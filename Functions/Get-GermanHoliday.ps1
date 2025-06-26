function Get-GermanHoliday {
  <#
    .SYNOPSIS
    Calculates the German holidays for a given year and state.

    .DESCRIPTION
    This function calculates the German holidays for a given year and state.

    .PARAMETER year
    The year for which the holidays should be calculated.

    .PARAMETER state
    The state for which the holidays should be calculated. If no state is specified, the holidays that are the same for all states are returned.

    .OUTPUTS
    A list of German holidays for the specified year and state.

    .EXAMPLE
    Get-GermanHoliday -year 2025 -state 'BW'
    Calculates the German holidays for the year 2025 in the state of Baden-Württemberg.

    .LINK
    https://de.wikipedia.org/wiki/Feiertage_in_Deutschland

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
    [int]$year,
    [Parameter(Mandatory = $false)]
    [ValidateSet('BW', 'BY', 'BE', 'BB', 'HB', 'HE', 'HH', 'MV', 'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH')]
    [string]$state
  )

  #endregion

  #region------------------------------------------[Initialisations]---------------------------------

  #endregion

  #region------------------------------------------[Import Modules & Snap-ins]-----------------------

  # Import the Get-EasterSunday function
  . .\Get-EasterSunday.ps1

  #endregion

  #region------------------------------------------[Declarations]------------------------------------

  #endregion

  #region------------------------------------------[Functions]---------------------------------------

  #endregion

  #region------------------------------------------[Execution]---------------------------------------

  # Function to calculate Easter Sunday
  $easterSunday = Get-EasterSunday -year $year

  # Holidays that are the same for all states
  $holidays = @(
    @{ Name = 'Neujahr'; Date = Get-Date -Year $year -Month 1 -Day 1 }
    @{ Name = 'Karfreitag'; Date = $easterSunday.AddDays(-2) }
    @{ Name = 'Ostermontag'; Date = $easterSunday.AddDays(1) }
    @{ Name = 'Tag der Arbeit'; Date = Get-Date -Year $year -Month 5 -Day 1 }
    @{ Name = 'Christi Himmelfahrt'; Date = $easterSunday.AddDays(39) }
    @{ Name = 'Pfingstmontag'; Date = $easterSunday.AddDays(50) }
    @{ Name = 'Tag der Deutschen Einheit'; Date = Get-Date -Year $year -Month 10 -Day 3 }
    @{ Name = '1. Weihnachtstag'; Date = Get-Date -Year $year -Month 12 -Day 25 }
    @{ Name = '2. Weihnachtstag'; Date = Get-Date -Year $year -Month 12 -Day 26 }
  )

  # Holidays that are specific to individual states
  $statespecificHolidays = @{
    # 'BW' = Baden-Württemberg
    'BW' = @(
      @{ Name = 'Heilige Drei Könige'; Date = Get-Date -Year $year -Month 1 -Day 6 }
      @{ Name = 'Fronleichnam'; Date = $easterSunday.AddDays(60) }
      @{ Name = 'Allerheiligen'; Date = Get-Date -Year $year -Month 11 -Day 1 }
    )
    # 'BY' = Bayern
    'BY' = @(
      @{ Name = 'Heilige Drei Könige'; Date = Get-Date -Year $year -Month 1 -Day 6 }
      @{ Name = 'Fronleichnam'; Date = $easterSunday.AddDays(60) }
      @{ Name = 'Mariä Himmelfahrt'; Date = Get-Date -Year $year -Month 8 -Day 15 }
      @{ Name = 'Allerheiligen'; Date = Get-Date -Year $year -Month 11 -Day 1 }
    )
    # 'BE' = Berlin
    'BE' = @(
      @{ Name = 'Internationaler Frauentag'; Date = Get-Date -Year $year -Month 3 -Day 8 }
    )
    # 'BB' = Brandenburg
    'BB' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'HB' = Bremen
    'HB' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'HE' = Hessen
    'HE' = @(
      @{ Name = 'Fronleichnam'; Date = $easterSunday.AddDays(60) }
    )
    # 'HH' = Hamburg
    'HH' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'MV' = Mecklenburg-Vorpommern
    'MV' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'NI' = Niedersachsen
    'NI' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'NW' = Nordrhein-Westfalen
    'NW' = @(
      @{ Name = 'Fronleichnam'; Date = $easterSunday.AddDays(60) }
    )
    # 'RP' = Rheinland-Pfalz
    'RP' = @(
      @{ Name = 'Fronleichnam'; Date = $easterSunday.AddDays(60) }
    )
    # 'SL' = Saarland
    'SL' = @(
      @{ Name = 'Mariä Himmelfahrt'; Date = Get-Date -Year $year -Month 8 -Day 15 }
      @{ Name = 'Fronleichnam'; Date = $easterSunday.AddDays(60) }
    )
    # 'SN' = Sachsen
    'SN' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
      @{ Name = 'Buß- und Bettag'; Date = Get-Date -Year $year -Month 11 -Day 1 | Where-Object { $_.DayOfWeek -eq 'Wednesday' }
      }
    )
    # 'ST' = Sachsen-Anhalt
    'ST' = @(
      @{ Name = 'Heilige Drei Könige'; Date = Get-Date -Year $year -Month 1 -Day 6 }
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'SH' = Schleswig-Holstein
    'SH' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
    # 'TH' = Thüringen
    'TH' = @(
      @{ Name = 'Reformationstag'; Date = Get-Date -Year $year -Month 10 -Day 31 }
    )
  }

  # If a state was specified, add the state-specific holidays to the list
  if ($state -and $statespecificHolidays.ContainsKey($state)) {
    $holidays += $statespecificHolidays[$state]
  }

  # Sort the holidays by date
  return $holidays | Sort-Object Date

  #endregion
}
