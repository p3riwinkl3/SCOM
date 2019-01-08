
###############################============================##################################
#### Name: SCOMMaintModeGroup.ps1
#### Author: Raleine-Ann Asis
#### Date: April 29, 2016
#### Version: 2
#### Updated: January 7, 2019
#### Changes:   Parameterized Email Recipients, Configured platform_eng_alerts to receive
####
#### Description:
        1) Script to set a SCOM Group in Maintenance Mode
        2) Mandatory Parameters are required by the script to execute properly

    Parameters
    -SCOMServer
        Mandatory parameter containing mgmt server name (Be sure to use FQDN).

    -GroupName
         Mandatory parameter containing display name of the target group (Be sure to enclose with ''). SCOM Group creation for maintenace mode is handled by
         SCOM SME of IT Monitoring Team
    -Length
         Mandatory parameter containing integer of desired duration in minutes.
    -Remark
        Optional parameter description of maintenance action (Free text. Be sure to enclose with '').
    -Reason
        Mandatory parameter containing reason. The acceptable values for this parameter are:

         -- PlannedOther
         -- UnplannedOther
         -- PlannedHardwareMaintenance
         -- UnplannedHardwareMaintenance
         -- PlannedHardwareInstallation
         -- UnplannedHardwareInstallation
         -- PlannedOperatingSystemReconfiguration
         -- UnplannedOperatingSystemReconfiguration
         -- PlannedApplicationMaintenance
         -- ApplicationInstallation
         -- ApplicationUnresponsive
         -- ApplicationUnstable
         -- SecurityIssue
         -- LossOfNetworkConnectivity
    -MailRecipient
        Optional parameter. Email/Slack Channel Recipient of the Notification. Default recipient is pe_maintmode_notif Slack Channel

SCRIPT USAGE

1) Running Script from Powershell Window
.\SCOMMaintModeGroup.ps1 -SCOMServer SCOMSERVERNAME.DOMAINNAME.COM -GroupName NAMEOFGROUP -Length ENTERMINUTESFORDURATION -Remark "COMMENTOFWHYSERVERISINMAINTMODE" -Reason '<REFERTOLISTBELOWFORSCOMACCEPTABLEMAINTMODEREASON>' -MailRecipient 'EmailAdd1','EmailAdd2',...

2) Syntax For Adding Script in Windows Task Scheduler (Actions >> Add Arguments)
    -FILE <LOCATION OF SCRIPT>\SCOMMaintModeGroup.ps1 -SCOMServer SCOMSERVERNAME.DOMAIN.NAME -GroupName NAMEOFGROUP -Length MINUTESOFDURATION -Remark "COMMENTOFWHYSERVERISINMAINTMODE" -Reason "PlannedOther" -MailRecipient Email1@xxxx.com, email2@xxxx.com

SCRIPT LOGGING
$filepath creates/updates MaintModeLog.txt which writes all execution result of the script;

