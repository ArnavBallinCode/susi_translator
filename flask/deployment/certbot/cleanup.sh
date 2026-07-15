#!/bin/sh

# DNS Provider Cleanup Hook for Certbot
# Removes the TXT record after verification is complete.

if [ -z "$DNS_TOKEN" ]; then
    echo "Error: DNS_TOKEN environment variable is not set."
    exit 1
fi

SUBDOMAIN=$(echo "$CERTBOT_DOMAIN" | sed 's/\.[^.]*\.[^.]*$//')
echo "Cleaning up DNS provider TXT record for subdomain: $SUBDOMAIN"

# To clear a TXT record, update it with the clear=true parameter
RESPONSE=$(wget -qO- "https://www.duckdns.org/update?domains=${SUBDOMAIN}&token=${DNS_TOKEN}&clear=true")

if [ "$RESPONSE" = "OK" ]; then
    echo "DNS provider TXT record cleared."
else
    # Cleanup failure is non-fatal for Certbot but should be visible in logs
    echo "Warning: DNS provider may not have cleared TXT record. Response: ${RESPONSE}"
fi
