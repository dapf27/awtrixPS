function Get-EasterSunday {
  <#
    .SYNOPSIS
    Calculates the date of Easter Sunday for a given year.

    .DESCRIPTION
    This function calculates the date of Easter Sunday for a given year using the Gausian algorithm.

    .PARAMETER year
    The year for which the date of Easter Sunday should be calculated.

    .OUTPUTS
    The date of Easter Sunday for the specified year.

    .EXAMPLE
    Get-EasterSunday -year 2025
    Calculates the date of Easter Sunday for the year 2025.

    .LINK
    https://de.wikipedia.org/wiki/Gau%C3%9Fsche_Osterformel

    .NOTES
    Version:        0.1
    Author:         dapf27
    Creation Date:  2025-01-30
    Purpose/Change: Initial script development
  #>

  #region------------------------------------------[Script Parameters]-------------------------------

  Param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1583, 4099)]
    [int]$year
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

  $a = $year % 19
  $b = [math]::Floor($year / 100)
  $c = $year % 100
  $d = [math]::Floor($b / 4)
  $e = $b % 4
  $f = [math]::Floor(($b + 8) / 25)
  $g = [math]::Floor(($b - $f + 1) / 3)
  $h = (19 * $a + $b - $d - $g + 15) % 30
  $i = [math]::Floor($c / 4)
  $k = $c % 4
  $l = (32 + 2 * $e + 2 * $i - $h - $k) % 7
  $m = [math]::Floor(($a + 11 * $h + 22 * $l) / 451)
  $month = [math]::Floor(($h + $l - 7 * $m + 114) / 31)
  $day = (($h + $l - 7 * $m + 114) % 31) + 1

  return Get-Date -Year $year -Month $month -Day $day

  #endregion
}
