#!/bin/sh

# DuckDNS Cleanup Hook for Certbot
# Removes the TXT record after verification is complete.

if [ -z "$DUCKDNS_TOKEN" ]; then
    echo "Error: DUCKDNS_TOKEN environment variable is not set."
    exit 1
fi

SUBDOMAIN=$(echo "$CERTBOT_DOMAIN" | sed 's/\.duckdns\.org//')
echo "Cleaning up DuckDNS TXT record for subdomain: $SUBDOMAIN"

# To clear a TXT record in DuckDNS, you update it with an empty txt parameter (or clear=true)
wget -qO- "https://www.duckdns.org/update?domains=${SUBDOMAIN}&token=${DUCKDNS_TOKEN}&clear=true" > /dev/null

echo "DuckDNS TXT record cleared."
