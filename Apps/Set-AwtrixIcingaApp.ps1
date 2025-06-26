<#
.SYNOPSIS
  Monitors an Icinga instance for critical, unacknowledged hosts and services and sends the data to an Awtrix clock.

.DESCRIPTION
  This script connects to an Icinga monitoring server to retrieve the number of critical
  but unacknowledged hosts and services. The data is then sent to an Awtrix clock via its API
  for display. The script first verifies the Icinga server connection and retries if unavailable.
  If the connection is successful, it fetches the data and updates the Awtrix display.

.OUTPUTS
  Create and update the app at the awtrix smart clock

.EXAMPLE
  Run the script:
  .\Set-AwtrixIcingaApp.ps1

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

# Define the Icinga API URL and authentication token
$icingaUrl = '[YOUR ICINGA URL HERE]' # e.g., 'icinga.example.com'
$icingaAuth = '[YOUR AUTH TOKEN HERE]'

# Define the name of the app to be created on the Awtrix clock
$appName = 'Icinga'

# Default payload structure for the Awtrix clock API request
$body = @{
  # The icon ID or filename (without extension) to display on the app. You can also send a 8x8 jpg as Base64 String
  icon         = '8x8/8544'
  # Uppercase setting - 0=global setting, 1=forces uppercase; 2=shows as it sent.
  textCase     = 2
  # Modifies the scroll speed. Enter a percentage value of the original scroll speed.
  scrollSpeed  = 40
  # Removes the custom app when there is no update after the given time in seconds.
  lifetime     = 120
  # 0 = deletes the app, 1 = marks it as staled with a red rectangle around the app
  lifetimeMode = 0
}

# Set up HTTP headers for the Icinga API request
$headers = @{}
$headers.Add('Accept', '*/*')
$headers.Add('Authorization', "Basic $icingaAuth")
$headers.Add('Content-Type', 'application/json')

# Define API request URLs and filters for retrieving Icinga service and host problems
$reqUrlServices = "https://$($icingaUrl):5665/v1/objects/services"
$bodyServices = '{ "filter": "service.state==2 && service.acknowledgement==0 && service.handled==false" }'

$reqUrlHosts = "https://$($icingaUrl):5665/v1/objects/hosts"
$bodyHosts = '{ "filter": "host.state==1 && host.acknowledgement==0 && host.handled==false" }'

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
  # Check if the Icinga server is reachable before proceeding
  if ((Test-NetConnection -ComputerName $icingaUrl -Port 5665).TcpTestSucceeded) {
    # Attempt to retrieve the number of unacknowledged service issues from Icinga
    try {
      $responseServices = Invoke-RestMethod -Uri $reqUrlServices -Method Get -Headers $headers -ContentType 'application/json' -Body $bodyServices -SkipCertificateCheck
      $servicesCount = $responseServices.results.attrs.Count
    } catch {
      $servicesCount = '-'
    }

    # Attempt to retrieve the number of unacknowledged host issues from Icinga
    try {
      $responseHosts = Invoke-RestMethod -Uri $reqUrlHosts -Method Get -Headers $headers -ContentType 'application/json' -Body $bodyHosts -SkipCertificateCheck
      $hostsCount = $responseHosts.results.attrs.Count
    } catch {
      $hostsCount = '-'
    }

    # The text to display. Keep in mind the font does not have a fixed size and I uses less space than W. This facts affects when text will start scrolling
    $body.Add('text', "Host: $hostsCount - Svc: $servicesCount")

    # Send the status update to the Awtrix clock via API
    Invoke-RestMethod -Method Post -Uri "http://$($location.IP)/api/custom?name=$appName" -Body ($body | ConvertTo-Json -Compress) -ContentType 'application/json' | Out-Null
  }
}
#endregion
