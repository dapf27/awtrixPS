<#
.SYNOPSIS
    Retrieves weather data and displays it on an Awtrix smart clock.

.DESCRIPTION
    This script:
    - Retrieves the Awtrix clock's IP address using an external function ('Get-AwtrixLocation.ps1').
    - Fetches weather data for the office location from OpenWeatherMap API (https://openweathermap.org).
    - Rounds and formats temperature values.
    - Assigns an appropriate weather icon based on the weather condition code.
    - Sends the formatted weather data to the Awtrix clock for display.

.OUTPUTS
  Create and update the app at the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixWeatherApp.ps1

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

# Set the proxy settings to use the system's default proxy
netsh winhttp import proxy source=ie
(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#endregion

#region------------------------------------------[Import Modules & Snap-ins]-----------------------

# Import external function to retrieve the Awtrix location
. .\..\Functions\Get-AwtrixLocation.ps1

#endregion

#region------------------------------------------[Declarations]------------------------------------

# API key from https://home.openweathermap.org/api_keys
$openweatherApiKey = '[YOUR KEY HERE]'

# Name of the app to be created on the Awtrix clock
$appName = 'Weather'

# Default payload structure for the Awtrix clock API request
$body = @{
  # Uppercase setting - 0=global setting, 1=forces uppercase; 2=shows as it sent.
  textCase     = 2
  # Removes the custom app when there is no update after the given time in seconds.
  lifetime     = 1830
  # 0 = deletes the app, 1 = marks it as staled with a red rectangle around the app
  lifetimeMode = 0
  # Modifies the scroll speed. Enter a percentage value of the original scroll speed.
  scrollSpeed  = 40
}

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
  # Construct API URL for OpenWeatherMap
  $url = "http://api.openweathermap.org/data/2.5/weather?q=$($location.Office)&appid=$openweatherApiKey&units=metric&lang=de"

  # Fetch weather data from OpenWeatherMap API
  $response = Invoke-RestMethod -Uri $url -Method Get

  # Round the temperature and the "feels like" temperature
  $temp = $([math]::Round($response.main.temp, 0))
  $tempFeel = $([math]::Round($response.main.feels_like, 0))

  # Add temperature info to the message body
  # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
  $body.Add('text', "$temp ($tempFeel) °C")

  # Assign appropriate weather icon based on condition codes
  # Reference: https://openweathermap.org/weather-conditions
  switch ($response.weather.id) {
    # Thunderstorm
    { $_ -match '^2[0-9]{2}$' } {
      $body.Add('icon', '8x8/weather/63084')
      break
    }
    # Drizzle
    { $_ -match '^3[0-9]{2}$' } {
      $body.Add('icon', '8x8/weather/60934')
      break
    }
    # Rain
    { $_ -match '^5[0-9]{2}$' } {
      $body.Add('icon', '8x8/weather/55417')
      break
    }
    # Snow
    { $_ -match '^6[0-9]{2}$' } {
      $body.Add('icon', '8x8/weather/60937')
      break
    }
    # Atmosphere
    { $_ -match '^7[0-9]{2}$' } {
      $body.Add('icon', '8x8/weather/2154')
      break
    }
    # Clear
    800 {
      $body.Add('icon', '8x8/weather/43263')
      break
    }
    # Part Clouds
    801 {
      $body.Add('icon', '8x8/weather/876')
      break
    }
    # Clouds
    { $_ -match '^80[2-9]$' } {
      $body.Add('icon', '8x8/weather/12294')
      break
    }
    default {
    }
  }

  # Send the weather to the Awtrix clock via API
  Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/custom?name=$appName" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
}

#endregion
