FROM ubuntu:18.04

# Packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    gpg \
    curl \    
    lsb-release \
    add-apt-key \
    ca-certificates \    
    dumb-init \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Common SDK
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    sudo \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && sudo apt-get install yarn -y

# Node SDK
# RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
# RUN apt-get update && apt-get install --no-install-recommends -y \
#     nodejs \
#     && rm -rf /var/lib/apt/lists/*

# Golang SDK
ENV GO_VERSION="1.12.2"
RUN curl -sL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz | tar -xz -C /usr/local

# Java SDK
RUN apt-get update && apt-get install --no-install-recommends -y \
    default-jre-headless \
    default-jdk-headless \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install --no-install-recommends -y \
    google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Code-Server
RUN apt-get update && apt-get install --no-install-recommends -y \
    bsdtar \
    openssl \
    locales \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

ENV CODE_VERSION="1.939-vsc1.33.1"
RUN curl -sL https://github.com/codercom/code-server/releases/download/${CODE_VERSION}/code-server${CODE_VERSION}-linux-x64.tar.gz | tar --strip-components=1 -zx -C /usr/local/bin code-server${CODE_VERSION}-linux-x64/code-server

# Setup User
RUN groupadd -r coder \
    && useradd -m -r coder -g coder -s /bin/bash \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER coder

# Setup User Profile
ENV LC_ALL=en_US.UTF-8

# Setup User Visual Studio Code Extentions
ENV VSCODE_EXTENSIONS "/home/coder/.local/share/code-server/extensions"

# Setup Java Extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/java \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/redhat/vsextensions/java/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/java-debugger \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-debug/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-debugger extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/java-test \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-test/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-test extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/maven \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-maven/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/maven extension

# Setup Chrome Preview
RUN mkdir -p ${VSCODE_EXTENSIONS}/chrome-debugger \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/msjsdiag/vsextensions/debugger-for-chrome/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/chrome-debugger extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/chrome-preview \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/auchenberg/vsextensions/vscode-browser-preview/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/chrome-preview extension

# Setup User Workspace
RUN mkdir -p /home/coder/project
WORKDIR /home/coder/project

ENTRYPOINT ["dumb-init", "code-server"]
