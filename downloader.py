import urllib.request
import json
import logging
import hashlib 
import sys, os

####################################################################
#
#   Downloads the Vagrant Win10 Edge Developer VM from Microsoft
#   (see here https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/ )
#   and checks if the download was successful and file hash matches
#   returns comparison via exit status. 0 for success, 255 else.
#   check with "$?"
#
####################################################################

API_PATH = "https://developer.microsoft.com/en-us/microsoft-edge/api/tools/vms/?id=20190311"
dlName = sys.argv[1]

logging.basicConfig(level=logging.INFO)

response = urllib.request.urlopen(API_PATH)
body = json.loads(response.read())

for winVersion in body:
    if "MSEdge on Win10" in winVersion["name"]:
        for provisioner in winVersion["software"]:
            if "Vagrant" in provisioner["name"]:
                vmURL = provisioner["files"][0]["url"]
                vmMD5 = provisioner["files"][0]["md5"]
                logging.info(f"URL for downloading Vagrant Image of Win10 Edge Developer edition: {vmURL}")
                break
logging.info("Starting download of approx. 7GB image. This might take a bit...")
# Download VM image
urllib.request.urlretrieve(vmURL, dlName)
logging.info(f"Download finished. FILE: {dlName}")

# compare precalc hash from microsoft with hash of downloaded file
logging.info(f"Checking hashes")

md5hash = urllib.request.urlopen(vmMD5).read()
logging.info(f"Remote hash value: {md5hash}")

logging.info(f"Calculating local hash value. This might take a bit...")
CHUNK = 4194304     # 4 MB chunks
md5 = hashlib.md5()
with open(dlName, 'rb') as f:
    while True:
        data = f.read(CHUNK)
        if not data:
            break
        md5.update(data)

localMD5 = md5.hexdigest()
logging.info(f"Local hash value: {localMD5}")

# compare hashes and return exit code
if md5hash.decode("utf-8").lower() == localMD5:
    logging.info(f"Hashes match! Download successful.")
    sys.exit(0)
else: 
    logging.error(f"Hashes do not match! Download failed.")
    sys.exit(-1)
