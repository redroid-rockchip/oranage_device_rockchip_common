#! /vendor/bin/sh

#########################################
### init.insmod.cfg format:           ###
### --------------------------------- ###
### [insmod|setprop] [path|prop name] ###
### ...                               ###
#########################################

if [[ -e "/vendor/etc/init.insmod_charger.cfg" && "$(getprop ro.boot.mode)" == "charger" ]]; then
  cfg_file="/vendor/etc/init.insmod_charger.cfg"
else
  cfg_file="/vendor/etc/init.insmod.cfg"
fi

if [ -f $cfg_file ]; then
  while IFS=" " read -r action name
  do
    case $action in
      "insmod")
        if [ -f $name ]; then
          insmod $name
        fi
        ;;
      "setprop") setprop $name 1 ;;
    esac
  done < $cfg_file
fi

/system/bin/lsusb |grep 0bda:1a2b && /vendor/bin/usb_modeswitch -K -v 0bda -p 1a2b
sleep 0.5
/system/bin/lsusb |grep 0bda: && /system/bin/insmod /vendor/lib/modules/rtk_btusb.ko

# set property even if there is no insmod config
# as property value "1" is expected in early-boot trigger
setprop vendor.all.modules.ready 1
