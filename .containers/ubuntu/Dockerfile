FROM ubuntu:22.04

# OS Stuff.
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 python3-pip

# Python stuff.
RUN pip install python-a2s

WORKDIR /app

# Set default command
CMD ["/bin/bash"]
