#obtain orphaned RGs

# Initialize an empty array to store the report
$report = @()

# Get all Azure subscriptions for a specific tenant
$AllSubscriptions = Get-AzSubscription 

foreach ($Subscription in $AllSubscriptions) {
    # Set the Azure context to the current subscription
    Set-AzContext -SubscriptionId $Subscription.Id

    # Retrieve all resource groups in the current subscription
    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {
        # Check if the resource group is empty (no resources)
        $resourcesInGroup = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName
        if ($resourcesInGroup.Count -eq 0) {
            # If the resource group is empty, add its name to the report array
            $report += $resourceGroup.ResourceGroupName
        }
    }
}

# Output the report (this will display the names of empty resource groups)
$report
