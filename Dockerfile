FROM ubuntu:22.04

# Install required packages, including sudo and iproute2
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget curl git python3 python3-pip neofetch sudo iproute2

# Download and set up ttyd
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Add neofetch to bashrc
RUN echo "neofetch" >> /root/.bashrc

# Create a startup script for network config and ttyd
RUN echo '#!/bin/bash\n\
ip addr flush dev eth0\n\
ip addr add 172.17.0.100/16 dev eth0\n\
ip route add default via 172.17.0.1 dev eth0\n\
echo "nameserver 8.8.8.8" > /etc/resolv.conf\n\
echo "nameserver 8.8.4.4" >> /etc/resolv.conf\n\
/bin/ttyd -p 3000 -c $USERNAME:$PASSWORD /bin/bash' > /start.sh && \
    chmod +x /start.sh

# Expose the port
EXPOSE 3000

# Debug credential output (optional)
RUN echo $CREDENTIAL > /tmp/debug

# Run the startup script
CMD ["/start.sh"]