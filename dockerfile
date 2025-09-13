# Use the official Ubuntu image as a base
FROM ubuntu:latest

# Image maintainer
LABEL maintainer="jadesonbruno.a@outlook.com"

# Update system packages and install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
        sudo \
        wget \
        curl \
        openssh-client \
        iputils-ping \
        unzip \
        git && \
        rm -rf /var/lib/apt/lists/*

# Add ubuntu user to sudo group
RUN usermod -aG sudo ubuntu

# Set Terraform version 
ENV TERRAFORM_VERSION=1.13.0

# Create the downloads/ folder in ubuntu´s home and set permissions
RUN mkdir /home/ubuntu/downloads && \
    chown -R ubuntu:ubuntu /home/ubuntu/downloads && \
    cd /home/ubuntu/downloads

# Download and install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    rm -rf awscliv2.zip && \
    ./aws/install

# Copy terraform project to ubuntu user home directory
COPY ./terraform /home/ubuntu/data-projects/di-web-aplication-with-aws-ecs/terraform
RUN chown -R ubuntu:ubuntu /home/ubuntu/data-projects/di-web-aplication-with-aws-ecs/terraform

# Switch to ubuntu user
USER ubuntu

# Set the working directory
WORKDIR /home/ubuntu/data-projects/di-web-aplication-with-aws-ecs/terraform

# Set the default command to bash
CMD ["bash"]
