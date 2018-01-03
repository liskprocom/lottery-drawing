#Script Var
$APIendpoint = "https://wallet.lisknode.io/api/"
$Importxmlpath = "c:/temp/distribution.xml"
$Exportresultcsvpath = "c:/temp/result.csv"
$prizenumber = 43
$StartBlockHeight = 4854600
$PrizeAddress = "13165448076348058064L"
$Prizes = 25,15,10,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
$LSKunit = 100000000


#Import distributed ticket list
$List = Import-Clixml $Importxmlpath

#count number of tickets issued
[int]$nbtickets = ($list | measure nbtickets -sum).sum

#get prize pool
$PrizePool = (Invoke-WebRequest ($APIendpoint + "accounts/getBalance?address=" + $PrizeAddress) | ConvertFrom-Json).balance/$LSKunit

#Drawing
$CurrentBlockheight = $StartBlockHeight
$Winners = @()
$cpt = 1
while ($CurrentBlockheight -lt $($StartBlockHeight + $prizenumber) )
{
[string]$randomid = (Invoke-WebRequest ($APIendpoint + "blocks?height=" + $CurrentBlockheight) | ConvertFrom-Json).blocks.id
if ($randomid)
	{
    $ticket = get-random -maximum $nbtickets -minimum 1 -setseed $randomid.SubString(0,9)
	$address = ($list | where-object tickets -eq $ticket).address
	if ($winners | where-object Address -eq $address)
	   {
	   $prizenumber++
	   }
	else
	   {
	   $currentwinner= @{
					     Rank = $cpt
				         Address = $address
					     Tickets = $ticket
					     BlockHeight = $CurrentBlockheight
					     BlockID = $randomid
					     PrizePercent = $Prizes[$cpt-1]
					     PrizeAmount = $PrizePool / 100 * $Prizes[$cpt-1] - 0.1
				        }
	   $ServiceObject = New-Object -TypeName PSObject -Property $currentwinner
	   $cpt++
       $Winners += $ServiceObject
	   }
	$CurrentBlockheight++
    Start-Sleep -s 3
	}
else
    {
	Start-Sleep -s 3
	}	

}

#Export CSV file for result web publishing
$Winners | Export-Csv $Exportresultcsvpath
