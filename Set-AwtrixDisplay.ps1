<#
.SYNOPSIS
  Check the battery status, power state and if the system is unlocked to control the display of the Awtrix smart clock.

.DESCRIPTION
  This script retrieves the battery status using 'Get-CimInstance' from the 'Win32_Battery' class.
  Based on the battery status, it determines whether the system is running on battery power or
  connected to an AC power source. The power state is then sent as a JSON payload to the
  Awtrix clock via an HTTP API request. The script also checks if the system is unlocked and
  running on AC power to turn on the display. If the system is locked or running on battery power, the
  display is turned off.

.OUTPUTS
  Update the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixDisplay.ps1

.NOTES
  Version:        0.1
  Author:         dapf27
  Creation Date:  2025-01-30
  Purpose/Change: Initial script development
#>

#region------------------------------------------[Script Parameters]-------------------------------

[CmdletBinding(SupportsShouldProcess)]
Param (
)

#endregion

#region------------------------------------------[Initialisations]---------------------------------

# if run with "-Debug", all Write-Debug messages will be displayed
if ($PSBoundParameters['debug']) {
  $DebugPreference = 'Continue'
  Write-Debug '(!) Debug mode active...'
}
# if run with "-Verbose", all Write-Verbose messages will be displayed
if ($PSBoundParameters['verbose']) {
  $VerbosePreference = 'Continue'
  Write-Verbose '(!) Verbose mode active...'
}

#endregion

#region------------------------------------------[Import Modules & Snap-ins]-----------------------

# Import external function to retrieve the Awtrix location
. .\Functions\Get-AwtrixLocation.ps1

#endregion

#region------------------------------------------[Declarations]------------------------------------

# Initialize an empty object for storing location data
$location = [PSCustomObject]@{}

#endregion

#region------------------------------------------[Functions]---------------------------------------

#endregion

#region------------------------------------------[Execution]---------------------------------------

# Wait until a valid location is returned
do {
  # Retrieve the Awtrix device location (IP address)
  $location = Get-AwtrixLocation
  Start-Sleep -Seconds 30
} until ($location.IP)

# Proceed only if a valid location is returned
if (-not [string]::IsNullOrEmpty($location)) {
  while ($true) {
    # Retrieve battery status from the system
    $batteryStatus = Get-CimInstance -ClassName Win32_Battery

    # Determine if the system is unlocked
    if ([string]::IsNullOrEmpty((Get-Process -Name logonUI -ErrorAction SilentlyContinue))) {
      # System is unlocked
      $unlocked = $true
    } else {
      # System is locked
      $unlocked = $false
    }

    # Determine power state based on battery status
    switch ($batteryStatus.BatteryStatus) {
      1 {
        # Battery mode (running on battery)
        $acPower = $false
      }
      2 {
        # AC power mode (plugged in)
        $acPower = $true
      }
      default {
        # Default case (assume battery mode if status is unknown)
        $acPower = $false
      }
    }

    # If the system is unlocked and running on AC power, turn on the display
    # If the system is locked or running on battery power, turn off the display
    # Otherwise, turn off the display
    if ($unlocked -and $acPower) {
      $body = @{
        # Display on
        power = $true
      }
    } elseif (-not $unlocked -and $acPower) {
      $body = @{
        # Display off
        power = $false
      }
    } else {
      $body = @{
        # Display off
        power = $false
      }
    }

    # Send the power status to the Awtrix clock API
    Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/power" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null

    # Wait 10 seconds
    Start-Sleep -Seconds 10
  }
}
#endregion
