#obtain unattached disks

# Initialize an empty array to store the report
$report = @()

# Get all Azure subscriptions for a specific tenant
$AllSubscriptions = Get-AzSubscription

foreach ($Subscription in $AllSubscriptions) {
    # Set the Azure context to the current subscription
    Set-AzContext -SubscriptionId $Subscription.Id

    # Retrieve unattached disks in the current subscription
    $disksList = Get-AzDisk | Where-Object { $_.DiskState -eq 'Unattached' }

    foreach ($disk in $disksList) {
        # Extract the disk name and add it to the report array
        $diskName = $disk.Name
        $report += $diskName
    }
}

# Output the report (this will display the names of unattached disks)
$report