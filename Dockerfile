# Start from the code-server Debian base image
FROM codercom/code-server:4.0.2

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension hashicorp.terraform
RUN code-server --install-extension eamodio.gitlens

# upgrade terraform to =1.1.6
RUN sudo apt install -y wget && \
  wget https://releases.hashicorp.com/terraform/1.1.6/terraform_1.1.6_linux_amd64.zip && \
  sudo unzip terraform_1.1.6_linux_amd64.zip && \
  rm terraform_1.1.6_linux_amd64.zip && \
  sudo mv terraform /usr/bin/terraform

RUN sudo apt-get update && \
    sudo apt-get install -y \
        unzip \
        curl \
    && sudo apt-get clean \
    && sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && sudo rm -rf awscliv2.zip \
    && sudo apt-get -y purge curl \
    && sudo apt-get -y purge unzip 

RUN mkdir /home/coder/.ssh && ssh-keygen -q -t rsa -N '' -f /home/coder/.ssh/id_rsa

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
