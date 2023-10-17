# Import the CSV file
$data = Import-Csv -Path '.\AllCosmosDBs.csv'

# Loop through each row in the CSV file
foreach ($row in $data) {
    #split the id column
    $splitedData = $row.Id -split "/"

    #get the subscription id
    $subId = $splitedData[2]

    # Set the subscription
    Select-AzSubscription -SubscriptionId $subId

    # Assign the 'id' column to variables
    $id = $row.Id

    Write-Host "Changing Backup Policy Type for Cosmos DB with ID: $id"

    #Update cosmos DB backup policy type from periodic to continuous
    Update-AzCosmosDBAccount -ResourceId $id -BackupPolicyType "Continuous" -ContinuousTier "Continuous7Days"
}