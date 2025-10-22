#!/usr/bin/env bash
set -ouex pipefail


HOME_URL="https://github.com/TomekBobrowicz/trueno"
echo "fedora" | tee "/etc/hostname"
# OS Release File (changed in order with upstream)
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Bazzite Niri \"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Bazzite Niri\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"trueno\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"n.a.\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="bazzite"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF