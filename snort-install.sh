#!/bin/bash
#https://kifarunix.com/install-and-configure-snort-3-on-ubuntu-22-04/?expand_article=1
# Exit script on any error
set -e

# Update system package cache and upgrade system packages
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install required build tools and dependencies
echo "Installing build tools and dependencies..."
sudo apt install build-essential libpcap-dev libpcre3-dev \
libnet1-dev zlib1g-dev luajit hwloc libdnet-dev \
libdumbnet-dev bison flex liblzma-dev openssl libssl-dev \
pkg-config libhwloc-dev cmake cpputest libsqlite3-dev uuid-dev \
libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev \
libluajit-5.1-dev libunwind-dev libfl-dev -y

# Prepare directory for source files
echo "Setting up directories for source files..."
mkdir -p snort-source-files
cd snort-source-files

# Check if DAQ library is already downloaded
if [ ! -d "libdaq" ]; then
    echo "Downloading and building DAQ library..."
    git clone https://github.com/snort3/libdaq.git
    cd libdaq
    ./bootstrap
    ./configure
    make
    sudo make install
    cd ..
else
    echo "DAQ library already downloaded."
fi

# Check if Tcmalloc is already downloaded
if [ ! -f "gperftools-2.9.1.tar.gz" ]; then
    echo "Downloading and installing Tcmalloc..."
    wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
    tar xzf gperftools-2.9.1.tar.gz
    cd gperftools-2.9.1
    ./configure
    make
    sudo make install
    cd ..
else
    echo "Tcmalloc already downloaded."
fi

# Download and install Snort 3
if [ ! -f "3.1.28.0.tar.gz" ]; then
    echo "Downloading Snort 3..."
    wget https://github.com/snort3/snort3/archive/refs/tags/3.1.28.0.tar.gz
fi

if [ ! -d "snort3-3.1.28.0" ]; then
    echo "Installing Snort 3..."
    tar xzf 3.1.28.0.tar.gz
    cd snort3-3.1.28.0
    ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
    cd build
    make
    sudo make install
else
    echo "Snort 3 already downloaded and extracted."
fi

# Update shared libraries
echo "Updating shared libraries..."
sudo ldconfig

# Check Snort installation
echo "Verifying Snort installation..."
snort -V

echo "Snort 3 installation completed."
