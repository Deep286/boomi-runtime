#!/bin/bash
# Boomi Node Offboard Script
# This script automatically offboards a Boomi Molecule node from the platform
# when a container is being terminated

# Required environment variables (should be set via Kubernetes secrets)
BOOMI_ACCOUNT_ID="${BOOMI_ACCOUNT_ID}"
BOOMI_ATOM_ID="${BOOMI_ATOM_ID}"
BOOMI_USERNAME="${BOOMI_USERNAME}"
BOOMI_PASSWORD="${BOOMI_PASSWORD}"
BOOMI_BASE_URL="${BOOMI_BASE_URL:-https://api.boomi.com}"

LOG_FILE="/mnt/boomi/offboard.log"

# Check required environment variables
if [[ -z "$BOOMI_USERNAME" || -z "$BOOMI_PASSWORD" || -z "$BOOMI_ACCOUNT_ID" || -z "$BOOMI_ATOM_ID" ]]; then
  echo "❌ Missing required environment variables:" >> "$LOG_FILE" 2>&1
  echo "Please set BOOMI_USERNAME, BOOMI_PASSWORD, BOOMI_ACCOUNT_ID, BOOMI_ATOM_ID" >> "$LOG_FILE" 2>&1
  exit 1
fi

# Derive nodeId from ATOM_LOCALHOSTID or fallback to hostname
RAW_HOSTNAME=${ATOM_LOCALHOSTID:-$(hostname)}
NODE_ID=$(echo "$RAW_HOSTNAME" | sed 's/[-.]/_/g')

echo "🔧 Starting node offboard process..." >> "$LOG_FILE" 2>&1
echo "📌 Offboarding node ID: $NODE_ID" >> "$LOG_FILE" 2>&1
echo "🔗 From Atom ID: $BOOMI_ATOM_ID" >> "$LOG_FILE" 2>&1
echo "🏢 Account: $BOOMI_ACCOUNT_ID" >> "$LOG_FILE" 2>&1

# Create the NodeOffboard JSON payload
request_body=$(jq -n \
  --arg atomId "$BOOMI_ATOM_ID" \
  --arg nodeId "$NODE_ID" \
  '{
    "@type": "NodeOffboard",
    "nodeId": [$nodeId],
    "atomId": $atomId
  }')

echo "📤 Sending offboard request..." >> "$LOG_FILE" 2>&1

# Send NodeOffboard request to Boomi API
response=$(curl -s -w "\n%{http_code}" -X POST \
  -u "$BOOMI_USERNAME:$BOOMI_PASSWORD" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$request_body" \
  "$BOOMI_BASE_URL/api/rest/v1/$BOOMI_ACCOUNT_ID/NodeOffboard")

# Parse response
http_body=$(echo "$response" | sed '$d')
http_code=$(echo "$response" | tail -n1)

# Log the result
if [[ "$http_code" == "200" ]]; then
  echo "✅ NodeOffboard successful" >> "$LOG_FILE" 2>&1
  echo "$http_body" | jq >> "$LOG_FILE" 2>&1
else
  echo "❌ NodeOffboard failed (HTTP $http_code)" >> "$LOG_FILE" 2>&1
  echo "$http_body" | jq >> "$LOG_FILE" 2>&1
  exit 1
fi
