#!/bin/bash
# Title          :disable_image.sh
# Description    :This script used to disable images in orange openstack, running on cascading node, 
# Author         :Mohamed Galal
# Example        :#bash disable_image.sh -d ${img_id}
[[ ${#@} -ne 2 ]] && { echo "[-] this script need image id"; exit 1; }
while [[ $1 ]]
do
    case $1 in
        -d | --image-disable )
        image_id=$2
        shift 2
        ;;
        -h | --help )
        echo "-d --imageId \t\t Image id to disable it"
        exit 0
        ;;
    esac
done

imagetype="private"
protected="false"
visibility="private"
image_type="private"

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

glance image-update ${image_id} --protected ${protected}  --visibility ${visibility} --property __imagetype=${image_type}
echo "[+] Updating ram: ${min_ram}"
echo "[+] Making image unprotected"
echo "[+] Image isn't visibilty"
echo "[+] Image type is ${image_type}"
