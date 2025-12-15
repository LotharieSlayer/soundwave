FROM alpine:latest

# Install required packages
RUN apk add --no-cache curl cronie tzdata

# Set timezone (change if needed)
ENV TZ=Europe/Paris

# Create directories
RUN mkdir -p /data /var/log

# Copy files
COPY update_radios.sh /usr/local/bin/update_radios.sh
COPY crontab /etc/crontabs/root

# Permissions
RUN chmod +x /usr/local/bin/update_radios.sh

# Initial download on container start
RUN /usr/local/bin/update_radios.sh

# Start cron in foreground
CMD ["crond", "-f"]

