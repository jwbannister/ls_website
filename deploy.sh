#!/bin/bash

# Lunar Staircase - AWS S3 + CloudFront Deployment Script
# This script syncs your website to S3 and invalidates the CloudFront cache

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
else
  echo -e "${RED}Error: .env file not found${NC}"
  echo "Please create a .env file based on .env.example"
  exit 1
fi

# Check required environment variables
if [ -z "$AWS_S3_BUCKET" ] || [ -z "$AWS_CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo -e "${RED}Error: Required environment variables not set${NC}"
  echo "Please set AWS_S3_BUCKET and AWS_CLOUDFRONT_DISTRIBUTION_ID in .env"
  exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo -e "${RED}Error: AWS CLI is not installed${NC}"
  echo "Please install AWS CLI: https://aws.amazon.com/cli/"
  exit 1
fi

echo -e "${YELLOW}Starting deployment to AWS...${NC}"
echo ""

# Sync files to S3
echo -e "${YELLOW}[1/3] Syncing files to S3 bucket: ${AWS_S3_BUCKET}${NC}"
aws s3 sync . s3://${AWS_S3_BUCKET} \
  --exclude ".git/*" \
  --exclude ".ai/*" \
  --exclude ".cursor/*" \
  --exclude "node_modules/*" \
  --exclude ".env*" \
  --exclude "deploy.sh" \
  --exclude "*.md" \
  --exclude ".gitignore" \
  --delete \
  --cache-control "public, max-age=31536000" \
  --exclude "*.html" \
  --exclude "*.css" \
  --exclude "*.js"

# Upload HTML, CSS, JS with shorter cache (for easier updates)
echo -e "${YELLOW}[2/3] Uploading HTML, CSS, and JS files with shorter cache...${NC}"
aws s3 sync . s3://${AWS_S3_BUCKET} \
  --exclude "*" \
  --include "*.html" \
  --include "*.css" \
  --include "*.js" \
  --cache-control "public, max-age=3600" \
  --delete

echo -e "${GREEN}✓ Files synced successfully${NC}"
echo ""

# Invalidate CloudFront cache
echo -e "${YELLOW}[3/3] Invalidating CloudFront cache...${NC}"
INVALIDATION_OUTPUT=$(aws cloudfront create-invalidation \
  --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} \
  --paths "/*" \
  --output json)

INVALIDATION_ID=$(echo $INVALIDATION_OUTPUT | grep -o '"Id": "[^"]*' | cut -d'"' -f4)

echo -e "${GREEN}✓ CloudFront invalidation created: ${INVALIDATION_ID}${NC}"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "S3 Bucket: ${AWS_S3_BUCKET}"
echo "CloudFront Distribution: ${AWS_CLOUDFRONT_DISTRIBUTION_ID}"
echo "Invalidation ID: ${INVALIDATION_ID}"
echo ""
echo -e "${YELLOW}Note: CloudFront invalidation may take 5-15 minutes to complete.${NC}"
echo -e "Check status: aws cloudfront get-invalidation --distribution-id ${AWS_CLOUDFRONT_DISTRIBUTION_ID} --id ${INVALIDATION_ID}"
echo ""
