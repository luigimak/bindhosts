#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="/data/adb/modules/bindhosts"
PERSISTENT_DIR="/data/adb/bindhosts"
. $MODDIR/utils.sh
. $MODDIR/mode.sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs


target_hostsfile="$MODDIR/system/etc/hosts"
helper_mode=""

# reusable functions
mount_bind() { 
	mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts
}

overlay_routine() {
	devicename=overlay
	[ ${KSU} = true ] && devicename=KSU
	[ $APATCH = true ] && devicename=APatch
	target_hostsfile="/system/etc/hosts"
	[ ! -d $MODDIR/workdir ] && mkdir $MODDIR/workdir
	mount -t overlay -o lowerdir=/system/etc,upperdir=$MODDIR/system/etc,workdir=$MODDIR/workdir $devicename /system/etc
}

# operating modes
normal_mount() {
	echo "bindhosts: service.sh - mode normal_mount" >> /dev/kmsg
}

ksu_susfs_bind() { 
	${SUSFS_BIN} add_sus_kstat '/system/etc/hosts'
	mount_bind
	${SUSFS_BIN} update_sus_kstat '/system/etc/hosts'
	${SUSFS_BIN} add_try_umount $target_hostsfile 1
	${SUSFS_BIN} add_try_umount $target_hostsfile > /dev/null 2>&1 #legacy susfs
	echo "bindhosts: service.sh - mode ksu_susfs_bind" >> /dev/kmsg
}

bindhosts() { 
	mount_bind
	echo "bindhosts: service.sh - mode plain bindhosts" >> /dev/kmsg 
}

apatch_hfr() {
	target_hostsfile="/data/adb/hosts"
	[ ! -f $target_hostsfile ] && {
		cat /system/etc/hosts > $target_hostsfile
		printf "127.0.0.1 localhost\n::1 localhost\n" >> $target_hostsfile
		susfs_clone_perm $target_hostsfile /system/etc/hosts
		}
	helper_mode="| hosts_file_redirect 💉"
	echo "bindhosts: service.sh - mode apatch_hfr" >> /dev/kmsg
}

zn_hostsredirect() {
	target_hostsfile="/data/adb/hostsredirect/hosts"
	[ ! -f $target_hostsfile ] && {
		mkdir -p /data/adb/hostsredirect
		cat /system/etc/hosts > $target_hostsfile
		printf "127.0.0.1 localhost\n::1 localhost\n" >> $target_hostsfile
		susfs_clone_perm $target_hostsfile /system/etc/hosts
		}
	helper_mode="| ZN-hostsredirect 💉"
	echo "bindhosts: service.sh - mode zn_hostsredirect" >> /dev/kmsg
}

ksu_susfs_open_redirect() { 
	${SUSFS_BIN} add_open_redirect /system/etc/hosts "$MODDIR/system/etc/hosts"
	echo "bindhosts: service.sh - mode ksu_susfs_open_redirect" >> /dev/kmsg
}

ksu_source_mod() { 
	mount_bind
	echo "bindhosts: service.sh - mode ksu_source_mod" >> /dev/kmsg
}

generic_overlay() {
	overlay_routine
	echo "bindhosts: service.sh - mode generic_overlay" >> /dev/kmsg
}

ksu_susfs_overlay() {
	overlay_routine
	${SUSFS_BIN} add_sus_mount /system/etc
	${SUSFS_BIN} add_try_umount /system/etc 1
	${SUSFS_BIN} add_try_umount /system/etc > /dev/null 2>&1 #legacy susfs
	echo "bindhosts: service.sh - mode ksu_susfs_overlay" >> /dev/kmsg
}

##
# check opmodes and then do something
case $operating_mode in
	0) normal_mount ;;
	1) ksu_susfs_bind ;;
	2) bindhosts ;;
	3) apatch_hfr ;;
	4) zn_hostsredirect ;;
	5) ksu_susfs_open_redirect ;;
	6) ksu_source_mod ;;
	7) generic_overlay ;;
	8) ksu_susfs_overlay ;;
	*) normal_mount ;; # catch invalid modes
esac

##################

# cronjobs
# this is optional and opt-in
# I don't plan to extend this myself
# just check if crontabs exists
# if it does then we enable crond
[ -d $PERSISTENT_DIR/crontabs ] && {
	echo "bindhosts: service.sh - enabling crond" >> /dev/kmsg
	busybox crond -bc $PERSISTENT_DIR/crontabs -L /dev/null
	}

##################
until [ "$(getprop sys.boot_completed)" == "1" ]; do
    sleep 1
done

# set description conditionally
if [ -w $target_hostsfile ] ; then
	echo "bindhosts: service.sh - active" >> /dev/kmsg
	# writable hosts file aye? 
	# tell the user we are ready
	string="description=status: ready 🚀"
	# readout if bindhosts.sh did something
	grep -q "# bindhosts v" $target_hostsfile && string="description=status: active ✅ | blocked: $(grep -c "0.0.0.0" $target_hostsfile ) 🚫 | custom: $( grep -vEc "0.0.0.0| localhost|#" $target_hostsfile ) 🤖 $helper_mode"
	# read out if Adaway did something 
	grep -q "generated by AdAway" $target_hostsfile && string="description=status: active ✅ | 🛑 AdAway 🕊️"
else
	string="description=status: failed 😭 needs correction 💢"
	touch $MODDIR/disable
fi

# update description
sed -i "s/^description=.*/$string/g" $MODDIR/module.prop

# EOF
