## Introduction
This document explains how to allow linux containers running on kubernetes to access databases secured by kerberos authentication.
It requires to configure a GMSA account, use linux hosts domain joined, and an AD group to allow the linux hosts to retrieve the password of the GMSA account. The credentials-fetcher systemd service checks every 10 minutes if the kerberos ticket is expiring in the next hour and then it performs a ticket renewal.

There is an alternative using linux hosts without domain joined and a secret store to share the GMSA account password between the hosts. This approach has not been tested. Let us know if you choose this route and want to contribute sample documentation.

There is the practical option of replacing kerberos with username and password authentication.

## Active Directory configuration
Request the domain administrator to execute these tasks
* Create one GMSA account and one AD Group for the PrincipalsAllowedToRetrieveManagedPassword
* Add 1 Windows machine to the AD Group. It is needed to create a CredentialSpec file
* Add the Linux machines running the bridge containers to the AD Group

## On the Windows machine
1. Open elevated PowerShell window
```
Install-WindowsFeature RSAT-AD-PowerShell
Install-Module CredentialSpec
```
2. Open PowerShell window
```
$GMSA_NAME='gmsa_bridge'  # input the GMSA account name
Test-ADServiceAccount $GMSA_NAME
Get-ADServiceAccount $GMSA_NAME -Properties PrincipalsAllowedToRetrieveManagedPassword
# from the previous command output. GMSA distinguished name sample value is in format "CN=$GMSA_NAME,$GMSA_OU,DC=..."
$GMSA_DN='CN=gmsa_bridge,OU=DA Managed Service Accounts,OU=TSI DA,DC=tsi,DC=lan'
# many directories use default GMSA_OU='CN=Managed Service Accounts'
$GMSA_OU='OU=DA Managed Service Accounts,OU=TSI DA'
$GMSA_GROUP='gmsa_group_bridge'  # input the CN value from PrincipalsAllowedToRetrieveManagedPassword. Discard the OU,DC values
Get-ADGroup -Identity $GMSA_GROUP
Get-ADGroupMember -Identity $GMSA_GROUP
New-Item -Path "$env:ProgramData\Docker" -Name CredentialSpecs -ItemType Directory
New-CredentialSpec -AccountName $GMSA_NAME -FileName credspec.json
```
3. Copy the CredentialSpec file to the linux machines
```
scp "$env:ProgramData\Docker\CredentialSpecs\credspec.json" $env:USERNAME@${LINUX_HOSTNAME}:/tmp
```

## For each Linux machine
1. Open a root session
```
sudo -i
```
2. Move the CredentialSpec file to /root/credspec.json
```
mv /tmp/credspec.json /root/credspec.json
chown root:root /root/credspec.json
chmod 600 /root/credspec.json
```
3. Print the contents of resolv.conf file
```
cat /etc/resolv.conf 
```
4. If the search value in resolv.conf file contains your company domain then skip this step. Input a domain nameserver in ecs.config file
```
# list the domain nameservers
dig +noall +answer $(dnsdomainname) ns | awk '{ print substr($5, 1, length($5)-1) }'
# ask your domain administrator which domain nameserver should be used for your machines depending on the region/datacenter
cat << EOF > /etc/ecs/ecs.config
DOMAIN_CONTROLLER_GMSA="usw2itvwdc01.example.com"
EOF
```
5. Install credentials-fetcher service
```
# input the value collected in the Windows machine
export GMSA_OU='OU=DA Managed Service Accounts,OU=TSI DA'
./credfetcher.sh
```
6. Check the output is successful: journalctl -u credentials-fetcher | tail -50
```
Dec 03 16:53:08 990a25cb113d44a.example.com systemd[1]: Starting credentials-fetcher systemd service unit file....
Dec 03 16:53:08 990a25cb113d44a.example.com credentials-fetcherd[1691972]: krb_files_dir = /var/credentials-fetcher/krbdir
Dec 03 16:53:08 990a25cb113d44a.example.com credentials-fetcherd[1691972]: cred_file = /root/credspec.json (lease id: credspec)
Dec 03 16:53:08 990a25cb113d44a.example.com credentials-fetcherd[1691972]: logging_dir = /var/credentials-fetcher/logging
Dec 03 16:53:08 990a25cb113d44a.example.com credentials-fetcherd[1691972]: unix_socket_dir = /var/credentials-fetcher/socket
Dec 03 16:53:08 990a25cb113d44a.example.com credentials-fetcherd[1691972]: Credential file exists /root/credspec.json
Dec 03 16:53:08 990a25cb113d44a.example.com credentials-fetcherd[1691972]: Generating lease id credspec
Dec 03 16:53:10 990a25cb113d44a.example.com credentials-fetcherd[1691972]: Deleting existing credential file directory /var/credentials-fetcher/krbdir/credspec/gmsa_bridge
Dec 03 16:53:10 990a25cb113d44a.example.com credentials-fetcherd[1691972]: ldapsearch -H ldap://usw2itvwdc01.example.com -b 'CN=gmsa_bridge,OU=DA Managed Service Accounts,OU=TSI DA,DC=tsi,DC=lan' -s sub  "(objectClass=msDs-GroupManagedServiceAccount)"  msDS-ManagedPassword
Dec 03 16:53:10 990a25cb113d44a.example.com credentials-fetcherd[1691972]: ldapsearch -H ldap://usw2itvwdc01.example.com -b 'CN=gmsa_bridge,OU=DA Managed Service Accounts,OU=TSI DA,DC=tsi,DC=lan' -s sub  "(objectClass=msDs-GroupManagedServiceAccount)"  msDS-ManagedPassword
Dec 03 16:53:10 990a25cb113d44a.example.com ldapsearch[1692018]: GSSAPI client step 1
Dec 03 16:53:10 990a25cb113d44a.example.com ldapsearch[1692018]: GSSAPI client step 1
Dec 03 16:53:10 990a25cb113d44a.example.com credentials-fetcherd[1692018]: SASL/GSS-SPNEGO authentication started
Dec 03 16:53:12 990a25cb113d44a.example.com ldapsearch[1692018]: GSSAPI client step 1
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1692018]: SASL username: 990A25CB113D44A$@EXAMPLE.COM
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1692018]: SASL SSF: 256
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1692018]: SASL data security layer installed.
Dec 03 16:53:12 990a25cb113d44a.example.com ldapsearch[1692018]: DIGEST-MD5 common mech free
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1691972]: dotnet /usr/sbin/credentials_fetcher_utf16_private.exe | kinit  -c /var/credentials-fetcher/krbdir/credspec/gmsa_bridge/krb5cc -V 'gmsa_bridge$'@EXAMPLE.COM
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1692055]: Using specified cache: /var/credentials-fetcher/krbdir/credspec/gmsa_bridge/krb5cc
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1692055]: Using principal: gmsa_bridge$@EXAMPLE.COM
Dec 03 16:53:12 990a25cb113d44a.example.com credentials-fetcherd[1692055]: Password for gmsa_bridge$@EXAMPLE.COM:
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1692055]: Authenticated to Kerberos v5
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: kinit return value = 0
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: gMSA ticket is at /var/credentials-fetcher/krbdir/credspec/gmsa_bridge/krb5cc
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: gMSA ticket is at /var/credentials-fetcher/krbdir/credspec/gmsa_bridge/krb5cc
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: grpc pthread is at 0x55f578341930
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: krb refresh pthread is at 0x55f57833ff70
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: watchdog enabled with interval value = 5000000Thread 0: top of stack near 0x7f230aaa5bc8; argv_string=krb_ticket_refresh_thread
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: Thread 0: top of stack near 0x7f230b2a6c68; argv_string=grpc_thread
Dec 03 16:53:14 990a25cb113d44a.example.com credentials-fetcherd[1691972]: Server listening on unix:/var/credentials-fetcher/socket/credentials_fetcher.sock
Dec 03 16:53:15 990a25cb113d44a.example.com systemd[1]: Started credentials-fetcher systemd service unit file..
```
7. Wait 10 minutes for it to run the ticket renewal logic. It should check the ticket is expiring in more than 1 hour from now and skip the generation of a new ticket.
```
Dec 03 20:40:42 990a25cb113d44a.example.com credentials-fetcherd[2159878]: gMSA ticket is at /var/credentials-fetcher/krbdir/credspec/gmsa_bridge/krb5cc is not yet ready for renewal
```
8. It will renew the ticket when the ticket is less than 1 hour from expiration
```
Dec 04 03:40:02 990a25cb113d44a.example.com credentials-fetcherd[2159878]: gMSA ticket is at /var/credentials-fetcher/krbdir/credspec/gmsa_bridge/krb5cc is ready for renewal!
```
9. Share the absolute path of the krb5cc file to the Tableau Bridge as a Service Team

References:
* https://aws.amazon.com/blogs/opensource/aws-now-supports-credentials-fetcher-for-gmsa-on-amazon-linux-2023/
* https://github.com/aws/credentials-fetcher