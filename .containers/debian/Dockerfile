FROM debian:bookworm

# OS Stuff.
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 python3-pip \
    software-properties-common \
    neovim

WORKDIR /app

# Set default command
CMD ["/bin/bash"]
