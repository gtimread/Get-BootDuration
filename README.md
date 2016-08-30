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
