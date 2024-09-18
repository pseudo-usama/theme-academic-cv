# Use Ubuntu as the base image
FROM ubuntu:20.04

# Set environment variables for non-interactive apt-get installations
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: Git, curl, tar, Go, and other required build tools
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    tar \
    build-essential \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Go (version 1.18 in this example, adjust as needed)
ENV GO_VERSION=1.18.4
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Hugo from the tarball
ENV HUGO_VERSION=0.126.3
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz -o /tmp/hugo.tar.gz && \
    tar -zxvf /tmp/hugo.tar.gz -C /usr/local/bin/ && \
    rm /tmp/hugo.tar.gz

# Verify Hugo installation
RUN hugo version

# Set up directories
RUN mkdir -p /app /output

# Set the working directory inside the container
WORKDIR /app

# Copy the entire repository into the container
COPY . .

# Install Go modules if go.mod is present
RUN if [ -f go.mod ]; then \
      hugo mod get && hugo mod tidy; \
    fi

# Build the Hugo site
RUN hugo --minify

EXPOSE 1313
CMD ["hugo", "server", "--bind", "0.0.0.0", "--port", "1313", "--baseURL", "http://localhost", "--watch"]
