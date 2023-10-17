# Get all subscriptions
$subscriptions = Get-AzSubscription

# Initialize an array to hold all Cosmos DB accounts
$allCosmosDBs = @()

# Iterate over each subscription
foreach ($subscription in $subscriptions) {
    # Set the subscription
    Select-AzSubscription -SubscriptionId $subscription.Id

    # Get all resource groups in the current subscription
    $resourceGroups = Get-AzResourceGroup

    # Iterate over each resource group
    foreach ($resourceGroup in $resourceGroups) {
        # Get the list of Cosmos DB accounts in the current resource group
        $cosmosDBs = Get-AzCosmosDBAccount -ResourceGroupName $resourceGroup.ResourceGroupName

        # Add the Cosmos DB accounts to the array
        $allCosmosDBs += $cosmosDBs
    }
}

# Export all Cosmos DB accounts to CSV
$allCosmosDBs | Export-Csv -Path .\AllCosmosDBs.csv -NoTypeInformation