# AWS S3 + CloudFront Setup Guide

Complete guide to hosting your Lunar Staircase website on AWS S3 + CloudFront.

**Estimated monthly cost:** $1-3 for low traffic sites

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Install AWS CLI](#step-1-install-aws-cli)
3. [Step 2: Configure AWS Credentials](#step-2-configure-aws-credentials)
4. [Step 3: Create S3 Bucket](#step-3-create-s3-bucket)
5. [Step 4: Request SSL Certificate](#step-4-request-ssl-certificate)
6. [Step 5: Create CloudFront Distribution](#step-5-create-cloudfront-distribution)
7. [Step 6: Configure DNS (Route 53 or External)](#step-6-configure-dns)
8. [Step 7: Deploy Your Website](#step-7-deploy-your-website)
9. [Ongoing: Update Your Website](#ongoing-update-your-website)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- AWS Account (create at https://aws.amazon.com)
- Domain name (e.g., lunarstaircase.com)
- Basic command line knowledge

---

## Step 1: Install AWS CLI

### macOS
```bash
brew install awscli
```

### Linux
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Windows
Download installer from: https://aws.amazon.com/cli/

**Verify installation:**
```bash
aws --version
```

---

## Step 2: Configure AWS Credentials

### Create IAM User with Programmatic Access

1. Go to AWS Console → IAM → Users → Add User
2. Username: `ls-website-deploy`
3. Access type: **Programmatic access** (check this box)
4. Permissions: Attach policies directly
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`
   - (Or create custom policy with minimal permissions)
5. Create user and **save the Access Key ID and Secret Access Key**

### Configure AWS CLI

```bash
aws configure
```

Enter:
- **AWS Access Key ID:** [Your access key]
- **AWS Secret Access Key:** [Your secret key]
- **Default region:** `us-east-1` (required for SSL certificates)
- **Default output format:** `json`

**Verify:**
```bash
aws sts get-caller-identity
```

---

## Step 3: Create S3 Bucket

### Option A: Using AWS Console

1. Go to **S3** in AWS Console
2. Click **Create bucket**
3. **Bucket name:** `lunarstaircase.com` (use your domain name)
4. **Region:** `us-east-1` (recommended)
5. **Block all public access:** UNCHECK this (we need public read access)
6. Create bucket
7. Go to bucket → **Permissions** → **Bucket Policy**
8. Add this policy (replace `lunarstaircase.com` with your bucket name):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::lunarstaircase.com/*"
    }
  ]
}
```

### Option B: Using AWS CLI

```bash
# Set your bucket name
BUCKET_NAME="lunarstaircase.com"

# Create bucket
aws s3 mb s3://${BUCKET_NAME} --region us-east-1

# Enable static website hosting
aws s3 website s3://${BUCKET_NAME} --index-document index.html --error-document index.html

# Set bucket policy for public read
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket ${BUCKET_NAME} --policy file://bucket-policy.json
```

---

## Step 4: Request SSL Certificate

**IMPORTANT:** Must be done in **us-east-1** region for CloudFront.

### Using AWS Console

1. Go to **Certificate Manager** (ACM)
2. **MAKE SURE YOU'RE IN US-EAST-1 REGION** (top right)
3. Click **Request certificate**
4. Choose **Request a public certificate**
5. **Domain names:**
   - `lunarstaircase.com`
   - `www.lunarstaircase.com` (add both)
6. **Validation method:** DNS validation (recommended)
7. Request certificate
8. Click **Create records in Route 53** (if using Route 53)
   - OR manually add CNAME records to your DNS provider
9. Wait for validation (5-30 minutes)

### Using AWS CLI

```bash
# Request certificate
CERT_ARN=$(aws acm request-certificate \
  --domain-name lunarstaircase.com \
  --subject-alternative-names www.lunarstaircase.com \
  --validation-method DNS \
  --region us-east-1 \
  --output text \
  --query CertificateArn)

echo "Certificate ARN: ${CERT_ARN}"

# Get validation records
aws acm describe-certificate \
  --certificate-arn ${CERT_ARN} \
  --region us-east-1 \
  --query 'Certificate.DomainValidationOptions[*].ResourceRecord'
```

Add the CNAME records to your DNS, then wait for validation.

---

## Step 5: Create CloudFront Distribution

### Using AWS Console

1. Go to **CloudFront** → **Create Distribution**
2. **Origin domain:** Select your S3 bucket from dropdown
   - It will show: `lunarstaircase.com.s3.us-east-1.amazonaws.com`
3. **Origin path:** Leave blank
4. **Name:** `S3-lunarstaircase`
5. **Origin access:** Choose **Origin access control settings (recommended)**
   - Click **Create control setting**
   - Create with defaults
6. **Viewer protocol policy:** Redirect HTTP to HTTPS
7. **Allowed HTTP methods:** GET, HEAD
8. **Compress objects automatically:** Yes
9. **Price class:** Use all edge locations (or choose based on your needs)
10. **Alternate domain names (CNAMEs):**
    - `lunarstaircase.com`
    - `www.lunarstaircase.com`
11. **Custom SSL certificate:** Choose your ACM certificate
12. **Default root object:** `index.html`
13. **Error pages (optional):**
    - Create custom error response
    - HTTP error code: 403, 404
    - Response page path: `/index.html`
    - HTTP response code: 200
14. Create distribution
15. **IMPORTANT:** Copy the S3 bucket policy shown after creation and add it to your S3 bucket

### Using AWS CLI (Advanced)

See the [CloudFormation template](#cloudformation-template-optional) below for Infrastructure as Code approach.

---

## Step 6: Configure DNS

### Option A: Using Route 53 (AWS DNS)

1. Go to **Route 53** → **Hosted zones** → **Create hosted zone**
2. Domain name: `lunarstaircase.com`
3. Type: Public
4. Create two **A records** (Alias):
   - **Name:** (leave blank for root domain)
   - **Record type:** A
   - **Alias:** Yes
   - **Route traffic to:** CloudFront distribution
   - **Choose distribution:** Select your CloudFront distribution

5. Repeat for `www`:
   - **Name:** `www`
   - Same settings as above

6. **Update your domain registrar:**
   - Copy the 4 nameservers from Route 53 hosted zone
   - Go to your domain registrar (GoDaddy, Namecheap, etc.)
   - Update nameservers to Route 53 nameservers
   - Wait 24-48 hours for DNS propagation

### Option B: Using External DNS Provider

If your domain is with GoDaddy, Namecheap, etc.:

1. Get your CloudFront distribution domain:
   - Go to CloudFront → Your distribution
   - Copy the **Distribution domain name** (e.g., `d1234abcd.cloudfront.net`)

2. In your DNS provider, create:
   - **CNAME record:**
     - Name: `www`
     - Value: `d1234abcd.cloudfront.net`

   - **A record or CNAME for root domain:**
     - Some providers support ALIAS/ANAME for root domain
     - Otherwise, use CNAME flattening or redirect root to www

---

## Step 7: Deploy Your Website

### First-time Deployment

1. **Create your `.env` file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your values:**
   ```bash
   # Get your bucket name from S3
   AWS_S3_BUCKET=lunarstaircase.com

   # Get your CloudFront distribution ID from CloudFront console
   AWS_CLOUDFRONT_DISTRIBUTION_ID=E1234567890ABC

   AWS_REGION=us-east-1
   ```

3. **Make deploy script executable:**
   ```bash
   chmod +x deploy.sh
   ```

4. **Run deployment:**
   ```bash
   ./deploy.sh
   ```

The script will:
- Upload all files to S3
- Set appropriate cache headers
- Invalidate CloudFront cache
- Display deployment summary

---

## Ongoing: Update Your Website

Whenever you make changes to your website:

```bash
# Edit your files (HTML, CSS, JS, etc.)
git add .
git commit -m "Update homepage content"

# Deploy to AWS
./deploy.sh

# Push to GitHub (optional)
git push
```

Your website will be updated within 5-15 minutes (CloudFront invalidation time).

---

## Cost Breakdown

**Monthly costs for low-traffic site (~1,000 visitors/month):**

- **S3 Storage:** <$0.01 (site is ~5MB)
- **S3 Requests:** <$0.01 (minimal GET requests)
- **CloudFront Data Transfer:** ~$0.50 (5GB at $0.085/GB)
- **CloudFront Requests:** ~$0.01 (10,000 requests)
- **Route 53 Hosted Zone:** $0.50/month (optional)
- **CloudFront Invalidations:** FREE (first 1,000 paths/month)

**Total: $1-3/month**

**Scaling:**
- 10,000 visitors/month: ~$5-8/month
- 100,000 visitors/month: ~$10-15/month

---

## CloudFormation Template (Optional)

For Infrastructure as Code, create `cloudformation.yml`:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Lunar Staircase Website - S3 + CloudFront'

Parameters:
  DomainName:
    Type: String
    Default: lunarstaircase.com
    Description: Your domain name

  CertificateArn:
    Type: String
    Description: ACM Certificate ARN (must be in us-east-1)

Resources:
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Ref DomainName
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: index.html
      PublicAccessBlockConfiguration:
        BlockPublicAcls: false
        BlockPublicPolicy: false
        IgnorePublicAcls: false
        RestrictPublicBuckets: false

  BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref S3Bucket
      PolicyDocument:
        Statement:
          - Sid: PublicReadGetObject
            Effect: Allow
            Principal: '*'
            Action: 's3:GetObject'
            Resource: !Sub '${S3Bucket.Arn}/*'

  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Enabled: true
        DefaultRootObject: index.html
        Aliases:
          - !Ref DomainName
          - !Sub 'www.${DomainName}'
        ViewerCertificate:
          AcmCertificateArn: !Ref CertificateArn
          SslSupportMethod: sni-only
          MinimumProtocolVersion: TLSv1.2_2021
        Origins:
          - DomainName: !GetAtt S3Bucket.DomainName
            Id: S3Origin
            S3OriginConfig:
              OriginAccessIdentity: ''
        DefaultCacheBehavior:
          TargetOriginId: S3Origin
          ViewerProtocolPolicy: redirect-to-https
          AllowedMethods:
            - GET
            - HEAD
          CachedMethods:
            - GET
            - HEAD
          Compress: true
          ForwardedValues:
            QueryString: false
            Cookies:
              Forward: none

Outputs:
  BucketName:
    Value: !Ref S3Bucket
    Description: S3 Bucket Name

  DistributionId:
    Value: !Ref CloudFrontDistribution
    Description: CloudFront Distribution ID

  DistributionDomain:
    Value: !GetAtt CloudFrontDistribution.DomainName
    Description: CloudFront Distribution Domain
```

**Deploy with:**
```bash
aws cloudformation create-stack \
  --stack-name ls-website \
  --template-body file://cloudformation.yml \
  --parameters \
    ParameterKey=DomainName,ParameterValue=lunarstaircase.com \
    ParameterKey=CertificateArn,ParameterValue=arn:aws:acm:us-east-1:123456789:certificate/abc-123
```

---

## Troubleshooting

### "AccessDenied" when accessing website
- Check S3 bucket policy allows public read
- Check CloudFront Origin Access Control is configured correctly
- Verify bucket policy includes CloudFront distribution

### Certificate validation stuck
- Ensure CNAME records are added to DNS correctly
- Wait up to 30 minutes for propagation
- Check in Route 53 or your DNS provider that records exist

### Website shows old content after deployment
- CloudFront cache hasn't invalidated yet (wait 5-15 minutes)
- Check invalidation status: `aws cloudfront get-invalidation --distribution-id YOUR_ID --id INVALIDATION_ID`
- Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)

### Deploy script fails with "aws: command not found"
- AWS CLI not installed or not in PATH
- Run: `which aws` to check installation
- Reinstall AWS CLI

### "Invalid bucket name" error
- Bucket names must be DNS-compliant (lowercase, no underscores)
- Bucket names must be globally unique across all AWS accounts
- Try a different name if taken

### DNS not resolving
- DNS propagation takes 24-48 hours
- Use `dig lunarstaircase.com` to check DNS records
- Verify nameservers are updated at domain registrar

---

## Security Best Practices

1. **Never commit `.env` to git** (already in `.gitignore`)
2. **Use IAM user with minimal permissions** (not root account)
3. **Enable CloudFront security headers** (CSP, HSTS, etc.)
4. **Rotate AWS access keys** every 90 days
5. **Enable CloudTrail logging** for audit trail
6. **Set up billing alerts** in AWS Console

---

## Next Steps

Once deployed:
- [ ] Test website on multiple devices
- [ ] Run Lighthouse audit for performance
- [ ] Set up AWS billing alerts
- [ ] Monitor CloudFront metrics in CloudWatch
- [ ] Add Google Analytics or analytics tool (optional)
- [ ] Test SSL certificate (https://www.ssllabs.com/ssltest/)

---

## Useful Commands

```bash
# Check deployment status
aws cloudfront get-distribution --id YOUR_DISTRIBUTION_ID

# List invalidations
aws cloudfront list-invalidations --distribution-id YOUR_DISTRIBUTION_ID

# Sync files (without invalidation)
aws s3 sync . s3://your-bucket-name --exclude ".git/*"

# Get bucket size
aws s3 ls s3://your-bucket-name --recursive --human-readable --summarize

# View CloudFront logs
aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,DomainName,Status]'
```

---

## Support

- AWS Documentation: https://docs.aws.amazon.com
- AWS Support: https://console.aws.amazon.com/support
- Community: https://repost.aws/

---

**Questions?** Feel free to ask for help with any step!
