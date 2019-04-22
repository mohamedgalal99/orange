#!/bin/bash
# Title          :modify_image.sh
# Description    :This script used to modify and enable public image in orange openstack, running on cascading node, 
# Author         :Mohamed Galal
# Example        :#bash modify_image.sh -m ${img_id}

[[ ${#@} -ne 2 ]] && { echo "[-] this script need image id"; exit 1; }
while [[ $1 ]]
do
    case $1 in
        -m | --imageId )
        image_id=$2
        shift 2
        ;;
        -h | --help )
        echo "-m --imageId \t\t Image id to berform modification on it"
        exit 0
        ;;
    esac
done
# image_id="$1"
imagetype="gold"
min_ram=2048
protected="true"
visibility="public"
image_type="gold"

echo "[*] Geting image avilability ..."
glance image-list | grep "${image_id}" &> /dev/null
[[ $? -eq 0 ]] && echo "[*] Find image with id: ${image_id}" || { echo "[*] Can't find image with id: ${image_id}"; exit 1; }

active_servers=$(cps template-instance-list --service glance glance | grep "active" | wc -l)
if [ ${active_servers} -gt 0 ]
then
    echo "[*] There are ${active_servers} connected to our glance"
else
    echo "[-] There isn't any active servers connected to glance"
    exit 1
fi
image_name="$(glance image-show ${image_id} | grep -E "\sname" | awk -F"|" '{print $3}' | sed 's/^\s//; s/\s*$//')"
echo "[*] Going to update image ${image_name} parameters"

glance image-update ${image_id} --min-ram ${min_ram} --protected ${protected}  --visibility ${visibility} --property __imagetype=${image_type}
echo "[+] Updating ram: ${min_ram}"
echo "[+] Making image protected"
echo "[+] Image visibilty is ${visibility}"
echo "[+] Image type is ${image_type}"
