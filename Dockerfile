# Use a light Debian image
FROM debian:stable-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Python libraries
RUN pip3 install pandas numpy matplotlib

# Install Node.js libraries
RUN npm install -g yarn asdf

# Set up asdf for version management
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0

# Add asdf to .bashrc
RUN echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc \
    && echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
