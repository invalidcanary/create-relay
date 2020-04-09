### Randall Vogsland, Presidio
### properly creates a relay connector to allow for anonymous relay to external recipients, relaxes common throttles
### Parameters:  Server, Name for the connector to be created, fqdn to assign

### Example: .\create-relay.ps1 -server msp-mbx01 -connectorName "External Relay" -fqdn relay.invalidcanary.com

### To copy existing IP lists from another connector, specify the $sourceConn
### Example:  .\create-relay.ps1 -server msp-mbx01 -connectorName "External Relay" -fqdn relay.invalidcanary.com -sourceConn "msp-mbx02\External Relay"




Param(
[Parameter(Mandatory=$True,Position=1)]
[string]$server,
[Parameter(Mandatory=$True)]
[string]$connectorName,
[Parameter(Mandatory=$True)]
[string]$fqdn,
[Parameter(Mandatory=$False)]
[string]$sourceConn
)


$connector = $server + "\" + $connectorName


New-ReceiveConnector -Name $connectorName -Server $server -Usage Custom -Bindings 0.0.0.0:25 -RemoteIPRanges 9.9.9.9 -TransportRole FrontEndTransport -fqdn $fqdn 

Get-ReceiveConnector "$connector" | add-adpermission -User "NT AUTHORITY\Anonymous Logon" -ExtendedRights MS-Exch-SMTP-Accept-Any-Recipient

Set-ReceiveConnector -identity "$connector" -PermissionGroups AnonymousUsers
Set-ReceiveConnector -identity "$connector" -TarpitInterval 00:00:00
Set-ReceiveConnector -identity "$connector" -ConnectionTimeout 00:30:00
Set-ReceiveConnector -identity "$connector" -ConnectionInactivityTimeout 00:20:00
Set-ReceiveConnector -identity "$connector" -MaxAcknowledgementDelay 00:00:00
Set-ReceiveConnector -identity "$connector" -MaxInboundConnection 10000
Set-ReceiveConnector -identity "$connector" -MaxInboundConnectionPercentagePerSource 100
Set-ReceiveConnector -identity "$connector" -MaxInboundConnectionPerSource unlimited

if ($sourceConn -ne "") {

$conn = get-receiveConnector $sourceConn
$remoteIPs = $conn.RemoteIPRanges

Set-ReceiveConnector -identity "$connector" -RemoteIPRanges $remoteIPs
}
