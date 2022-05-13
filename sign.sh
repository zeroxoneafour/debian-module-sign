#!/bin/bash

RETURNDIR="$(pwd)"
cd /var/lib/shim-signed/mok

VERSION="$(uname -r)"
SHORT_VERSION="$(uname -r | cut -d . -f 1-2)"
MODULES_DIR=/lib/modules/$VERSION
KBUILD_DIR=/usr/lib/linux-kbuild-$SHORT_VERSION

sudo sbsign --key MOK.priv --cert MOK.pem "/boot/vmlinuz-$VERSION" --output "/boot/vmlinuz-$VERSION.tmp"
sudo mv "/boot/vmlinuz-$VERSION.tmp" "/boot/vmlinuz-$VERSION"


echo -n "Passphrase for the private key: "
read -s KBUILD_SIGN_PIN
export KBUILD_SIGN_PIN

if [ -f "$MODULES_DIR/misc/vboxdrv.ko" ]; then
	cd "$MODULES_DIR/misc"
	sudo --preserve-env=KBUILD_SIGN_PIN "$KBUILD_DIR"/scripts/sign-file sha256 /var/lib/shim-signed/mok/MOK.priv /var/lib/shim-signed/mok/MOK.der vboxdrv.ko
fi

if [ -d "$MODULES_DIR/updates/dkms" ]; then
	cd "$MODULES_DIR/updates/dkms"
	for i in *.ko ; do sudo --preserve-env=KBUILD_SIGN_PIN "$KBUILD_DIR"/scripts/sign-file sha256 /var/lib/shim-signed/mok/MOK.priv /var/lib/shim-signed/mok/MOK.der "$i" ; done
fi

cd $RETURNDIR
