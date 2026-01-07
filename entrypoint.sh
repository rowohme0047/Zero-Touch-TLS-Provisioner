#!/bin/bash
set -e
set -x # Enable debug mode for troubleshooting

# Define directories
CERT_DIR=${CERT_DIR:-"/etc/letsencrypt/live"}
OUTPUT_DIR=${OUTPUT_DIR:-"/output"}

DOMAINS=("${DOMAIN_1}" "${DOMAIN_2}")

# Loop through each domain
for DOMAIN in "${DOMAINS[@]}"; do
    DOMAIN_DIR="${CERT_DIR}/${DOMAIN}"

    echo "Generating SSL certificate for ${DOMAIN} using DNS-01 challenge..."

    # Use DNS-01 challenge with manual hooks
    certbot certonly --non-interactive --agree-tos --email "${CERTBOT_EMAIL}" \
      --manual --preferred-challenges dns \
      --manual-auth-hook "/scripts/authenticator.sh" \
      --manual-cleanup-hook "/scripts/cleanup.sh" \
      -d "${DOMAIN}"

    # Verify the certificate
    if [ ! -f "${DOMAIN_DIR}/fullchain.pem" ] || [ ! -f "${DOMAIN_DIR}/privkey.pem" ]; then
        echo "Error: SSL certificate for ${DOMAIN} was not generated successfully."
        exit 1
    fi

    echo "Certificate generated successfully for ${DOMAIN}. Converting to .pfx format..."

    # Convert to .pfx format
    if openssl pkcs12 -export \
      -out "${OUTPUT_DIR}/${DOMAIN}.pfx" \
      -inkey "${DOMAIN_DIR}/privkey.pem" \
      -in "${DOMAIN_DIR}/fullchain.pem" \
      -certfile "${DOMAIN_DIR}/fullchain.pem" \
      -password pass:${PFX_PASSWORD}; then
        echo "Successfully converted ${DOMAIN} certificate to .pfx format."
    else
        echo "Error: Failed to convert ${DOMAIN} certificate to .pfx format."
        exit 1
    fi
done

echo "All certificates successfully generated and saved to ${OUTPUT_DIR}."
