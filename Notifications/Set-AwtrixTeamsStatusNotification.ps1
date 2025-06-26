<#
.SYNOPSIS
  Checks the current Microsoft Teams status and sends the status data to an Awtrix clock.

.DESCRIPTION
  This script retrieves the Microsoft Teams status from the log file and sends the status data to the
  Awtrix clock via an HTTP API request.

.OUTPUTS
  Update the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixTeamsStatusNotification.ps1

.LINK
  https://github.com/AntoineGS/teams-status-rs/issues/7#issuecomment-1913094747

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

# Define the log file path
$logFolderTeams = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Logs"

# Initialize an empty object for storing location data
$location = [PSCustomObject]@{}

#region------------------------------------------[Language local]----------------------------------

# Teams Activity
$taNotInACall = 'Nicht im Gespräch'
$taIncomingCall = 'Eingehender Anruf'
$taInACall = 'Im Gespräch'

# Teams Status
$tsAvailable = 'Verfügbar'
$tsBusy = 'Beschäftigt'
$tsAway = 'Abwesend'
$tsBeRightBack = 'Bin gleich zurück'
$tsDoNotDisturb = 'Nicht stören'
$tsOffline = 'Offline'
$tsFocusing = 'Fokussiert'
$tsPresenting = 'Präsentation'
$tsInAMeeting = 'In einer Besprechung'
$tsOnThePhone = 'Am Telefon'

# Camera Status
#$csCameraOn = 'An'
#$csCameraOff = 'Aus'

#endregion

#$currentStatus = $null
#$currentActivity = $null
#$currentCamStatus = $null
#$camStatus = $csCameraOff
$Activity = $null

#endregion

#region------------------------------------------[Settings]----------------------------------------

# Define the status and activity settings
$teamsActivityHash = @{
  # activity -- body settings
  $taNotInACall   = @( $taNotInACall, @{
      text = $taNotInACall
    } )
  $taInACall      = @( $taInACall, @{
      icon     = '8x8/teams/1232'
      text     = $taInACall
      color    = '#ff0000'
      fadeText = 1500
    } )
  $taIncomingCall = @( $taIncomingCall, @{
      text = $taIncomingCall
    } )
}

$teamsStatusHash = @{
  # state, state local -- body settings
  'Available'        = @( 'Available', $tsAvailable, @{
      text = $tsAvailable
    } )
  'Busy'             = @( 'Busy', $tsBusy, @{
      icon = '8x8/teams/46936'
      text = $tsBusy
    } )
  'Away'             = @( 'Away', $tsAway, @{
      icon = '8x8/teams/11520'
      text = $tsAway
    } )
  'BeRightBack'      = @( 'BeRightBack', $tsBeRightBack, @{
      icon = '8x8/teams/11520'
      text = $tsBeRightBack
    } )
  'DoNotDisturb'     = @( 'DoNotDisturb', $tsDoNotDisturb, @{
      icon     = '8x8/teams/56891'
      text     = $tsDoNotDisturb
      color    = '#ff0000'
      fadeText = 1500
    } )
  'Offline'          = @( 'Offline', $tsOffline, @{
      text = $tsOffline
    } )
  'Focusing'         = @( 'Focusing', $tsFocusing, @{
      text = $tsFocusing
    } )
  'Presenting'       = @( 'Presenting', $tsPresenting, @{
      text = $tsPresenting
    } )
  'presentertoolbar' = @( 'Presenting', $tsPresenting, @{
      text = $tsPresenting
    } )
  'InAMeeting'       = @( 'InAMeeting', $tsInAMeeting, @{
      text = $tsInAMeeting
    } )
  'OnThePhone'       = @( 'OnThePhone', $tsOnThePhone, @{
      icon = '8x8/teams/1232'
      text = $tsOnThePhone
    } )
}

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
    # Wait until the Teams process is running
    do {
      $TeamsProcess = Get-Process -Name *Teams* -ErrorAction SilentlyContinue
      if ($null -eq $TeamsProcess) {
        Write-Output 'Teams-Prozess nicht gefunden. Warte auf Neustart...'
        Start-Sleep -Seconds 10
      }
    } until ($TeamsProcess) # Repeat until the Teams process is running

    Start-Sleep -Seconds 20

    # Get the latest log file
    $logFileTeams = Get-ChildItem -Path $logFolderTeams -Filter 'MSTeams_*.log' | Sort-Object LastAccessTime -Descending | Select-Object -First 1

    # Get the last 1000 lines of the Teams log file and wait for new lines
    Get-Content -Path $logFileTeams.fullName -Encoding Utf8 -Tail 1000 -ReadCount 0 -Wait | ForEach-Object {
      # Initialize the body settings
      $body = @{
        # The icon ID or filename (without extension) to display on the app. You can also send a 8x8 jpg as Base64 String
        icon       = $null
        # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
        text       = $null
        # The text, bar or line color.
        color      = $null
        # Sets a background color.
        background = $null
        # Fades the text on and off in an given interval, not compatible with gradient or rainbow
        fadeText   = $null
        # Uppercase setting - 0=global setting, 1=forces uppercase; 2=shows as it sent.
        textCase   = 2
        # Set it to true, to hold your notification on top until you press the middle button or dismiss it via HomeAssistant. This key only belongs to notification.
        hold       = $true
      }

      # Check the Teams status
      $TeamsStatus = $_ | Select-String -Pattern 'Received Action: UserPresenceAction:', 'Navigation starting: about:blank?entityType=presentertoolbar' | Select-Object -Last 1

      # Check the Teams activity
      $TeamsActivity = $_ | Select-String -Pattern 'WebClientStatesModule', 'Attempting to play audio for notification type 1' | Select-Object -Last 1

      # Check if the Teams process is running
      if ($null -ne $TeamsProcess) {
        # Check if the Teams activity is not null
        if ($null -ne $TeamsActivity) {
          # Check the Teams activity
          if (($TeamsActivity -like '*new_state=Active*') -or ($TeamsActivity -like '*new_state=Inactive*') -or ($TeamsActivity -like '*new_state=LongInactive*')) {
            $Activity = $taNotInACall
            #if ($currentStatus -eq $tsPresenting) {
            #  $Status = $tsDoNotDisturb
            #} elseif ($currentStatus -eq $tsInAMeeting) {
            #  $Status = $tsBusy
            #}
          } elseif ($TeamsActivity -like '*new_state=VeryActive*') {
            $Activity = $taInACall
          } elseif ($TeamsActivity -like '*Attempting to play audio for notification type 1*') {
            $Activity = $taIncomingCall
          }
          # Set the body settings based on the Teams activity
          $teamsActivityHash.GetEnumerator() | ForEach-Object {
            if ($Activity -eq $_.Value[0]) {
              $_.Value[1].GetEnumerator() | ForEach-Object {
                $body[$_.Name] = $_.Value
              }
            }
          }
        } else {
          $Activity = $taNotInACall
        }

        # Check the Teams status
        if (($null -ne $TeamsStatus) -and ($Activity -eq $taNotInACall)) {
          $Status = $tsAvailable
          # Set the body settings based on the Teams status
          $teamsStatusHash.GetEnumerator() | ForEach-Object {
            if (($TeamsStatus -like "*, availability: $($_.Value[0])}") -or ($TeamsStatus -like "*Navigation starting: about:blank?entityType=$($_.Name)*")) {
              $Status = $_.Value[1]
              if ($Activity -eq $taInACall -and $Status -eq $tsDoNotDisturb) {
                $Status = $tsPresenting
              } elseif ($Activity -eq $taInACall) {
                $Status = $tsInAMeeting
              }
              $_.Value[2].GetEnumerator() | ForEach-Object {
                $body[$_.Name] = $_.Value
              }

            }
          }
        }
      } else {
        $Status = $tsOffline
        $Activity = $taNotInACall
      }

      # If the Teams status or activity is not null, send the status data to the Awtrix clock
      if (($null -ne $TeamsStatus) -and ($Activity -eq $taNotInACall)) {
        #Write-Output "Teams Status: $Status"
        if (($Status -eq $tsAvailable) -or ($Status -eq $tsOffline)) {
          # If the status is available or offline, dismiss the notification
          Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/notify/dismiss" | Out-Null
        } else {
          # Send the status update to the Awtrix clock via API
          Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/notify/dismiss" | Out-Null
          Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/notify" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
        }
      }

      # If the Teams activity is not null and the activity is in a call, send the status data to the Awtrix clock
      if (($null -ne $TeamsActivity) -and ($Activity -eq $taInACall)) {
        #Write-Output "Teams Activity: $Activity"

        # Send the status update to the Awtrix clock via API
        Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/notify/dismiss" | Out-Null
        Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/notify" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
      }

      <# TODO: Check the camera status
    if ($Activity -eq $taInACall -or $camStatus -eq $csCameraOn) {
      $registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam\MSTeams_8wekyb3d8bbwe\'

      $webcam = Get-ItemProperty -Path $registryPath -Name LastUsedTimeStop | Select-Object LastUsedTimeStop

      if ($webcam.LastUsedTimeStop -eq 0) {
        $camStatus = $csCameraOn
        Write-Output "Camera Activity: $camStatus"
      } else {
        $camStatus = $csCameraOff
        Write-Output "Camera Activity: $camStatus"
      }
    }

    if ($currentActivity -ne $Activity) {
      $currentActivity = $Activity
    }

    if ($null -ne $camStatus -and $currentCamStatus -ne $camStatus) {
      $currentCamStatus = $camStatus
    }
    #>
      #$Status = $null

      # If the Teams process is not running, break the loop and wait for the process to restart
      $TeamsProcess = Get-Process -Name *Teams* -ErrorAction SilentlyContinue
      if ($null -eq $TeamsProcess) {
        Write-Output 'Teams process ended. Restart monitoring...'
        break  # Break the loop and wait for the Teams process to restart
      }
    }
  }
}
#endregion
