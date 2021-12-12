<#-----------------------------------------------------------------------------
 Endpoint Validation Tests

 Powershell Testing with Pester

 Author - Chad Eckles

-----------------------------------------------------------------------------#>


## ServiceTests.Tests.ps1
Describe 'Status of security agents on localhost' {
    
    $status = (Get-Service -Name 'WinDefend').Status
        it 'Windows Defender should be running' {
        $status | should -Be 'Running'
    }
    
    
    $status = (Get-Service -Name 'QualysAgent').Status
        it 'Qualys Cloud Agent should be running' {
        $status | should -Be 'Running'
    }
    

    $status = (Get-Service -Name 'CcmExec').Status
        it 'Microsoft SMS Agent should be running' {
        $status | should -Be 'Running'
    }

    $status = (Get-Service -Name 'SplunkForwarder').Status
        it 'Splunk should be running' {
        $status | should -Be 'Running'
    }

}
    
Describe 'Available Software Checks' {
    context 'Standard installation location installs' {
        $installsList = [collections.generic.list[psobject]]::new()

        $installs64 =  Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty |
            Select-Object DisplayName, DisplayVersion

        $installs32 =  Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty |
            Select-Object DisplayName, DisplayVersion

        $installs64 | ForEach-Object {$installsList.Add($_)}
        $installs32 | ForEach-Object {$installsList.Add($_)}

        it 'should have Google Chrome version 75 or higher installed' {
             ($installsList | Where-Object -Property DisplayName -eq 'Google Chrome').DisplayVersion | Should -BeGreaterOrEqual "75*"
        }
        it 'should have Splunk Universal Forwarder 7.0 or higher installed' {
             ($installsList | Where-Object -Property DisplayName -eq 'UniversalForwarder').DisplayVersion | Should -BeGreaterOrEqual "7*"
        }

}




Describe "Check workstation" {
    Context "Check service status"{
        It "VSS service status - stopped" {
            (Get-Service -Name VSS).Status| Should Be Stopped
        }
 
        It "Firewall service status - running" {
            (Get-Service -Name MpsSvc).Status| Should Be Running
        }
    }
     
    Context "Check free disk space"{
        It "C drive free space greater than 20 GB" {
            (Get-WmiObject win32_logicaldisk -Filter "Drivetype=3" | Where-Object {$_.DeviceID -eq "C:"}).FreeSpace/1GB | Should BeGreaterThan 20
        }
 
    }
     
    Context "Check RAM usage"{
        It "Free RAM greater than 4GB" {
            (Get-Ciminstance Win32_OperatingSystem | Select-Object FreePhysicalMemory).FreePhysicalMemory/1mb | Should BeGreaterThan 4
        }
 
    }
    
}



