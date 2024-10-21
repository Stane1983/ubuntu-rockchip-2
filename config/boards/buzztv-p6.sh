# shellcheck shell=bash

export BOARD_NAME="BuzzTV PowerStation 6"
export BOARD_MAKER="BuzzTV"
export BOARD_SOC="Rockchip RK3588"
export BOARD_CPU="ARM Cortex A76 / A55"
export UBOOT_PACKAGE="u-boot-buzztv-rk3588"
export UBOOT_RULES_TARGET="buzztv-p6-rk3588"
export COMPATIBLE_SUITES=("jammy" "noble" "oracular")
export COMPATIBLE_FLAVORS=("server" "desktop")

function config_image_hook__buzztv-p6() {
    local rootfs="$1"
    local overlay="$2"
    local suite="$3"

    if [ "${suite}" == "jammy" ] || [ "${suite}" == "noble" ]; then
        # Install panfork
        chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa
        chroot "${rootfs}" apt-get update
        chroot "${rootfs}" apt-get -y install mali-g610-firmware
        chroot "${rootfs}" apt-get -y dist-upgrade

        # Install libmali blobs alongside panfork
        chroot "${rootfs}" apt-get -y install libmali-g610-x11

        # Install the rockchip camera engine
        chroot "${rootfs}" apt-get -y install camera-engine-rkaiq-rk3588

        # Fix WiFi not working when bluetooth enabled for the official RTL8852BE WiFi + BT card
        mkdir -p "${rootfs}"/usr/lib/scripts
        cp "${overlay}/usr/lib/systemd/system/rtl8852be-reload.service" "${rootfs}/usr/lib/systemd/system/rtl8852be-reload.service"
        cp "${overlay}/usr/lib/scripts/rtl8852be-reload.sh" "${rootfs}/usr/lib/scripts/rtl8852be-reload.sh"
        chroot "${rootfs}" systemctl enable rtl8852be-reload

    fi

    return 0
}
