# Utilise l'image Alpine
FROM alpine:latest

# Installe les dépendances nécessaires avec root
RUN apk update && apk upgrade
RUN apk add --no-cache nodejs npm yarn git curl zsh python3 py3-pip shadow sudo openrc openssh docker-cli docker-compose

# Installer pandas, numpy et matplotlib
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install pandas numpy matplotlib requests

# Pour des raisons de sécurité, il est préférable de créer un utilisateur pour éviter d'utiliser root par défaut
RUN addgroup -g 1000 devuser && \
    adduser -D -u 1000 -G devuser devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configuration du service SSH (exécuté en tant que root)
RUN mkdir /var/run/sshd && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Créer le groupe docker et ajouter l'utilisateur devuser à ce groupe
RUN addgroup -S docker && addgroup devuser docker

USER devuser

ENV HOME /home/devuser
ENV PATH $PATH:$HOME/.local/bin

# Set zsh as the default shell
SHELL ["/bin/zsh", "-c"]
ENV SHELL /bin/zsh

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

# Pour démarrer le service SSH et ensuite basculer à l'utilisateur devuser
CMD ["/bin/zsh", "-c", "sudo /usr/sbin/sshd && sudo chown -R devuser:devuser /workspace && su - devuser -c 'tail -f /dev/null'"]
