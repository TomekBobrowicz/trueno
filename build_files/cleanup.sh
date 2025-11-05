#!/usr/bin/env bash

HOME_URL="https://github.com/TomekBobrowicz/trueno"
echo "trueno" | tee "/etc/hostname"
# OS Release File (changed in order with upstream)
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Trueno \"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Trueno\"|
s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"bunta\"|
s|^VARIANT_ID=.*|VARIANT_ID=""|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:tomekbobrowicz:trueno\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="trueno"|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF