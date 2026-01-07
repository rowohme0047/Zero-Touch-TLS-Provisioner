#!/bin/bash
set -e

DUCKDNS_TOKEN="266f425b-a3ad-49ba-944e-2e5d6441caed"

echo "Adding TXT record for $CERTBOT_DOMAIN"

# Add TXT record to DuckDNS
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}&token=${DUCKDNS_TOKEN}&txt=${CERTBOT_VALIDATION}" -o /dev/null -w "%{http_code}")
if [ "$RESPONSE" -ne 200 ]; then
    echo "Error: Failed to add TXT record for $CERTBOT_DOMAIN. HTTP response code: $RESPONSE"
    exit 1
fi

echo "TXT record added for $CERTBOT_DOMAIN"

# Wait for DNS propagation
echo "Waiting for DNS propagation..."
sleep 180 # Increase wait time for DNS propagation

# Verify TXT record using dig
echo "Verifying TXT record propagation..."
if ! dig +short TXT "_acme-challenge.${CERTBOT_DOMAIN}" | grep -q "${CERTBOT_VALIDATION}"; then
    echo "Error: TXT record for $CERTBOT_DOMAIN is not propagated. Validation may fail."
    exit 1
fi
echo "TXT record successfully propagated for $CERTBOT_DOMAIN"
