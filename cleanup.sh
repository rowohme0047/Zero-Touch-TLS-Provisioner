#!/bin/bash
set -e

DUCKDNS_TOKEN="266f425b-a3ad-49ba-944e-2e5d6441caed"

echo "Removing TXT record for $CERTBOT_DOMAIN"

# Remove the TXT record from DuckDNS
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}&token=${DUCKDNS_TOKEN}&clear=true" -o /dev/null -w "%{http_code}")
if [ "$RESPONSE" -ne 200 ]; then
    echo "Error: Failed to remove TXT record for $CERTBOT_DOMAIN. HTTP response code: $RESPONSE"
    exit 1
fi

echo "TXT record removed for $CERTBOT_DOMAIN"
