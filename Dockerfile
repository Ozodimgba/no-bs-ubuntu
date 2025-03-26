FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget curl git python3 python3-pip neofetch sudo iproute2 iptables

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install ttyd
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Add neofetch to bashrc
RUN echo "neofetch" >> /root/.bashrc

# Startup script
RUN echo '#!/bin/bash\n\
echo "nameserver 8.8.8.8" > /etc/resolv.conf\n\
echo "nameserver 8.8.4.4" >> /etc/resolv.conf\n\
tailscaled --tun=userspace-networking &\n\
sleep 5\n\
tailscale up --authkey="$TAILSCALE_AUTHKEY" || echo "Tailscale failed"\n\
PORT=${PORT:-3000}\n\
/bin/ttyd -p "$PORT" -c "$USERNAME:$PASSWORD" /bin/bash' > /start.sh && \
    chmod +x /start.sh

# Expose port 3000
EXPOSE 3000

# Optional debug
RUN echo "$CREDENTIAL" > /tmp/debug

# Run the script
CMD ["/start.sh"]