#Get all the eligible rbac roles for every user on Azure Tenant

Connect-AzAccount
$allresultsSUBS = @()
$allresultsSUBSa = @()

$allresourcecontainersSUB = Search-AzGraph -UseTenantScope  -First 1000 -Query "resourcecontainers | where type =~ 'microsoft.resources/subscriptions' "

foreach ($i in $allresourcecontainersSUB ) {
	
    $subid=  $i.id

    $result=Get-AzRoleEligibilitySchedule -Scope $subid

    $allresultsSUBS  += $result

    $resulta=Get-AzRoleAssignmentSchedule -Scope $subid

    $allresultsSUBSa  += $resulta
   
    write-output $i.name
}

$allresultsSUBS| Export-Csv -path 'C:\tmp3\test - Copy.csv' -Append
$allresultsSUBSa| Export-Csv -path 'C:\tmp3\test - Copy.csv' -Append