function Get-AwtrixLocation {
  <#
  .SYNOPSIS
    Function for managing the location of the awtrix clock and setting different options

  .DESCRIPTION
    Function for managing the location of the awtrix clock and setting different options

  .OUTPUTS
  CSV file containing the list of synchronized contacts.

  .EXAMPLE
    Get-AwtrixLocation

  .NOTES
    Version:        0.1
    Author:         dapf27
    Creation Date:  2025-01-30
    Purpose/Change: Initial script development
  #>

  #region------------------------------------------[Script Parameters]-------------------------------

  Param (
  )

  #endregion

  #region------------------------------------------[Initialisations]---------------------------------

  #endregion

  #region------------------------------------------[Import Modules & Snap-ins]-----------------------

  #endregion

  #region------------------------------------------[Declarations]------------------------------------

  #endregion

  #region------------------------------------------[Functions]---------------------------------------

  #endregion

  #region------------------------------------------[Execution]---------------------------------------

  # Retrieves all IPv4 addresses of the computer that fall within a specific range.
  # - Only IPv4 addresses are considered.
  # - Addresses in the range 192.168.178.* are included.
  # - Addresses in the range 10.*.*.* are also included, except for those starting with 10.49.*.
  $ipAddresses = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match '^192\.168\.178\.' -or ($_.IPAddress -match '^10\.' -and $_.IPAddress -notmatch '^10\.49\.') }).IPAddress

  # Determines the office location based on the detected IP address.
  # - If the IP address matches 192.168.178.*, it assigns "city of your home".
  # - If the IP address is in the 10.* range but not in 10.49.*, it assigns "city of your office".
  # - If none of the conditions match, the default location is "default city name".
  switch ($ipAddresses) {
    # your Awtrix clock at home
    { $_ -match '^192\.168\.178\.' } {
      $result = [PSCustomObject]@{
        Office = 'City name of your home'
        IP     = '192.168.178.xxx'
      }
      break
    }
    # for example if you have a second Awtrix clock in your office
    { $_ -match '^10\.' -and $_ -notmatch '^10\.49\.' } {
      $result = [PSCustomObject]@{
        Office = 'City name of your Office'
        IP     = '10.xxx.xxx.xxx'
      }
      break
    }
    # default case if no specific IP address matches
    default {
      $result = [PSCustomObject]@{
        Office = 'Default city name'
        IP     = '192.168.178.xxx'
      }
    }
  }

  # If the IP is reachable, the script returns the full $result object otherwise it is null.
  if (-not (Test-Connection $result.IP -Count 1 -Quiet)) {
    $result = $null
  }

  return $result

  #endregion
}
