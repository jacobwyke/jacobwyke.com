#!/bin/bash

sudo /usr/bin/apt install unzip
cd /tmp
wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
unzip terraform_0.11.1_linux_amd64.zip
sudo mv terraform /usr/local/bin/
