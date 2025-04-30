#!/bin/bash
<<<<<<< HEAD
# set -x Enable debugging
set -x
=======
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex
>>>>>>> 41d753a (Separate out zimbraimage and deployment)

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

<<<<<<< HEAD
# Enable this sausers if you are directly facing Internet.
#
# !!! Do not enable if there is already an ESG in front of you.
#

=======
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
if [ ! -f /opt/zimbra/data/spamassassin/localrules/sauser.cf ]; then
  cat <<EOT > /opt/zimbra/data/spamassassin/localrules/sauser.cf
# My sauser.cf rules

# Our partners
whitelist_auth *@synacor.com

<<<<<<< HEAD
# Internal redirected mail is trusted
score ALL_TRUSTED              -9.0

# Adjust RDNS
score RDNS_NONE                 3.0

# Adjust SPF
=======
# Enforcing SPF - override existing score
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
ifplugin Mail::SpamAssassin::Plugin::SPF
score SPF_NONE                  3.0
score SPF_FAIL                  9.0
score SPF_SOFTFAIL              9.0
score SPF_HELO_NONE             3.0
score SPF_HELO_FAIL             9.0
score SPF_HELO_SOFTFAIL         9.0
endif # Mail::SpamAssassin::Plugin::SPF

<<<<<<< HEAD
# Adjust DMARC
ifplugin Mail::SpamAssassin::Plugin::AskDNS
score DMARC_FAIL_REJECT         9.0
score DMARC_FAIL_QUAR           6.0
score DMARC_FAIL_NONE           1.2
endif
=======
# Enforce RDNS
score RDNS_NONE                 6.0
>>>>>>> 41d753a (Separate out zimbraimage and deployment)

# Misc SA adjustments
score RCVD_IN_BL_SPAMCOP_NET    6.0
score FREEMAIL_FORGED_REPLYTO   3.0

<<<<<<< HEAD
=======
# Internal redirected mail is trusted
score ALL_TRUSTED              -9.0

# Override DMARC scores

ifplugin Mail::SpamAssassin::Plugin::AskDNS

  askdns   __DMARC_POLICY_NONE   _dmarc._AUTHORDOMAIN_ TXT /^v\s*=DMARC1 (?=\s*;) .* ;\s* p\s*=\s*none       \s*(?:;|\z)/x
  askdns   __DMARC_POLICY_QUAR   _dmarc._AUTHORDOMAIN_ TXT /^v\s*=DMARC1 (?=\s*;) .* ;\s* p\s*=\s*quarantine \s*(?:;|\z)/x
  askdns   __DMARC_POLICY_REJECT _dmarc._AUTHORDOMAIN_ TXT /^v\s*=DMARC1 (?=\s*;) .* ;\s* p\s*=\s*reject     \s*(?:;|\z)/x

  meta     DMARC_FAIL_REJECT !(DKIM_VALID_AU || SPF_PASS) && __DMARC_POLICY_REJECT
  describe DMARC_FAIL_REJECT DMARC validation failed and policy is to reject
  score    DMARC_FAIL_REJECT 9.0

  meta     DMARC_FAIL_QUAR   !(DKIM_VALID_AU || SPF_PASS) && __DMARC_POLICY_QUAR
  describe DMARC_FAIL_QUAR   DMARC validation failed and policy is quarantine
  score    DMARC_FAIL_QUAR   6.0

  meta     DMARC_FAIL_NONE   !(DKIM_VALID_AU || SPF_PASS) && __DMARC_POLICY_NONE
  describe DMARC_FAIL_NONE   DMARC validation failed and policy is none
  score    DMARC_FAIL_NONE   1.2

  meta     DMARC_PASS_REJECT DKIM_VALID_AU && SPF_PASS && __DMARC_POLICY_REJECT
  describe DMARC_PASS_REJECT DMARC validation passed and policy is to reject
  tflags   DMARC_PASS_REJECT nice
  score    DMARC_PASS_REJECT -1.2

  meta     DMARC_PASS_QUAR   DKIM_VALID_AU && SPF_PASS && __DMARC_POLICY_QUAR
  describe DMARC_PASS_QUAR   DMARC validation passed and policy is quarantine
  tflags   DMARC_PASS_QUAR   nice
  score    DMARC_PASS_QUAR   -1.0

  meta     DMARC_PASS_NONE   DKIM_VALID_AU && SPF_PASS && __DMARC_POLICY_NONE
  describe DMARC_PASS_NONE   DMARC validation passed and policy is none
  tflags   DMARC_PASS_NONE   nice
  score    DMARC_PASS_NONE   -0.6

endif
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
EOT

fi
