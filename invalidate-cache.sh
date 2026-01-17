#!/bin/bash

# Lunar Staircase - CloudFront Cache Invalidation Script
# Use this to clear CloudFront cache without re-uploading files

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load environment variables
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
else
  echo -e "${RED}Error: .env file not found${NC}"
  exit 1
fi

if [ -z "$AWS_CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo -e "${RED}Error: AWS_CLOUDFRONT_DISTRIBUTION_ID not set in .env${NC}"
  exit 1
fi

echo -e "${YELLOW}Invalidating CloudFront cache...${NC}"

# Create invalidation
INVALIDATION_OUTPUT=$(aws cloudfront create-invalidation \
  --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} \
  --paths "/*" \
  --output json)

INVALIDATION_ID=$(echo $INVALIDATION_OUTPUT | grep -o '"Id": "[^"]*' | cut -d'"' -f4)

echo -e "${GREEN}✓ Cache invalidation created: ${INVALIDATION_ID}${NC}"
echo ""
echo -e "${YELLOW}Note: Invalidation may take 5-15 minutes to complete.${NC}"
echo ""
echo "Check status with:"
echo "  aws cloudfront get-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --id ${INVALIDATION_ID}"
