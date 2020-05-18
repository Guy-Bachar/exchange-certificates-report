Exchange Certificates Report
============================

            

The following script will query for every Exchange 2010/2013 server in the Environment and pull the following information on every Certificates which is assigned to an Exchange Service:


  *  Services Assigned 
  *  Issuer 
  *  Thumbprint 
  *  Subject Name 
  *  Issue Date 
  *  Expiration Date 
  *  Self Signed or Not 
  *  Subject Alternative Names 
  *  Expires In (Days) 
Script Features:

  *  The script pulls the information from every server by using Get-Exchange Server cmdlet

  *  The script support Exchange Certificates assignment awareness, meaning it only pull the certificates assigned to Exchange services

  *  The Script query every exchange server in the environment which is Exchange 2010/2013

  *  Certificates which are about to expire in the next 30 days will be colored in Red, Certificates which will expire in the next 60 days will be colored in orange

  *  The script can also be configured to send email as well as being a scheduled task in order to be notified on a weekly/monthly basis.

The current caveats in this version of the script

  *  Does not pull EDGE Certificates information 
  *  Does not pull Exchange 2007 Certificates Information 
Version Control:

  *  0.1 - August-13-2014 - Initial Version for connecting Internal Exchange Servers

Output:

![Image](https://github.com/Guy-Bachar/exchange-certificates-report/raw/master/Examples%231.png)


 


![Image](https://github.com/Guy-Bachar/exchange-certificates-report/raw/master/Examples%232.png)


 


 

 

        
    
