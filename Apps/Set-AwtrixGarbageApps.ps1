<#
.SYNOPSIS
  This script retrieves and displays waste collection schedules on an Awtrix smart clock.

.DESCRIPTION
  The script fetches waste collection data from an external API based on a predefined house number
  and waste type IDs. It processes the data and updates the Awtrix clock display to show upcoming
  waste collection days (today or tomorrow) with corresponding icons.

.OUTPUTS
  Create and update the app at the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixGarbageApps.ps1

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

$wastetypes = @{
  'Papiertonne' = @{
    id   = '19'
    icon = 'tonne_papier'
  }
  'Bioabfall'   = @{
    id   = '28'
    icon = 'tonne_bio'
  }
  'Restmüll'    = @{
    id   = '31'
    icon = 'tonne_restmuell'
  }
  #'Gelbe Tonne' = @{
  #  id =''
  #  icon = 'tonne_gelb'
  #}
}

$key = 'be047b0bf308c04e4dab7240aa418381'
$idHouseNumber = 194

# Define the name of the app to be created on the Awtrix clock
$appName = 'Garbage'

# Default payload structure for the Awtrix clock API request
$body = @{
  # The icon ID or filename (without extension) to display on the app. You can also send a 8x8 jpg as Base64 String
  icon         = $null
  # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
  text         = $null
  # Uppercase setting - 0=global setting, 1=forces uppercase; 2=shows as it sent.
  textCase     = 2
  # Modifies the scroll speed. Enter a percentage value of the original scroll speed.
  scrollSpeed  = 40
  # Removes the custom app when there is no update after the given time in seconds.
  lifetime     = 120
  # 0 = deletes the app, 1 = marks it as staled with a red rectangle around the app
  lifetimeMode = 0
}

# Initialize an empty object for storing location data
$location = [PSCustomObject]@{}

#endregion

#region------------------------------------------[Functions]---------------------------------------

function Get-RestOfTheDaySecond {
  # Get the remaining seconds of the day from now until end
  [CmdletBinding()]
  param (
  )
  $now = Get-Date
  $endOfDay = Get-Date -Hour 23 -Minute 59 -Second 59
  # Round for the smaller number
  $remainingSeconds = [math]::Floor(($endOfDay - $now).TotalSeconds)

  return $remainingSeconds
}

#endregion

#region------------------------------------------[Execution]---------------------------------------

# Wait until a valid location is returned
do {
  # Retrieve the Awtrix device location (IP address)
  $location = Get-AwtrixLocation
  Start-Sleep -Seconds 30
} until ($location.IP)

# Proceed only if a valid location is returned
if ((-not [string]::IsNullOrEmpty($location)) -and ($location.Office -eq '[CITY OF YOUR HOME]')) {
  # Get the current date and the next day
  $today = Get-Date
  $tomorrow = $today.AddDays(1)

  # Define the time period for the waste collection data
  # If today is December 31st, the period is from January 1st of the current year to December 31st of the next year
  if ($today.Month -eq 12 -and $today.Day -eq 31) {
    $period = "$($today.Year)0101-$($today.AddYears(1).Year)1231"
  } else {
    $period = "$($today.Year)0101-$($today.Year)1231"
  }

  # Get the IDs of the waste types
  $wastetypesIds = ($wastetypes.Values | ForEach-Object { $_['id'] } | Sort-Object) -join ','

  # Construct the URL for retrieving the waste collection data
  $url = "https://api.abfall.io/?key=$key&mode=export&idhousenumber=$idHouseNumber&wastetypes=$wastetypesIds&timeperiod=$period&showinactive=false&type=csv"

  # Attempt to retrieve the waste collection data
  try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing

    # Convert the content from ISO-8859-1 to UTF-8
    $contentLatin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($response.Content)
    # Convert the CSV data to a PowerShell object
    $csvData = $contentLatin1 | ConvertFrom-Csv -UseCulture
    # Get the column names and sort them
    $columnName = $csvData[0].PSObject.Properties.Name | Sort-Object

    # Iterate through the rows and columns of the CSV data
    foreach ($row in $csvData) {
      foreach ($column in $columnName) {
        $send = $false
        # Check if the cell is not empty
        if (-not [string]::IsNullOrEmpty($row.$column)) {
          # Convert the date to the format 'dd.MM.yyyy'
          $fieldDate = Get-Date $row.$column -Format 'dd.MM.yyyy'
          # Check if the date is valid
          if (-not [string]::IsNullOrEmpty($fieldDate)) {
            # Remove the umlauts and other strange letters
            $appName = $column.Replace('Ä', 'Ae').Replace('Ö', 'Oe').Replace('Ü', 'Ue').Replace('ä', 'ae').Replace('ö', 'oe').Replace('ü', 'ue').Replace('ß', 'ss')
            $appName = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding('Cyrillic').GetBytes($appName))
            # Get the icon for the waste type
            $appIcon = $wastetypes[$column].icon
            # Set the icon and lifetime of the app
            $body.icon = "8x8/garbage/$appIcon"
            $body.lifetime = Get-RestOfTheDaySecond
            # Check if today is a pick-up date in the csv list
            if ($fieldDate -eq $today.ToString('dd.MM.yyyy')) {
              # Set the textof the app
              $body.text = "HEUTE: $column"
              $send = $true
            } elseif ($fieldDate -eq $tomorrow.ToString('dd.MM.yyyy')) {
              # Set the textof the app
              $body.text = "MORGEN: $column"
              $send = $true
            }

            # Send the apps only to the clock if it has something to show
            if ($send) {
              # Send the status update to the Awtrix clock via API
              Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/custom?name=$appName" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
            }
          }
        }
      }
    }
  } catch {
    # Set the body for the app if there are no data available
    $body.text = 'Mülldaten nicht abrufbar!'
    $body.icon = '8x8/1059'
    $body.lifetime = Get-RestOfTheDaySecond
    # Send the status update to the Awtrix clock via API
    Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/custom?name=$appName" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
  }
}
#endregion
