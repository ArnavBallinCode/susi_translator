#!/bin/sh

# Certbot Auto-Renewal Entrypoint
# Periodically checks and renews Let's Encrypt certificates.

# Fail fast on missing required environment variables
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME environment variable is not set."
    exit 1
fi

echo "Starting Certbot Let's Encrypt auto-renewal service for $DOMAIN_NAME..."

chmod +x /opt/certbot-scripts/authenticator.sh

# Disable fail-fast for the main loop — certbot failures are caught, logged,
# and retried on the next iteration rather than crashing the container.
set +e

# Main renewal loop
while :; do
    echo "Checking certificate status for $DOMAIN_NAME..."

    # If dummy certificates exist, remove them
    # so Certbot can generate the real ones without crashing
    if [ -f "/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem" ] && [ ! -L "/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem" ]; then
        echo "Removing dummy certificates to allow Certbot to generate real ones..."
        rm -rf "/etc/letsencrypt/live/${DOMAIN_NAME}"
        rm -rf "/etc/letsencrypt/archive/${DOMAIN_NAME}"
        rm -rf "/etc/letsencrypt/renewal/${DOMAIN_NAME}.conf"
    fi

    # Obtain or renew certificate via DNS provider DNS-01 challenge
    certbot certonly \
        --non-interactive \
        --agree-tos \
        -m "${CERTBOT_EMAIL:-admin@${DOMAIN_NAME}}" \
        --manual \
        --preferred-challenges dns \
        --manual-auth-hook /opt/certbot-scripts/authenticator.sh \
        --manual-cleanup-hook /opt/certbot-scripts/cleanup.sh \
        -d "$DOMAIN_NAME" \
        --cert-name "${DOMAIN_NAME}" \
        --keep-until-expiring

    CERTBOT_EXIT=$?
    if [ "$CERTBOT_EXIT" -ne 0 ]; then
        echo "Certbot failed with exit code ${CERTBOT_EXIT}. Will retry in 12 hours."
    else
        echo "Certbot check completed successfully."
    fi

    echo "Sleeping for 12 hours..."
    sleep 12h
done