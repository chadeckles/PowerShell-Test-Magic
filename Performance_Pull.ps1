#
#
################################
#    Performance Pull Script   #
################################
#
######################
#    Instructions    #
######################
#
# 1. Within PowerShell, navigate to the directory where the Performance_Pull.ps1 script is located
# 2. Execute the script in PowerShell by entering the following command: .\Performance_Pull.ps1
# 3. Within the same directory, a file called Performance_Report.csv will be created
# 4. Open the file after the script has completed and load into your preferred data processing tool of choice. 
#
# ** NOTE: The script will take approximately 15-20 minutes to complete. ** 
#
# Author - Chad Eckles
# Release Date- 02 November 2021
#
$localhost = $env:computername
$Counters = @(
       "\PhysicalDisk(*)\% Idle Time",
       "\PhysicalDisk(_total)\Avg. Disk sec/Read",
       "\PhysicalDisk(_total)\Avg. Disk sec/Write",
       "\Memory\Pages/sec",
       "\Memory\Available MBytes",
       "\Processor(_total)\% Processor Time",
       "\Network Interface(*)\Bytes Total/sec",
       "\Network Interface(*)\Output Queue Length",
       "\LogicalDisk(C:)\% Free Space",
       "\LogicalDisk(*)\Avg. Disk Queue Length"
)
Get-Counter -Counter $Counters -MaxSamples 1000 | ForEach {
    $_.CounterSamples | ForEach {
        [pscustomobject]@{
            TimeStamp = Get-Date -Format "MM_dd_yyyy-HH:mm:ss"
            Path = $_.Path
            Value = $_.CookedValue
        }
    }
} | Export-Csv -Path Performance_Report.csv -NoTypeInformation
