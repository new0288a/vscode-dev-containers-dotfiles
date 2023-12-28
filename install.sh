#!/bin/bash

# install OpenVPN
sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://packages.openvpn.net/packages-repo.gpg | sudo tee /etc/apt/keyrings/openvpn.asc
DISTRO=$(lsb_release -c | awk '{print $2}')
echo "deb [signed-by=/etc/apt/keyrings/openvpn.asc] https://packages.openvpn.net/openvpn3/debian $DISTRO main" | sudo tee /etc/apt/sources.list.d/openvpn-packages.list
sudo apt-get update
sudo apt-get install -y openvpn3

# install the necessary packages
sudo apt-get install -y \
  apg \
  ntpdate \
  watch \
  vim \
  unzip \
  jq \
  curl \
  wget

cat <<'EOF' >> ~/.bashrc

alias createsecret="apg -c /dev/random -M NCSL -m 20 -x 25"
alias updatetime="sudo ntpdate tock.stdtime.gov.tw"
alias updatedevelop="git branch -D quincy-develop && git checkout -b quincy-develop"
alias go2vpn="openvpn3 session-start --config $(ls -b ~/*.ovpn)"
mkdir ~/tools
touch ~/tools/capitalize-title.py && echo 'import sys; print("-".join([ word.capitalize() for word in sys.argv[1].split( ) ]))' > ~/tools/capitalize-title.py && alias create-ticket-title='python ~/tools/capitalize-title.py'
echo -e '#!/bin/bash\n#bash ~/tools/find-string-in-vault-directory.sh ./inventories/prod-v2/group_vars/prod-v2/vault/ ~/.ansible/prod-v2/vault-password-file vault_emq_pull_api_keys_vitesse_secret\n#./inventories/prod-v2/group_vars/prod-v2/vault/pull/pull.yml\nfind $1 -type f -printf "%h/\"%f\" " | xargs -d " " -n1 -I "{}" sh -c "ansible-vault view "{}" --vault-password-file $2 | grep -q $3 && echo "{}' > ~/tools/find-string-in-vault-directory.sh
echo -e '#!/bin/bash\n#$ bash ~/tools/find-string-in-all-vault-directory.sh vault_emqcore_partner_keys_vitesse\n#./inventories/prod-v2/group_vars/prod-v2/vault/core/core.yml\nfor i in prod-v2 staging-v2 sandbox-v2 send-staging;do bash ~/tools/find-string-in-vault-directory.sh ./inventories/$i/group_vars/$i/vault/ ~/.ansible/$i/vault-password-file $1;done' > ~/tools/find-string-in-all-vault-directory.sh && alias find-in-ansible-vault='bash ~/find-string-in-all-vault-directory.sh'
echo -e '#!/bin/bash\n#$ bash ~/tools/compare-with-the-file-before-modification.sh inventories/prod-v2/group_vars/prod-v2/vault/core/core.yml\n#158a159\n#> vault_emqcore_partner_keys_vitesse: '\''xxxxxxxxxxxxxxxxxxxxxxxxxx'\''\nansible-vault view ~/git/emq-devops/ansible/$1 --vault-password-file ~/.ansible/prod-v2/vault-password-file > /tmp/exist_diff.txt\nansible-vault view ~/git2/emq-devops/ansible/$1 --vault-password-file ~/.ansible/prod-v2/vault-password-file > /tmp/orig_diff.txt\ndiff /tmp/exist_diff.txt /tmp/orig_diff.txt' > ~/tools/compare-with-the-file-before-modification.sh && alias compare-ansible-vault='bash ~/compare-with-the-file-before-modification.sh'

EOF