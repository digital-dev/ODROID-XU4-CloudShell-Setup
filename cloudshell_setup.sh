#!/bin/bash
# Initial Setup
apt update
required=(git)
findmissing() {
        for i in "$@"; do
        checkinstalled=$(apt-cache policy "$i" | grep Installed | awk '{print $2}' | tr -d "()") > /dev/null
        if [ "${checkinstalled}" = "none" ]; then
        echo "$i " >> ./missing.deps
        fi
        done
}
getmissing() {
        missing=$(cat missing.deps)
        apt install ${missing[@]}
}
echo -e "Finding and installing missing dependencies.\n"
findmissing "${required[@]}" && getmissing
rm ./missing.deps
# Setup LCD Screen
echo -e '\033[9;0]' > /dev/tty1
echo -e 'spi_s3c64xx\nspidev\nfbtft_device' >> /etc/modules
echo "options fbtft_device name=hktft9340 busnum=1 rotate=270" > /etc/modprobe.d/odroid-cloudshell.conf
echo -e "# blacklist IO Board Sensors\nblacklist ioboard_bh1780\nblacklist ioboard_bmp180\nblacklist ioboard_keyled\n# LCD Touchscreen driver\nblacklist ads7846" > /etc/modprobe.d/blacklist-odroid.conf
sed -i -e 's/console=tty1/console=tty1 consoleblank=0/g' /media/boot/boot.ini
# Setup CPU Throttling
wget https://raw.githubusercontent.com/mad-ady/odroid-cpu-control/master/odroid-cpu-control && chmod +x odroid-cpu-control
./odroid-cpu-control -s -g "powersave" -m 200m -M 1.4G
# Persistent CPU Throttling
sed -i '13i\\n./usr/bin/odroid-cpu-control -s -g powersave -m 200m -M 1.4G' /etc/rc.local
mv odroid-cpu-control /usr/bin/odroid-cpu-control
# Setup CloudShell LCD Information Display
git clone https://github.com/digital-dev/cloudshell_lcd && chmod +x ./cloudshell_lcd/*.sh && ./cloudshell_lcd/build_deb.sh