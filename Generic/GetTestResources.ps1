#Get all resources that include the word "test"

# Get the list of all subscriptions
$subscriptions = Get-AzSubscription

# Initialize an empty array to hold the resources
$resources = @()

# Loop through each subscription
foreach ($subscription in $subscriptions) {
    # Set the subscription context
    Set-AzContext -Subscription $subscription.Id

    # Get all resources in the subscription
    $allResources = Get-AzResource

    # Filter the resources to get only those that contain 'test' in the name
    $testResources = $allResources | Where-Object { $_.Name -like '*test*' } | Select-Object Name, ResourceGroupName, ResourceType, @{Name='SubscriptionId'; Expression={$subscription.Id}}

    # Add the test resources to the array
    $resources += $testResources
}

# Output the resources to a CSV file
$resources | Export-Csv -Path 'AllTest.csv' -NoTypeInformation