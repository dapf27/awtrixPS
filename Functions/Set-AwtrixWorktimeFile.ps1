<#
.SYNOPSIS
  Prompts the user to enter their start work time once per day and stores the data in a file.

.DESCRIPTION
  This script checks if a stored start work date matches today's date.
  - If the date is different (or the file is missing), it opens a graphical user interface (GUI).
  - The user inputs their work start hours and minutes.
  - If the file already contains today's date, the script exits without prompting.
  The GUI is built using Windows Presentation Foundation (WPF) via XAML.

.OUTPUTS
  The input is saved in a text file ('.\startwork.txt').

.EXAMPLE
  Run the script:
  .\Set-AwtrixWorktimeFile.ps1

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

#endregion

#region------------------------------------------[Declarations]------------------------------------

# Define the file path where the start time will be stored
$startworkPath = '.\..\Apps\Files\startwork.txt'

# Define the XAML UI structure for user input (WPF Window)
$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Starting time" Height="170" Width="250" WindowStartupLocation="CenterScreen">
  <Grid>
    <TextBlock Text="Hours:" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="10,20,0,0"/>
    <TextBox Name="HoursInput" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="80,20,10,0" Width="50"/>

    <TextBlock Text="Minutes:" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="10,50,0,0"/>
    <TextBox Name="MinutesInput" VerticalAlignment="Top" HorizontalAlignment="Left" Margin="80,50,10,0" Width="50"/>

    <Button Content="OK" Name="OKButton" Width="80" Height="30" VerticalAlignment="Bottom" HorizontalAlignment="Center" Margin="0,0,0,10"/>
  </Grid>
</Window>
'@

# Global variables to store user input
$script:hours = $null
$script:minutes = $null

#endregion

#region------------------------------------------[Functions]---------------------------------------

# Function to process user input and close the window
function ProcessInput {
  Param (
    $Window
  )
  $script:hours = $Window.FindName('HoursInput').Text
  $script:minutes = $Window.FindName('MinutesInput').Text
  $Window.Close()
}

#endregion

#region------------------------------------------[Execution]---------------------------------------

# Check if the file exists, create it if not
if (-not (Test-Path $startworkPath)) {
  New-Item -Path $startworkPath -ItemType File | Out-Null
}

# Read the content of the start work file
$startworkFile = Get-Content -Path $startworkPath -Encoding utf8BOM

# Check if the stored date is different from today's date
if ([string]::IsNullOrWhiteSpace($startworkFile) -or ((Get-Date -Date $startworkFile[0]) -ne (Get-Date -Format 'yyyy-MM-dd'))) {
  Add-Type -AssemblyName PresentationFramework

  # Parse and load the XAML UI
  $reader = (New-Object System.Xml.XmlNodeReader ([xml]$XAML))
  $Window = [Windows.Markup.XamlReader]::Load($reader)

  # Attach event handlers to buttons and text fields
  $Window.FindName('OKButton').Add_Click({
      ProcessInput -Window $Window
    })

  $Window.FindName('MinutesInput').Add_KeyDown({
      param($send, $e)
      $send | Out-Null
      if ($e.Key -eq 'Return') {
        ProcessInput -Window $Window
      }
    })

  $Window.Add_Loaded({
      $Window.FindName('HoursInput').Focus()
    })

  # Show the dialog and wait for user input
  $Window.ShowDialog() | Out-Null

  # Save the entered data to the file
  Set-Content -Path $startworkPath -Value $(Get-Date -Format 'yyyy-MM-dd') -Force -Encoding utf8BOM
  Add-Content -Path $startworkPath -Value $script:hours -Force -Encoding utf8BOM
  Add-Content -Path $startworkPath -Value $script:minutes -Force -Encoding utf8BOM
}

#endregion
