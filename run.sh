# confige
ROOT="/home/min/firmadyne/"
BRAND="Netgear"
SQLIP="127.0.0.1"
FWROOT="/home/min/frameware/"
FWNAME="WNAP320 Firmware Version 2.0.3.zip"
PJNAME="1"
# download firmware first

#modify config 
sed -i "s#\#FIRMWARE_DIR=/home/vagrant/firmadyne/#FIRMWARE_DIR=${ROOT}#g" ${ROOT}firmadyne.config


#execute main command
if [ -f "${FWROOT}${FWNAME}" ]; then

# check old rootfs file 
if [ -f "${ROOT}images/1.tar.gz" ]; then
    cmd="y"
    read -p "Old rootfs is exist , remove it? [Y/n]" cmd
    if [ "${cmd,,}"=="y" ]; then
        rm ${ROOT}images/1.tar.gz
    fi
fi

# unzip FW's rootfs as an image at images 
python ${ROOT}sources/extractor/extractor.py -b ${BRAND} -sql ${SQLIP} -np -nk "${FWROOT}${FWNAME}" ${ROOT}images

cd ${ROOT}
#check target image Arch
bash ${ROOT}scripts/getArch.sh ${ROOT}images/1.tar.gz

#create DB table 
sudo python ${ROOT}scripts/tar2db.py -i ${PJNAME} -f ${ROOT}images/1.tar.gz

# make QEMU image
sudo ${ROOT}scripts/makeImage.sh ${PJNAME}

# build network infomation 
${ROOT}scripts/inferNetwork.sh ${PJNAME} |grep Interfaces | awk -F "'" '{print $4}'> network.log


#run QEMU
if [ -f "${ROOT}scratch/${PJNAME}/run.sh" ]; then
    sleep 30 && firefox -new-window "http://$(cat ${ROOT}network.log)" &
    ${ROOT}scratch/${PJNAME}/run.sh
else
    echo -e "[Error] No run.sh at ${ROOT}scratch/${PJNAME}"
fi
else
    echo "[Error] No file at ${FWROOT}${FWNAME} . "
fi

