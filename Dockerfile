# Utilise l'image Alpine
FROM alpine:latest

# Installe les dépendances nécessaires
RUN apk update && apk upgrade
RUN apk add --no-cache nodejs npm yarn git curl zsh python3 py3-pip shadow sudo

# Installer pandas, numpy et matplotlib
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
# Installer pandas, numpy et matplotlib
RUN pip install pandas numpy matplotlib requests

# Set zsh as the default shell
SHELL ["/bin/zsh", "-c"]
ENV SHELL /bin/zsh

# For security reason, it's best to create a user to avoid using root by default, but giving him sudo right
RUN addgroup -g 1000 devuser && \
    adduser -D -u 1000 -G devuser devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devuser

ENV HOME /home/devuser
ENV PATH $PATH:$HOME/.local/bin

# Install oh-my-zsh
RUN ash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Scarb
RUN ash -c "$(curl -fsSL https://docs.swmansion.com/scarb/install.sh)" -s -- -v 2.6.4

# Install Starknet Foundry
RUN ash -c "$(curl -fsSL https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh)" -s
RUN snfoundryup -v 0.23.0

# Définit le répertoire de travail
WORKDIR /app

