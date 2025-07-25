# RustDesk Server Dockerfile
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTDESK_VERSION=1.2.3

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create rustdesk user and directories
RUN useradd -r -d /opt/rustdesk -s /bin/false rustdesk \
    && mkdir -p /opt/rustdesk/data \
    && mkdir -p /opt/rustdesk/logs

# Download and install RustDesk server
WORKDIR /opt/rustdesk
RUN wget -O rustdesk-server.zip https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-linux-amd64.zip \
    && unzip rustdesk-server.zip \
    && rm rustdesk-server.zip \
    && chmod +x hbbs hbbr \
    && chown -R rustdesk:rustdesk /opt/rustdesk

# Create startup script
RUN echo '#!/bin/bash\n\
cd /opt/rustdesk\n\
echo "Starting RustDesk Relay Server..."\n\
./hbbr &\n\
echo "Starting RustDesk Signal Server..."\n\
./hbbs -r $RUSTDESK_RELAY_SERVER &\n\
wait' > /opt/rustdesk/start.sh \
    && chmod +x /opt/rustdesk/start.sh

# Switch to rustdesk user
USER rustdesk

# Expose ports
# 21115: hbbs (TCP)
# 21116: hbbs (TCP/UDP) 
# 21117: hbbr (TCP)
# 21118: hbbr (TCP)
# 21119: hbbr (TCP)
EXPOSE 21115 21116 21117 21118 21119

# Set working directory
WORKDIR /opt/rustdesk

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -f "hbbs|hbbr" || exit 1

# Start the services
CMD ["/opt/rustdesk/start.sh"]
