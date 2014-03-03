#!/bin/bash
# Update everything first.
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
# To get basic settings in the terminal.
sudo apt install tmux vim fonts-noto -y
# To get npm and graphite.
sudo apt install npm -y
sudo npm install -g n
sudo n lts
sudo n prune
sudo npm i -g @withgraphite/graphite-cli

# To setup ssh into the device.
sudo apt install keychain openssh-server
