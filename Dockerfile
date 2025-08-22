FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Create working directory
RUN mkdir -p /data

# Install base system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libbz2-dev \
    python3-pip \
    python3-distutils \
    openssh-client \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Build Python 3.8.10 from source
RUN wget https://www.python.org/ftp/python/3.8.10/Python-3.8.10.tgz && \
    tar xzf Python-3.8.10.tgz && \
    cd Python-3.8.10 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.8.10 Python-3.8.10.tgz

# Set python3 alternative to point to python3.8
RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.8 1

# Remove broken lsb_release to prevent pip crash
RUN rm -f /usr/bin/lsb_release

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Ansible Core
RUN python3 -m pip install ansible-core==2.13.13

# Install community.general collection
RUN ansible-galaxy collection install community.general

# Verify installations
RUN python3 --version && ansible --version && ssh -V && vim --version
