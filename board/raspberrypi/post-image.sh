#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

for arg in "$@"
do
	case "${arg}" in
		--add-miniuart-bt-overlay)
		if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi (3B, 3B+, 3A+, 4B and Zero W) ttyAMA0 serial console
dtoverlay=miniuart-bt
__EOF__
		fi
		;;
		--aarch64)
		# Run a 64bits kernel (armv8)
		sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		if ! grep -qE '^arm_64bit=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_64bit=1
__EOF__
		fi
		;;
		--gpu_mem_256=*|--gpu_mem_512=*|--gpu_mem_1024=*)
		# Set GPU memory
		gpu_mem="${arg:2}"
		sed -e "/^${gpu_mem%=*}=/s,=.*,=${gpu_mem##*=}," -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
		--add-dpi-lcd-support)
            if ! grep -qE '^dtoverlay=dpi24' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
                echo "Adding LCD support to config.txt (fixes DPI interface)."
                cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# Enables 7 inch display over DPI
# dtoverlay=dpi24
# enable_dpi_lcd=1
# display_default_lcd=1
# dpi_group=2
# dpi_mode=87
# dpi_output_format=0x6f005
# hdmi_cvt 1024 600 60 6 0 0 0

# Set up DPI output for CS.Projector
dtoverlay=dpi24
framebuffer_width=1280
framebuffer_height=720
enable_dpi_lcd=1
display_default_lcd=1
dpi_group=2
dpi_mode=87
dpi_output_format=262679
dpi_timings=1280 0 16 8 16 720 0 45 45 25 0 0 0 60 0 74250000 3

__EOF__
            fi
		;;
		--add-rndis)
			if ! grep -qE '^dtoverlay=dwc2' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
				echo "Adding RNDIS"
				cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# Enables USB Gadget Interface
dtoverlay=dwc2,dr_mode=peripheral
dtoverlay=g_ether

__EOF__
			fi
        ;;
		--add-i2c)
			if ! grep -qE '^dtoverlay=i2c-dev' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
				echo "Adding I2C"
				cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# Enable i2c
dtoverlay=i2c-dev
dtoverlay=i2c1-bcm2708,sda1_pin=44,scl1_pin=45,pin_func=6

__EOF__
			fi
        ;;
	esac
done

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
