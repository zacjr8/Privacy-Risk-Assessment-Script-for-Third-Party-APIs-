#!/bin/bash

# File containing the list of APIs
API_FILE="apis.txt"

# Define the PII patterns to search for (e.g., emails, names, IPs, phone numbers)
PII_PATTERNS=("email" "name" "ip_address" "phone" "ssn")

# Output report file
REPORT_FILE="privacy_risk_report.txt"

# Empty the report file at the start
> $REPORT_FILE

# Function to check for PII in API response
check_for_pii() {
    local response="$1"
    local api_url="$2"
    
    echo "Analyzing response from $api_url..." >> $REPORT_FILE
    
    # Check for each PII pattern
    for pattern in "${PII_PATTERNS[@]}"; do
        echo "Checking for $pattern in response..."
        if echo "$response" | grep -iq "$pattern"; then
            echo "⚠️  PII detected: $pattern found in API response from $api_url" >> $REPORT_FILE
        else
            echo "$pattern not found in $api_url" >> $REPORT_FILE
        fi
    done
}

# Loop through each API in the API file
while IFS= read -r api_url; do
    if [[ -n "$api_url" ]]; then
        echo "Querying API: $api_url..."
        
        # Query the API using curl
        response=$(curl -s "$api_url")
        
        # Check if the response is valid JSON
        if echo "$response" | jq . > /dev/null 2>&1; then
            # If valid JSON, check for PII in the response
            check_for_pii "$response" "$api_url"
        else
            echo "Error: Received invalid JSON response from $api_url" >> $REPORT_FILE
        fi
    fi
done < "$API_FILE"

echo "Privacy risk assessment completed. Check the report: $REPORT_FILE"
