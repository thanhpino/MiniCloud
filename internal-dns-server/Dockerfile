FROM alpine:latest

# Install Bind9 and DNS tools (dig, nslookup)
RUN apk add --no-cache bind bind-tools && \
    mkdir -p /etc/bind/zones /var/cache/bind /var/run/named && \
    chown -R named:named /etc/bind /var/cache/bind /var/run/named

# Copy configuration files
COPY named.conf /etc/bind/named.conf
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local
COPY db.cloud.local /etc/bind/zones/db.cloud.local

RUN chown -R named:named /etc/bind/zones && \
    chmod 644 /etc/bind/zones/db.cloud.local

EXPOSE 53/udp 53/tcp

CMD ["named", "-g", "-c", "/etc/bind/named.conf", "-u", "named"]

