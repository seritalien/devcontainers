# Utilise l'image Alpine
FROM alpine:latest

# Installe les dépendances nécessaires avec root
RUN apk update && apk upgrade && \
    apk add --no-cache nodejs npm yarn git curl zsh python3 py3-pip shadow sudo openrc openssh docker-cli docker-compose && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install pandas numpy matplotlib requests && \
    addgroup -g 1000 devuser && \
    adduser -D -u 1000 -G devuser devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /var/run/sshd && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    ssh-keygen -A && \
    addgroup -S docker && addgroup devuser docker

# Définir les variables d'environnement
ENV PATH="/opt/venv/bin:$PATH" \
    HOME="/home/devuser" \
    SHELL="/bin/zsh"

USER devuser

# Set zsh as the default shell
SHELL ["/bin/zsh", "-c"]

# Install oh-my-zsh
RUN ash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Scarb
RUN ash -c "$(curl -fsSL https://docs.swmansion.com/scarb/install.sh)" -s -- -v 2.6.4

# Install Starknet Foundry
RUN ash -c "$(curl -fsSL https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh)" -s
RUN snfoundryup -v 0.23.0

# Définit le répertoire de travail
WORKDIR /app

# Expose SSH port
EXPOSE 22

# Démarrer un shell interactif par défaut
CMD ["/bin/zsh"]
