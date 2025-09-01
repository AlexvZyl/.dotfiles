FROM ubuntu:24.04

# OS Stuff.
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 python3-pip \
    software-properties-common

# Python stuff.
RUN pip install python-a2s

WORKDIR /app

# Set default command
CMD ["/bin/bash"]
