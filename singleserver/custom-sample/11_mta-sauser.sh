#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Enable this sausers if you are directly facing Internet.
#
# !!! Do not enable if there is already an ESG in front of you.
#

if [ ! -f /opt/zimbra/data/spamassassin/localrules/sauser.cf ]; then
  cat <<EOT > /opt/zimbra/data/spamassassin/localrules/sauser.cf
# My sauser.cf rules

# Our partners
whitelist_auth *@synacor.com

# Internal redirected mail is trusted
score ALL_TRUSTED              -9.0

# Adjust RDNS
score RDNS_NONE                 3.0

# Adjust SPF
ifplugin Mail::SpamAssassin::Plugin::SPF
score SPF_NONE                  3.0
score SPF_FAIL                  9.0
score SPF_SOFTFAIL              9.0
score SPF_HELO_NONE             3.0
score SPF_HELO_FAIL             9.0
score SPF_HELO_SOFTFAIL         9.0
endif # Mail::SpamAssassin::Plugin::SPF

# Adjust DMARC
ifplugin Mail::SpamAssassin::Plugin::AskDNS
score DMARC_FAIL_REJECT         9.0
score DMARC_FAIL_QUAR           6.0
score DMARC_FAIL_NONE           1.2
endif

# Misc SA adjustments
score RCVD_IN_BL_SPAMCOP_NET    6.0
score FREEMAIL_FORGED_REPLYTO   3.0

EOT

fi
