function Get-WorkTime {
  <#
  .SYNOPSIS
  Calculates the work time based on a start time and two breaks.

  .DESCRIPTION
  Calculates the work time based on a start time and two breaks. The function expects the start time and the break times in the format "HH:mm".

  .PARAMETER startTime
  The start time of the work day.

  .PARAMETER breaks
  An array of break times in the format [Start, End] e.g. @("09:30", "09:45", "12:00", "12:45").

  .OUTPUTS
  The function returns a string with the total work time in hours and minutes.

  .EXAMPLE
  Get-WorkTime -startTime "08:00" -breaks @("09:30", "09:45", "12:00", "12:45")
  Calculates the work time based on a start time of 08:00 and two breaks at 09:30-09:45 and 12:00-12:45.

  .NOTES
    Version:        0.1
    Author:         dapf27
    Creation Date:  2025-01-30
    Purpose/Change: Initial script development

  #>

  #region------------------------------------------[Script Parameters]-------------------------------

  param (
    # Format: "HH:mm"
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^(?:[01]\d|2[0-3]):[0-5]\d$')]
    [string]$startTime,
    # Array of breaks in the format [Start, End] e.g. @("09:30", "09:45", "12:00", "12:45")
    [Parameter(Mandatory = $true)]
    [array]$breaks
  )

  #endregion

  #region------------------------------------------[Initialisations]---------------------------------

  #endregion

  #region------------------------------------------[Import Modules & Snap-ins]-----------------------

  #endregion

  #region------------------------------------------[Declarations]------------------------------------

  # Convert strings to datetime objects
  [datetime]$startTime = [datetime]::ParseExact($startTime, 'HH:mm', $null)

  # Get current time
  $now = Get-Date

  #endregion

  #region------------------------------------------[Functions]---------------------------------------

  function Get-BreakTime($bStart, $bEnd) {
    if ($now -gt $bEnd) {
      # Break is already over -> deduct the entire break
      return $bEnd - $bStart
    } elseif ($now -gt $bStart) {
      # Break has already started -> only deduct the part of the break that has already passed
      return $now - $bStart
    }
    # Break has not yet started -> no deductions
    return [timespan]::Zero
  }

  #endregion

  #region------------------------------------------[Execution]---------------------------------------

  # Check if the work day has already started
  if ($now -gt $startTime) {

    # Calculate total time
    $totalTime = New-TimeSpan -Start $startTime -End $now

    # Calculate break time
    $breakTime = [timespan]::Zero
    for ($i = 0; $i -lt $breaks.Length; $i += 2) {
      $breakStart = [datetime]::ParseExact($breaks[$i], 'HH:mm', $null)
      $breakEnd = [datetime]::ParseExact($breaks[$i + 1], 'HH:mm', $null)
      $breakTime += Get-BreakTime -bStart $breakStart -bEnd $breakEnd
    }

    # Effektive Arbeitszeit berechnen
    $workTime = $totalTime - $breakTime

    #return $workTime.Hours, $workTime.Minutes, $workTime.Seconds, $workTime.TotalSeconds, $breakTime
    return $workTime, $breakTime
  }
  #endregion
}
