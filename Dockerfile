FROM ubuntu:24.04

# ====-====-====-====-====-====-====-====-====-====-====

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# ====-====-====-====-====-====-====-====-====-====-====
# install node.js:

# https://stackoverflow.com/questions/25899912/how-to-install-nvm-in-docker

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR=/nvm
ENV NODE_VERSION=24

RUN mkdir -p $NVM_DIR

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV      PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN . "$NVM_DIR/nvm.sh"

# ====-====-====-====-====-====-====-====-====-====-====

# Update + install utilities
# --- Networking & HTTP ---
    RUN apt-get update && apt-get install -y \
    curl \
    wget \
    httpie \
    netcat-openbsd \
    dnsutils \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# --- File & Text Processing ---
RUN apt-get update && apt-get install -y \
    jq \
    yq \
    sed \
    gawk \
    grep \
    ripgrep \
    fd-find \
    diffutils \
    patch \
    && rm -rf /var/lib/apt/lists/*

# --- Archives & Compression ---
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# --- File Inspection ---
RUN apt-get update && apt-get install -y \
    file \
    tree \
    ncdu \
    htop \
    && rm -rf /var/lib/apt/lists/*

# --- Git & Versioning ---
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# --- Build & Dev Tools ---
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# --- Media Processing ---
RUN apt-get update && apt-get install -y \
    ffmpeg \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# --- Data & Encoding ---
RUN apt-get update && apt-get install -y \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# --- Search & Fuzzy Matching ---
RUN apt-get update && apt-get install -y \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# --- System Monitoring ---
RUN apt-get update && apt-get install -y \
    procps \
    && rm -rf /var/lib/apt/lists/*

# --- Time & Misc ---
RUN apt-get update && apt-get install -y \
    tzdata \
    moreutils \
    && rm -rf /var/lib/apt/lists/*

# ====-====-====-====-====-====-====-====-====-====-====
# Claude setup

# Needed for dictation
RUN apt-get update && apt-get install -y \
    sox \
    alsa-base \
    alsa-utils \
    && rm -rf /var/lib/apt/lists/*

ENV AUDIODRIVER=alsa
ENV AUDIODEV=hw:1,0

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN cp /root/.claude.json /root/.claude.json.bu

ENV PATH="/root/.local/bin:$PATH"

# ====-====-====-====-====-====-====-====-====-====-====

COPY ./entrypoint.sh /root/entrypoint.sh

WORKDIR /ws

ENTRYPOINT [ "bash", "/root/entrypoint.sh" ]