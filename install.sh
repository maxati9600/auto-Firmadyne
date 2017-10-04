#! /bin/bash
echo -e "\n===============================\nAuto Firmadyne Install script\n===============================\n"


#install dependencies
sudo apt-get install busybox-static fakeroot git kpartx netcat-openbsd nmap python-psycopg2 python3-psycopg2 snmp uml-utilities util-linux vlan -y

#clone firmadyne from github
cd ~
git clone --recursive https://github.com/firmadyne/firmadyne.git

#install binwalk
cd ~
git clone https://github.com/devttys0/binwalk.git
cd binwalk
sudo ./deps.sh --yes
sudo python ./setup.py install
pip install --upgrade pip
sudo -H pip install git+https://github.com/ahupp/python-magic
sudo -H pip install git+https://github.com/sviehb/jefferson

#install Database
cd ~
sudo apt-get install postgresql -y
sudo -u postgres createuser -P firmadyne
sudo -u postgres createdb -O firmadyne firmware
sudo -u postgres psql -d firmware < ./firmadyne/database/schema

#download pre-build kernel
cd ~/firmadyne
./download.sh


#install qemu 


sudo apt-get install qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils -y

echo -e "\n===============================\n firmadyne install is finish \n===============================\n"

