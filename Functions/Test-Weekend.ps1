function Test-Weekend {
  <#
    .SYNOPSIS
    Determines if the current day is a weekend day.

    .DESCRIPTION
    This function determines if the current day is a weekend day.

    .OUTPUTS
    Boolean value indicating whether the current day is a weekend day.

    .EXAMPLE
    Test-Weekend
    Returns True if the current day is a weekend day, otherwise False.

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

  $day = (Get-Date).DayOfWeek
  return ($day -eq 'Saturday' -or $day -eq 'Sunday')

  #endregion
}
