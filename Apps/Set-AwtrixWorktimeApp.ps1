<#
.SYNOPSIS
  Create and update the app at the awtrix smart clock

.DESCRIPTION
  This script calculates the work time progress based on the start time and break times
  provided in the 'startwork.txt' file. It then sends the work time progress to the Awtrix
  clock via its API for display. The script also checks if today is a weekend or a holiday
  and displays the overtime hours and minutes in such cases.

.OUTPUTS
  Create and update the app at the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixWorktimeApp.ps1

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

# Import external functions for checking holidays and weekends
. .\..\Functions\Test-TodayHoliday.ps1
. .\..\Functions\Test-Weekend.ps1

# Import external function for calculating work time
. .\..\Functions\Get-Worktime.ps1

#endregion

#region------------------------------------------[Declarations]------------------------------------

# Path to the file storing the start work time
$startworkPath = '.\Files\startwork.txt'

# Name of the app to be created on the Awtrix clock
$appName = 'Worktime'

# Default payload structure for the Awtrix clock API request
$body = @{
  # The icon ID or filename (without extension) to display on the app. You can also send a 8x8 jpg as Base64 String
  icon         = '8x8/1609'
  # Uppercase setting - 0=global setting, 1=forces uppercase; 2=shows as it sent.
  textCase     = 2
  # Modifies the scroll speed. Enter a percentage value of the original scroll speed.
  scrollSpeed  = 40
  # Removes the custom app when there is no update after the given time in seconds.
  lifetime     = 120
  # 0 = deletes the app, 1 = marks it as staled with a red rectangle around the app
  lifetimeMode = 0
}

# Define the breaks during the workday as an array of time strings - format 'HH:mm'
$breaks = @('09:30', '09:45', '12:00', '12:45')

# Define the normal working hours for a day
$normalWorkingHours = [TimeSpan]::FromHours(8)

# Initialize an empty object for storing location data
$location = [PSCustomObject]@{}

#endregion

#region------------------------------------------[Functions]---------------------------------------

#endregion

#region------------------------------------------[Execution]---------------------------------------

# Retrieve the Awtrix device location (IP address)
$location = Get-AwtrixLocation

# Proceed only if a valid location is returned
if (-not [string]::IsNullOrEmpty($location)) {
  # Wait until the startwork.txt file contains today's date
  do {
    $startworkFile = Get-Content -Path $startworkPath -Encoding utf8BOM
    if ((Get-Date -Date $startworkFile[0]) -ne (Get-Date -Format 'yyyy-MM-dd')) {
      Start-Sleep -Seconds 10
    }
  } until (
    (Get-Date -Date $startworkFile[0]) -eq (Get-Date -Format 'yyyy-MM-dd')
  )

  # Calculate the work time and break time
  $workTime, $breakTime = Get-WorkTime -startTime "$($startworkFile[1].PadLeft(2, '0')):$($startworkFile[2].PadLeft(2, '0'))" -breaks $breaks

  # Check if today is a weekend or a holiday
  if ((Test-Weekend) -or (Test-TodayHoliday -state 'BW')) {
    # If today is a weekend or a holiday, display the overtime hours and minutes
    $addBody = @{
      # Overtime hours and minutes
      # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
      text  = "$($workTime.Hours):$($workTime.Minutes.ToString('D2'))"
      # The text, bar or line color.
      color = '#00ff00'
    }
  } else {
    # Calculate percentage of work time completed
    $gonePercent = ($workTime.TotalSeconds / $normalWorkingHours.TotalSeconds) * 100

    # Determine whether still within work hours or in overtime
    if ($gonePercent -le 100) {
      # If within the 8-hour shift, display percentage progress
      $addBody = @{
        # Rounded percentage
        # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
        text       = "$([math]::Round($gonePercent,2)) % - $($workTime.Hours):$(($workTime.Minutes).ToString('D2'))"
        # Shows a progress bar. Value can be 0-100.
        progress   = [math]::Round($gonePercent)
        # The color of the progress bar.
        progressC  = '#00ff00'
        # The color of the progress bar background.
        progressBC = '#ff0000'
      }
    } else {
      # If overtime, calculate the extra time worked
      $overTime = $workTime - $normalWorkingHours
      $addBody = @{
        # Overtime hours and minutes
        # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
        text       = "$($overTime.Hours):$(($overTime.Minutes).ToString('D2'))"
        # Sets a background color.
        background = '#ff0000'
        # Fades the text on and off in an given interval, not compatible with gradient or rainbow
        fadeText   = 1500
      }
    }
  }

  # Merge additional body parameters into the main API payload
  foreach ($key in $addBody.Keys) {
    $body[$key] = $addBody[$key]
  }

  # Send the work time progress to the Awtrix clock via API
  Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/custom?name=$appName" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
}

#endregion
