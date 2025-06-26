function Test-TodayHoliday {
  <#
    .SYNOPSIS
    Checks if today is a holiday in a specific German state.

    .DESCRIPTION
    The function checks if today is a holiday in a specific German state. The state must be specified using the -state parameter. The function returns a message indicating whether today is a holiday or not.

    .PARAMETER state
    Specifies the German state for which the holiday should be checked. The parameter accepts the following values: BW, BY, BE, BB, HB, HE, HH, MV, NI, NW, RP, SL, SN, ST, SH, TH.

    .OUTPUTS
    The function returns a message indicating whether today is a holiday in the specified state.

    .EXAMPLE
    Test-TodayHoliday -state BW
    Checks if today is a holiday in Baden-Württemberg.

    .NOTES
    Version:        0.1
    Author:         dapf27
    Creation Date:  2025-01-30
    Purpose/Change: Initial script development
  #>

  #region------------------------------------------[Script Parameters]-------------------------------

  Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('BW', 'BY', 'BE', 'BB', 'HB', 'HE', 'HH', 'MV', 'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH')]
    [string]$state
  )

  #endregion

  #region------------------------------------------[Initialisations]---------------------------------

  #endregion

  #region------------------------------------------[Import Modules & Snap-ins]-----------------------

  # Import the Get-GermanHoliday function
  . .\Get-GermanHoliday.ps1

  #endregion

  #region------------------------------------------[Declarations]------------------------------------

  # Get the current date and year
  $today = Get-Date -Format 'dd.MM.yyyy'
  $year = Get-Date -Format 'yyyy'

  #endregion

  #region------------------------------------------[Functions]---------------------------------------

  #endregion

  #region------------------------------------------[Execution]---------------------------------------

  # Get the holidays for the current year and state
  $holidays = Get-GermanHoliday -year $year -state $state

  # Check if today is a holiday
  $holidayToday = $holidays | Where-Object { $_.Date.ToString('dd.MM.yyyy') -eq $today }

  if ($holidayToday) {
    return $holidayToday.Name
  } else {
    return $false
  }

  #endregion
}
