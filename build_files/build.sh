#!/bin/bash

set -ouex pipefail
cp -avf /ctx/files/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo

dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

systemctl enable systemd-timesyncd
systemctl enable systemd-resolved.service

dnf copr -y enable alternateved/eza 

dnf -y copr enable yalter/niri
dnf -y copr disable yalter/niri
dnf -y --enablerepo copr:copr.fedorainfracloud.org:yalter:niri install niri
rm -rf /usr/share/doc/niri

dnf -y copr enable scottames/ghostty
dnf -y copr disable scottames/ghostty
dnf -y --enablerepo copr:copr.fedorainfracloud.org:scottames:ghostty install ghostty

dnf -y copr enable errornointernet/quickshell
dnf -y copr disable errornointernet/quickshell
#dnf -y --enablerepo copr:copr.fedorainfracloud.org:errornointernet:quickshell install quickshell

dnf -y copr enable solopasha/hyprland
dnf -y copr disable solopasha/hyprland
dnf -y --enablerepo copr:copr.fedorainfracloud.org:solopasha:hyprland install hyprland hyprpaper hypridle hyprpicker nwg-look
dnf -y copr enable avengemedia/danklinux
dnf -y copr disable avengemedia/danklinux
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux install quickshell-git cliphist material-symbols-fonts matugen dgop

dnf -y copr enable avengemedia/dms-git
dnf -y copr disable avengemedia/dms-git
dnf -y --enablerepo copr:copr.fedorainfracloud.org:avengemedia:dms-git install dms

dnf -y copr enable heus-sueh/packages
dnf -y copr disable heus-sueh/packages

dnf -y copr enable brycensranch/gpu-screen-recorder-git
dnf -y --enablerepo copr:copr.fedorainfracloud.org:brycensranch:gpu-screen-recorder-git install gpu-screen-recorder-ui
dnf -y copr disable brycensranch/gpu-screen-recorder-git

dnf -y install \
    uxplay \
    udiskie \
    xdg-desktop-portal-gnome \
    swaybg \
    swayidle \
    swaylock \
    brightnessctl \
    gnome-keyring \
    nautilus \
    wlsunset \
    xdg-user-dirs \
    xwayland-satellite \
    cava \
    fuzzel \
    qt6ct \
    wl-clipboard \
    qt6-qtmultimedia \
    eza \
    bat \
    btop \
    zoxide \
    google-noto-fonts-all \
    jetbrains-mono-fonts-all \
    adw-gtk3-theme \
    google-chrome-stable \
    discord 
       


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

add_wants_niri() {
    sed -i "s/\[Unit\]/\[Unit\]\nWants=$1/" "/usr/lib/systemd/user/niri.service"
}
add_wants_niri plasma-polkit-agent.service
add_wants_niri swayidle.service
add_wants_niri udiskie.service
add_wants_niri xwayland-satellite.service
cat /usr/lib/systemd/user/niri.service

dnf install -y --setopt=install_weak_deps=False \
    polkit-kde

sed -i "s/After=.*/After=graphical-session.target/" /usr/lib/systemd/user/plasma-polkit-agent.service


dnf -y install --enablerepo=fedora-multimedia \
    ffmpeg libavcodec @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl ffmpegthumbnailer


sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf

systemctl enable --global plasma-polkit-agent.service
systemctl enable --global xwayland-satellite.service
systemctl preset --global plasma-polkit-agent
systemctl preset --global xwayland-satellite

dnf -y remove xwaylandvideobridge

mkdir -p "/usr/share/fonts/Maple Mono"

MAPLE_TMPDIR="$(mktemp -d)"
trap 'rm -rf "${MAPLE_TMPDIR}"' EXIT

LATEST_RELEASE_FONT="$(curl "https://api.github.com/repos/subframe7536/maple-font/releases/latest" | jq '.assets[] | select(.name == "MapleMono-Variable.zip") | .browser_download_url' -rc)"
curl -fSsLo "${MAPLE_TMPDIR}/maple.zip" "${LATEST_RELEASE_FONT}"
unzip "${MAPLE_TMPDIR}/maple.zip" -d "/usr/share/fonts/Maple Mono"

## DMS
curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" -o /usr/share/fonts/MaterialSymbolsRounded.ttf
curl -L "https://github.com/rsms/inter/raw/refs/tags/v4.1/docs/font-files/InterVariable.ttf" -o /usr/share/fonts/InterVariable.ttf
curl -L "https://github.com/tonsky/FiraCode/releases/latest/download/FiraCode-Regular.ttf" -o /usr/share/fonts/FiraCode-Regular.ttf

install -d /etc/niri/
cp -f /etc/skel/.config/niri/config.kdl /etc/niri/config.kdl
file /etc/niri/config.kdl | grep -F -e "empty" -v
stat /etc/niri/config.kdl

install -d /etc/ghostty/
cp -f /etc/skel/.config/ghostty/config /etc/ghostty/config
file /etc/ghostty/config | grep -F -e "empty" -v
stat /etc/ghostty/config

