<#
AUTHOR: Tim Read
DATE: 14 July 2015
Contact:tim.read@gmail.com
.SYNOPSIS
Script to retrieve Windows boot history and performance and display sub-optimal boot times to the end user in a chart
.DESCRIPTION
Script requires .NET Framework 4.0 on the client, which includes the built-in Chart controls used to display data to the user.
Currently the script must be run interactively, or via scheduled task, as the end user. PowerShell Execution Policy must be set to Unrestricted. Script retrieves EventID 100 entries from the Windows Diagnostics-Performance Operational Log. Pre-defined Boot time thresholds are built into Windows Client Operating Systems, via multiple Registry Keys at 
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\Performance\Boot\. For example PostBootMinorThreshold_Sec (30 seconds)
and PostBootMajorThreshold_Sec (60 seconds). The BootPostBootTime parameter in Event 100 is compared with these values. 
If it's less than 30 seconds, Event 100 is a Warning level; if between 60 and 59, Error level, and if 60 or more,
or if a "critical" service took longer than expected to start up, Critical level. The script retrieves the last 5 of these
Event ID 100 events and extracts the data to a Chart using PowerShell Chart Controls. The chart displays a Save button so that 
the user can save a copy. 
.EXAMPLE
.\Get-BootDuration.ps1
.LINK
Determining Windows Boot Time
http://www.happysysadm.com/2014/07/windows-boot-history-and-boot.html
Charting with PowerShell
http://blogs.technet.com/b/richard_macdonald/archive/2009/04/28/3231887.aspx
#>
$ErrorActionPreference = "SilentlyContinue"
# Fix for Get-WinEvent failing to populate localised Message event log field in some system locales
[System.Threading.Thread]::CurrentThread.CurrentCulture = New-Object "System.Globalization.CultureInfo" "en-US"
# Create Arrays containing data from EventID 100 events found in Microsoft-Windows-Diagnostics-Performance/Operational log
$BootTimeEvents = Get-WinEvent -FilterHashtable @{logname='Microsoft-Windows-Diagnostics-Performance/Operational';id=100} -MaxEvents 5
$BootDurations = $BootTimeEvents | %{($_.Message.Split("`n")[1].split(":")[1].trim().Replace("ms","")/1000)}
$BootDates = $BootTimeEvents | %{$_.TimeCreated}
# Load the appropriate Chart assemblies 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
# Create the Chart Object
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
$Chart.Width = 500 
$Chart.Height = 450 
$Chart.Left = 40 
$Chart.Top = 30
# Define Chart Area to draw on and add this to the chart
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
$Chart.ChartAreas.Add($ChartArea)
# add title and axes labels 
#[void]$Chart.Titles.Add("Last 5 Windows Boot Events Time and Duration")
$titlefont = new-object system.drawing.font("ARIAL",12,[system.drawing.fontstyle]::bold)
$title = New-Object System.Windows.Forms.DataVisualization.Charting.title
$chart.titles.add($title)
$chart.titles[0].text = "Recent Windows Sub-Optimal Boot Times - Date and Duration"
$chart.titles[0].font = $titlefont
# Add axes labels
$ChartArea.AxisX.Title = "Date" 
$ChartArea.AxisY.Title = "Duration (Seconds)"
# Add data to chart
[void]$Chart.Series.Add("Data") 
$Chart.Series["Data"].Points.DataBindXY($BootDates,$BootDurations)
# Make chart bars into 3d cylinders 
$Chart.Series["Data"]["DrawingStyle"] = "Cylinder"
# Find point with max/min values and change their colour 
$maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue() 
$maxValuePoint.Color = [System.Drawing.Color]::Red
$minValuePoint = $Chart.Series["Data"].Points.FindMinByValue() 
$minValuePoint.Color = [System.Drawing.Color]::Green
# Change chart area colour 
$Chart.BackColor = [System.Drawing.Color]::Transparent
# Display the chart on a form 
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor 
                [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
$Form = New-Object Windows.Forms.Form 
$Form.Text = "PowerShell Chart" 
$Form.Width = 600
$Form.Height = 600
$Form.controls.add($Chart) 
# Add Save button to the form, for the user to capture the chart as a .PNG file on their desktop
$SaveButton = New-Object Windows.Forms.Button 
$SaveButton.Text = "Save" 
$SaveButton.Top = 500 
$SaveButton.Left = 500
$SaveButton.Height = 35
$SaveButton.Width = 60
$SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right 
$SaveButton.add_click({$Chart.SaveImage($Env:USERPROFILE + "\Desktop\WindowsBootTimeChart.png", "PNG")})
$Form.controls.add($SaveButton)
$Form.Add_Shown({$Form.Activate()}) 
$Form.ShowDialog()