#Set Parameters
Param(
[Parameter(mandatory=$true)][String]$SCOMServer,
[Parameter(mandatory=$true)][String]$GroupName,
[Parameter(mandatory=$true)][Int]$Length, 
[Parameter(mandatory=$true)][String]$Remark,
[Parameter(mandatory=$true)][String]$Reason,
[Parameter(mandatory=$true)][String[]]$MailRecipient
)


$NotifRecipients = New-Object System.Collections.ArrayList

$NotifRecipients += "xxxxxxx@xxxxxx.slack.com"

if (!([string]::IsNullOrEmpty($MailRecipient))){
    $NotifRecipients += $MailRecipient
}

Write-Host $NotifRecipients

#Script Logging

$ScriptDir = Get-Location
$filepath = "$ScriptDir\MaintModeLog.txt"


$runID = Get-Random -Minimum 100000 -Maximum 999999

Function GenerateBody
{
    try
    {
        
        $a= Get-Content $filepath | Where-Object {$_ -like "*$runID*"}
        foreach ($i in $a)
        {
            $emailBody += "$i`r`n" 
        }
        
    }
    catch
    {
        Write-Log -message "$($Error[0].Exception.Message)"
    }
    
    $emailBody
}

function Write-Log{
    param(
        [parameter(mandatory=$true)][String[]]$message
        )

        $completeMessage = "$(Get-Date -Format g) | $runID | $message"
        Add-Content -Value $completeMessage -path $filepath

        

}

Function SendEmail
{
    $emailSubject = "SCOM Maintenance Execution for $ServerGroup"
    $emailBody = "Task completed. `nTask log may be reviewed at \\$env:COMPUTERNAME\$filepath `nRelevant lines from $filepath are below:`n`n"
    $emailBody += GenerateBody
    Send-MailMessage -SmtpServer 'SMTPServer.DOMAIN.COM' -From 'emailAdd@domain.com' -To $NotifRecipients -Subject $emailSubject -Body $emailBody
}

Try{
    Write-Log -message "Starting SCOM Maintenance Script at $(Get-Date)"  
    #Load OperationsManager Module
    Import-Module -Name OperationsManager
    Write-Log -message "Connecting to SCOM Server $SCOMServer"   

    #Connect to SCOM Management Group Server
    New-SCOMManagementGroupConnection -ComputerName $SCOMServer

    #Group of Servers to be put on Maintenance Mode
    $ServerGroup= Get-SCOMGroup | Where-Object {$_.DisplayName -like "$GroupName*"}
    
    $TimeMonOff = ((Get-Date).AddMinutes($Length))
   
    
    Write-Log -message "Setting $ServerGroup to Maintenance Mode..."
    #Set Group in Maint Mode Command
    Start-SCOMMaintenanceMode -Instance $ServerGroup -EndTime $TimeMonOff -Comment "$Remark" -Reason "$Reason" -Verbose -ErrorAction Stop
     
   
    Write-Log -message "Group $ServerGroup is on Maintenance Mode until $TimeMonOff"
    $logmessage = $ServerGroup.GetRelatedMonitoringObjects()|select-object 'DisplayName','Path'|Sort-Object PATH
    Write-Log -message  $logmessage

    

}
Catch [System.InvalidOperationException]
{
    Write-Log -message "The class instance  is already in maintenance mode. "
    Write-Log -message "Setting maintenance mode for group $ServerGroup has failed"

}
Catch {
    
    if ((Get-SCOMClassInstance -DisplayName $ServerGroup).InMaintenanceMode -eq $True){
        Write-Log -message "Error in Script Execution but $ServerGroup in Maintenance Mode until $TimeMonff "
    }
    else{
        Write-Log -message "$Error[4] Exception Found"
    }
}
Finally{

    Write-Log -message "Script Execution complete at $(Get-Date)"
    SendEmail
}
