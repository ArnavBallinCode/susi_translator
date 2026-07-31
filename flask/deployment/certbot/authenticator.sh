#!/bin/sh
set -e

# DNS Provider Authenticator Hook for Certbot
# Called by Certbot during DNS-01 challenge to update the DNS provider TXT record.

if [ -z "$DNS_TOKEN" ]; then
    echo "Error: DNS_TOKEN environment variable is not set."
    exit 1
fi

# Extract the subdomain from the domain name (e.g., 'susi' from 'susi.example.org')
SUBDOMAIN=$(echo "$CERTBOT_DOMAIN" | sed 's/\.[^.]*\.[^.]*$//')

echo "Sending TXT record to DNS provider for subdomain: $SUBDOMAIN"

# The DNS provider API uses GET requests; the token is passed as a URL parameter.
RESPONSE=$(wget -qO- "https://www.duckdns.org/update?domains=${SUBDOMAIN}&token=${DNS_TOKEN}&txt=${CERTBOT_VALIDATION}")

if [ "$RESPONSE" = "OK" ]; then
    echo "Successfully updated DNS provider TXT record."
else
    echo "Failed to update DNS provider TXT record. Response: $RESPONSE"
    exit 1
fi

# Wait for DNS propagation
echo "Waiting 30 seconds for DNS propagation..."
sleep 30