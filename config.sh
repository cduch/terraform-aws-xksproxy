
sudo yum install unzip git rpm-build gcc -y

curl https://releases.hashicorp.com/vault-pkcs11-provider/0.1.3/vault-pkcs11-provider_0.1.3_linux-el7_amd64.zip -o /tmp/vault-pkcs11-provider.zip

unzip /tmp/vault-pkcs11-provider.zip -d /usr/local/lib

git clone https://github.com/aws-samples/aws-kms-xks-proxy.git

curl https://sh.rustup.rs -sSf | sh

source "$HOME/.cargo/env"
cd aws-kms-xks-proxy
make
