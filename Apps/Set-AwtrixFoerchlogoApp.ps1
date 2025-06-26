<#
.SYNOPSIS
  Displays the Foerch logo on an Awtrix smart clock.

.DESCRIPTION
  This script sends the Foerch logo to an Awtrix smart clock for display. The script retrieves the
  Awtrix clock's IP address using an external function ('Get-AwtrixLocation.ps1') and sends the logo
  to the clock via an HTTP API request. The script waits for a valid location to be returned before
  sending the logo to the clock.

.OUTPUTS
  Create and update the app at the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixFoerchlogoApp.ps1

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
. .\..\Functions\Get-AwtrixLocation.ps1

#endregion

#region------------------------------------------[Declarations]------------------------------------

# Define the name of the app to be created on the Awtrix clock
$appName = 'FoerchLogo'

# Default payload structure for the Awtrix clock API request
$body = @{
  # The icon ID or filename (without extension) to display on the app. You can also send a 8x8 jpg as Base64 String
  icon         = '32x8/foerch'
  # Removes the custom app when there is no update after the given time in seconds.
  lifetime     = 43200
  # 0 = deletes the app, 1 = marks it as staled with a red rectangle around the app
  lifetimeMode = 0
}

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
  # Send the logo to the Awtrix clock via API
  Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/custom?name=$appName" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
}
#endregion
