<#  
.SYNOPSIS  
	This script report on the Exchange Certificates expiration dates

.NOTES  
  Version      				: 0.1
  Rights Required			: Local admin
  Exchange Version			: 2010/2013 (tested on Exchange 2013 SP1 and Exchange 2010 SP3)
  Authors       			: Guy Bachar, Yoav Barzilay
  Last Update               : 12-August-2014
  Twitter/Blog	            : @GuyBachar, http://guybachar.us
  Twitter/Blog	            : @y0avb, http://y0av.me

.VERSION
  0.1 - Initial Version for connecting Internal Exchange Servers
	
#>

#region Script Information
Clear-Host
Write-Host "--------------------------------------------------------------" -BackgroundColor DarkGreen
Write-Host
Write-Host "Exchange Certificates Reporter" -ForegroundColor Green
Write-Host "Version: 0.1" -ForegroundColor Green
Write-Host 
Write-Host "Authors:" -ForegroundColor Green
Write-Host " Guy Bachar       | @GuyBachar        | http://guybachar.us" -ForegroundColor Green
Write-Host " Yoav Barzilay    | @y0avb            | http://y0av.me" -ForegroundColor Green
Write-host
Write-Host "--------------------------------------------------------------" -BackgroundColor DarkGreen
Write-Host
#endregion

#region Verifying Administrator Elevation
Write-Host Verifying User permissions... -ForegroundColor Yellow
Start-Sleep -Seconds 2
#Verify if the Script is running under Admin privileges
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
  [Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
  Write-Warning "You do not have Administrator rights to run this script.`nPlease re-run this script as an Administrator!"
  Write-Host 
  Break
}
#endregion

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
        . $env:ExchangeInstallPath\bin\RemoteExchange.ps1
        Connect-ExchangeServer –auto

$FileDate = "{0:yyyy_MM_dd-HH_mm}" -f (get-date)
$ServicesFileName = $env:TEMP+"\ExchangeCertsReport-"+$FileDate+".htm"
New-Item -ItemType file $ServicesFileName -Force


$ExchangeServers = Get-ExchangeServer | Where-Object {($_.AdminDisplayVersion -like "*15*") -OR ($_.AdminDisplayVersion -like "*14*")}
$ServersList = @()
$ServersList = $ExchangeServers | Select-Object Name


#### Building HTML File ####
Function writeHtmlHeader
{
param($fileName)
$date = ( get-date ).ToString('MM/dd/yyyy')
Add-Content $fileName "<html>"
Add-Content $fileName "<head>"
Add-Content $fileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $fileName '<title>Exchange Certificates Report</title>'
add-content $fileName '<STYLE TYPE="text/css">'
add-content $fileName  "<!--"
add-content $fileName  "td {"
add-content $fileName  "font-family: Segoe UI;"
add-content $fileName  "font-size: 11px;"
add-content $fileName  "border-top: 1px solid #1E90FF;"
add-content $fileName  "border-right: 1px solid #1E90FF;"
add-content $fileName  "border-bottom: 1px solid #1E90FF;"
add-content $fileName  "border-left: 1px solid #1E90FF;"
add-content $fileName  "padding-top: 0px;"
add-content $fileName  "padding-right: 0px;"
add-content $fileName  "padding-bottom: 0px;"
add-content $fileName  "padding-left: 0px;"
add-content $fileName  "}"
add-content $fileName  "body {"
add-content $fileName  "margin-left: 5px;"
add-content $fileName  "margin-top: 5px;"
add-content $fileName  "margin-right: 0px;"
add-content $fileName  "margin-bottom: 10px;"
add-content $fileName  ""
add-content $fileName  "table {"
add-content $fileName  "border: thin solid #000000;"
add-content $fileName  "}"
add-content $fileName  "-->"
add-content $fileName  "</style>"
add-content $fileName  "</head>"
add-content $fileName  "<body>"
add-content $fileName  "<table width='100%'>"
add-content $fileName  "<tr bgcolor='#336699 '>"
add-content $fileName  "<td colspan='7' height='25' align='center'>"
add-content $fileName  "<font face='Segoe UI' color='#FFFFFF' size='4'>Exchange Certificates Report - $date</font>"
add-content $fileName  "</td>"
add-content $fileName  "</tr>"
add-content $fileName  "</table>"
}

Function writeTableHeader
{
param($fileName)
Add-Content $fileName "<tr bgcolor=#0099CC>"
Add-Content $fileName "<td width='8%' align='center'><font color=#FFFFFF>Services</font></td>"
Add-Content $fileName "<td width='15%' align='center'><font color=#FFFFFF>Issuer</font></td>"
Add-Content $fileName "<td width='15%' align='center'><font color=#FFFFFF>Thumbprint</font></td>"
Add-Content $fileName "<td width='15%' align='center'><font color=#FFFFFF>Subject Name</font></td>"
Add-Content $fileName "<td width='8%' align='center'><font color=#FFFFFF>Issue Date</font></td>"
Add-Content $fileName "<td width='8%' align='center'><font color=#FFFFFF>Expiration Date</font></td>"
Add-Content $fileName "<td width='6%' align='center'><font color=#FFFFFF>Self Signed</font></td>"
Add-Content $fileName "<td width='15%' align='center'><font color=#FFFFFF>SAN</font></td>"
Add-Content $fileName "<td width='10%' align='center'><font color=#FFFFFF>Expires In</font></td>"
Add-Content $fileName "</tr>"
}

Function writeHtmlFooter
{
param($fileName)
Add-Content $fileName "</body>"
Add-Content $fileName "</html>"
}

Function writeServiceInfo
{
param($fileName,$FriendlyName,$Issuer,$Subject,$Thumbprint,$NotBefore,$NotAfter,$Services,$IsSelfSigned)
$TimeDiff = New-TimeSpan (Get-Date) $NotAfter
$DaysDiff = $TimeDiff.Days

 if ($NotAfter -gt (Get-date).AddDays(60))
 {
 Add-Content $fileName "<tr>"
 Add-Content $fileName "<td>$FriendlyName</td>"
 Add-Content $fileName "<td>$Issuer</td>"
 Add-Content $fileName "<td>$Subject</td>"
 Add-Content $fileName "<td>$Thumbprint</td>"
 Add-Content $fileName "<td align='center'>$NotBefore</td>"
 Add-Content $fileName "<td align='center'>$NotAfter</td>"
 Add-Content $fileName "<td align='center'>$Services</td>"
 Add-Content $fileName "<td align='center'>$IsSelfSigned</td>"
 Add-Content $fileName "<td bgcolor='#00FF00' align=center>$DaysDiff</td>"
 Add-Content $fileName "</tr>"
 }
 elseif ($NotAfter -lt (Get-date).AddDays(30))
 {
 Add-Content $fileName "<tr>"
 Add-Content $fileName "<td>$FriendlyName</td>"
 Add-Content $fileName "<td>$Issuer</td>"
 Add-Content $fileName "<td>$Subject</td>"
 Add-Content $fileName "<td>$Thumbprint</td>"
 Add-Content $fileName "<td align='center'>$NotBefore</td>"
 Add-Content $fileName "<td align='center'>$NotAfter</td>"
 Add-Content $fileName "<td align='center'>$Services</td>"
 Add-Content $fileName "<td align='center'>$IsSelfSigned</td>"
 Add-Content $fileName "<td bgcolor='#FF0000' align=center>$DaysDiff</td>"
 Add-Content $fileName "</tr>"
 }
 else
 {
 Add-Content $fileName "<tr>"
 Add-Content $fileName "<td>$FriendlyName</td>"
 Add-Content $fileName "<td>$Issuer</td>"
 Add-Content $fileName "<td>$Subject</td>"
 Add-Content $fileName "<td>$Thumbprint</td>"
 Add-Content $fileName "<td align='center'>$NotBefore</td>"
 Add-Content $fileName "<td align='center'>$NotAfter</td>"
 Add-Content $fileName "<td align='center'>$Services</td>"
 Add-Content $fileName "<td align='center'>$IsSelfSigned</td>"
 Add-Content $fileName "<td bgcolor='#FBB917' align=center>$DaysDiff</td>"
 Add-Content $fileName "</tr>"
 }
}

Function sendEmail
{ param($from,$to,$subject,$smtphost,$htmlFileName)
$body = Get-Content $htmlFileName
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
$msg.isBodyhtml = $true
$smtp.send($msg)

}

# Main Script
writeHtmlHeader $ServicesFileName


foreach ($Server in $ServersList)
{       
        $FQDN = $Server.name
        Add-Content $ServicesFileName "<table width='100%'><tbody>"
        Add-Content $ServicesFileName "<tr bgcolor='#0099CC'>"
        Add-Content $ServicesFileName "<td width='100%' align='center' colSpan=9><font face='segoe ui' color='#FFFFFF' size='2'>$FQDN</font></td>"
        Add-Content $ServicesFileName "</tr>"
        WriteTableHeader $ServicesFileName
        
        try
        {
            $Cert = Get-ExchangeCertificate -Server $FQDN | Where {$_.Services -ne "None"} -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Host
            Write-Host "Error Conencting to local server " $FQDN ", Please verify connectivity and permissions" -ForegroundColor Red
            Continue
        }
        
        foreach ($item in $cert)
        {
        writeServiceInfo $ServicesFileName $item.Services $item.Issuer $item.Thumbprint $item.Subject $item.NotBefore $item.NotAfter $item.IsSelfSigned $item.CertificateDomains
        }
        
        Add-Content $ServicesFileName "</table>"
}

writeHtmlFooter $ServicesFileName

### Configuring Email Parameters
#sendEmail from@domain.com to@domain.com "Services State Report - $Date" SMTPS_ERVER $ServicesFileName

#Closing HTML
writeHtmlFooter $ServicesFileName
Write-Host "`n`nThe File was generated at the following location: $ServicesFileName `n`nOpenning file..." -ForegroundColor Cyan
Invoke-Item $ServicesFileName