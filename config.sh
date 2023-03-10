
export VAULT_ADDR=https://cduch-vault-01.hashidemos.io:8200/
export VAULT_IP="54.195.130.133"

# prepare system
sudo yum install unzip git rpm-build gcc opensc -y


# install and build xks-proxy
git clone https://github.com/aws-samples/aws-kms-xks-proxy.git
curl https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
cd aws-kms-xks-proxy
make
sudo yum install -y /home/centos/rpmbuild/RPMS/x86_64/xks-proxy-3.1.2-0.el7.x86_64.rpm

# install and configure libpkcs-11
sudo mkdir /etc/kmip/
scp ubuntu@$VAULT_ADDR:/tmp/*.pem /etc/kmip/
curl https://releases.hashicorp.com/vault-pkcs11-provider/0.1.3/vault-pkcs11-provider_0.1.3_linux-el7_amd64.zip -o /tmp/vault-pkcs11-provider.zip
unzip /tmp/vault-pkcs11-provider.zip -d /usr/local/lib

sudo cat <<EOT >> /tmp/vault-pkcs11.hcl
slot {
  server = "$VAULT_IP:5696"
  tls_cert_path = "/etc/kmip/cert.pem"
  ca_path = "/etc/kmip/ca.pem"
  scope = "my-service"
}
EOT
sudo mv /tmp/vault-pkcs11.hcl /etc/

sudo mkdir -p /var/local/xks-proxy/.secret/
sudo cp /tmp/settings.toml /var/local/xks-proxy/.secret/

# install and configure ngrok
cd /tmp
curl https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -o /tmp/ngrok-v3-stable-linux-arm64.tgz
tar -xzf /tmp/ngrok-v3-stable-linux-arm64.tgz
sudo mv ngrok /usr/local/bin/
ngrok config add-authtoken XXX
ngrok http 8000 &

