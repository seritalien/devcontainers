ARG PYTHON_VERSION="3.9-slim"
ARG ASDF_VERSION="v0.14.0"
ARG SCARB_VERSION="2.6.4"
ARG STARKNET_FOUNDRY_VERSION="0.23.0"
FROM python:${PYTHON_VERSION}
RUN  apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install gcc libgmp3-dev curl git zsh nodejs npm -y \
    && apt-get clean

COPY .p10k.zsh /root/.p10k.zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k \
    && echo 'source ~/.p10k.zsh' >> ~/.zshrc \
    && echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

WORKDIR /app

# Install Python libraries
RUN pip3 install pandas numpy matplotlib

# Install Node.js libraries
RUN npm install -g yarn

# Set up asdf for version management
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
# Add asdf to .bashrc
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc 
#\
#&& echo -e '\n. $HOME/.asdf/completions/asdf.zsh' >> ~/.zshrc

ENV PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

#Starknet tools
# Ajouter scarb et starknet-foundry via asdf
RUN /bin/zsh -c "source ~/.asdf/asdf.sh && asdf plugin add scarb && asdf install scarb 2.6.4 \
    && asdf plugin add starknet-foundry && asdf install starknet-foundry 0.23.0"


