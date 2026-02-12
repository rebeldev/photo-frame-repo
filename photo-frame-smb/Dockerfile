FROM alpine:3.19

# Install required packages
RUN apk add --no-cache bash coreutils jq cifs-utils

# Copy the startup script
COPY run.sh /run.sh

# Ensure the script is executable
RUN chmod 755 /run.sh

# Run the script
CMD ["/run.sh"]

