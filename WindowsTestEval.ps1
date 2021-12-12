#
# ####################################
#   Windows Test Evaluation Script   #
######################################
#
# Run this script to gather system information and diagnostics information on Windows endpoints
# to troubleshoot common issues.
#
# Author: Chad Eckles
# Release Date: 30 Oct 2020
#
###########################################################################################

$properties=@(
    @{Name="Name"; Expression = {$_.name}},
    @{Name="PID"; Expression = {$_.IDProcess}},
    @{Name="CPU (%)"; Expression = {$_.PercentProcessorTime}},
    @{Name="Memory (MB)"; Expression = {[Math]::Round(($_.workingSetPrivate / 1mb),2)}}
    @{Name="Disk (MB)"; Expression = {[Math]::Round(($_.IODataOperationsPersec / 1mb),2)}}
)
$ProcessCPU = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process |
    Select-Object $properties |
    Sort-Object "Memory (MB)" -desc |
    Select-Object -First 15

$top_CPU_processes = $ProcessCPU | select *,@{Name="Path";Expression = {(Get-Process -Id $_.PID).Path}} | Format-Table
$hostname=hostname
$update_info=wmic qfe
$datetime = Get-Date
$chrome_version=(Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo | Select ProductVersion | ft -HideTableHeaders | Out-String
$gp_info=gpresult /r
$top_app_errors=Get-EventLog -LogName application -EntryType error | Group source,eventid | Sort count -Descending | select -First 10 | FT count,Name


CLS

Write-Host -NoNewLine "Host Name: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  CSName | ForEach{ $_.CSName }

  Write-Host ""

Write-Host -NoNewLine "Date: "$datetime
  
  Write-Host ""
  Write-Host ""

Write-Host -NoNewLine "OS Version: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  Caption | ForEach{ $_.Caption }

  Write-Host ""

Write-Host -NoNewLine "Install Date: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  InstallDate | ForEach{ $_.InstallDate }

  Write-Host ""

Write-Host -NoNewLine "Service Pack Version: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  ServicePackMajorVersion | ForEach{ $_.ServicePackMajorVersion }

  Write-Host ""

Write-Host -NoNewLine "OS Architecture: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  OSArchitecture | ForEach{ $_.OSArchitecture }

  Write-Host ""

Write-Host -NoNewLine "Boot Device: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  BootDevice | ForEach{ $_.BootDevice }

  Write-Host ""

Write-Host -NoNewLine "Build Number: "

  Get-CimInstance Win32_OperatingSystem | Select-Object  BuildNumber | ForEach{ $_.BuildNumber }

  Write-Host ""

Write-Host -NoNewLine "Chrome Version:  "$chrome_version.Trim(" `t")

Write-Host "Windows Experience Index Metrics:"

  GET-WMIOBJECT WIN32_WINSAT | SELECT-OBJECT CPUSCORE,D3DSCORE,DISKSCORE,GRAPHICSSCORE,MEMORYSCORE

  Write-Host ""

Write-Host "Installed Hotfixes:  "

 $update_info

 Write-Host ""

Write-Host "Group Policy Information:  "

 $gp_info

 Write-Host ""

Write-Host "Top 10 Application Errors: "

 $top_app_errors
 
 Write-Host ""

 Write-Host "Top 15 - Highest CPU Processes: "

 $top_CPU_processes
