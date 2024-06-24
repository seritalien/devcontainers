# Utiliser Ubuntu 24.04 LTS
FROM ubuntu:24.04

# Mettre à jour et installer les dépendances de base
RUN apt-get update && apt-get install -y \
    sudo \
    apt-utils \
    curl \
    wget \
    git \
    openssh-client \
    python3 \
    python3-pip \
    zsh \
    fonts-powerline \
    software-properties-common \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libnss3 \
    libxrandr2 \
    libatk1.0-0 \
    libgtk-3-0 \
    libdrm2 \
    libgbm1 \
    libxss1 \
    libxshmfence1 \
    libglu1-mesa \
    xdg-utils \
    libnotify4 \
    libasound2-data \
    && rm -rf /var/lib/apt/lists/*

# Installer Brave Browser
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && apt-get install -y brave-browser

# Télécharger et installer Ferdium
RUN wget https://github.com/ferdium/ferdium-app/releases/download/v6.7.4/Ferdium-linux-6.7.4-amd64.deb && \
    apt-get update && apt-get install -y ./Ferdium-linux-6.7.4-amd64.deb && \
    rm Ferdium-linux-6.7.4-amd64.deb

# Installer Oh-My-Zsh
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" --unattended

# Définir Zsh comme shell par défaut
RUN chsh -s $(which zsh)

# Configuration pour l'affichage graphique
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

# Configuration utilisateur (optionnel)
ARG USERNAME=user
ARG USER_UID=1001
ARG USER_GID=1001

RUN if ! getent group $USER_GID; then groupadd --gid $USER_GID $USERNAME; fi && \
    if ! id -u $USER_UID > /dev/null 2>&1; then useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; fi && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME

# Installer des dépendances supplémentaires pour l'utilisateur
RUN sudo apt-get install -y python3-venv
