# Build Guide

## Tech Stack

**Pure static HTML/CSS/JS** - no frameworks, no build step.

### Why This Approach
- 3 pages, infrequent updates, AI-maintained
- No dependencies to update or break
- Maximum longevity
- Fast load times
- Cheap hosting (S3 + CloudFront)

## File Structure

```
ls_website/
├── index.html              # Home page
├── projects.html           # Projects/portfolio page
├── contact.html            # Contact page
├── css/
│   └── styles.css          # All styles
├── js/
│   └── main.js             # Minimal JS (mobile nav toggle)
├── logo/
│   ├── logo_horizontal.png # Header navigation logo
│   ├── logo_vertical.png   # Hero section logo
│   └── logo_picture.png    # Icon only (for favicon, etc.)
└── .ai/                    # AI documentation (excluded from deploy)
```

## Implementation Notes

### HTML
- Use semantic elements: `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`
- Include proper meta tags (viewport, description, OG tags)
- Link Google Fonts in `<head>`

### CSS
- Use CSS custom properties for colors/spacing (defined in DESIGN_SPEC.md)
- Mobile-first approach
- Flexbox/Grid for layout
- No CSS frameworks - write clean, readable CSS

### JavaScript
- Minimal - only what's needed:
  - Mobile navigation toggle
  - Form handling (if using Formspree)
  - Optional: smooth scroll, intersection observer for animations
- No jQuery or other libraries

## Page Content Structure

### Home (`index.html`)
1. **Hero**: Large logo/tagline, one-line company description, CTA
2. **About section**: Who Lunar Staircase is, what they do
3. **Services/focus**: Interactive training materials for K-12
4. **Featured projects**: 2-3 project cards (link to Projects page)
5. **CTA**: Contact prompt
6. **Footer**

### Projects (`projects.html`)
1. **Header**: Page title, brief intro
2. **Project grid**: Cards for each project
   - Image/thumbnail
   - Title
   - Description
   - Technologies used
   - Link (external or detail page)
3. **Footer**

### Contact (`contact.html`)
1. **Header**: Page title
2. **Contact info**: Email, possibly phone
3. **Contact form** (if using Formspree) or just prominent email
4. **Footer**

## Contact Form Options

### Option A: Formspree (Recommended for simplicity)
```html
<form action="https://formspree.io/f/{form-id}" method="POST">
  <input type="email" name="email" required>
  <textarea name="message" required></textarea>
  <button type="submit">Send</button>
</form>
```
Free tier: 50 submissions/month. User needs to create account and get form ID.

### Option B: Display Email Only
Just show email address with mailto link. Simplest, no third party.

### Option C: AWS Lambda + SES
More complex, requires AWS setup. Only if user wants full control.

**Decision needed from user.**

## Deployment (AWS)

### Infrastructure Overview

| Resource | Value |
|----------|-------|
| S3 Bucket | `ls-website-prod` |
| CloudFront Distribution ID | `E2LJTK8QDUV5FR` |
| CloudFront Domain | `d1naqd9g8n6mi2.cloudfront.net` |
| ACM Certificate | `arn:aws:acm:us-east-1:293477658025:certificate/a5defcaa-1026-4435-8f4b-1085109fb253` |
| AWS Profile | `bannisterjw` |
| Region | `us-east-1` |

### Live URLs

- https://lunarstaircase.com
- https://www.lunarstaircase.com

### DNS (Cloudflare)

Both `lunarstaircase.com` and `www.lunarstaircase.com` are CNAME records pointing to `d1naqd9g8n6mi2.cloudfront.net` with proxy disabled (DNS only).

### Deploy Updates

**1. Sync files to S3:**
```bash
aws s3 sync /Users/john/lunarstaircase/ls_website s3://ls-website-prod \
  --exclude ".git/*" \
  --exclude ".DS_Store" \
  --exclude ".ai/*" \
  --exclude ".cursor/*" \
  --exclude ".claude/*" \
  --profile bannisterjw
```

**2. Invalidate CloudFront cache (if needed):**
```bash
aws cloudfront create-invalidation \
  --distribution-id E2LJTK8QDUV5FR \
  --paths "/*" \
  --profile bannisterjw
```

### Architecture

```
                    ┌─────────────────┐
                    │   Cloudflare    │
                    │   (DNS only)    │
                    └────────┬────────┘
                             │
                             ▼
┌────────────────────────────────────────────────┐
│              CloudFront (CDN)                  │
│  - HTTPS termination (ACM certificate)        │
│  - Caching                                    │
│  - Gzip compression                           │
│  - Origin Access Control (OAC)                │
└────────────────────┬───────────────────────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │   S3 Bucket         │
          │   ls-website-prod   │
          │   (private)         │
          └─────────────────────┘
```

### Security Notes

- S3 bucket is **not** publicly accessible
- CloudFront uses Origin Access Control (OAC) to securely access S3
- Only CloudFront can read from the bucket (via bucket policy)
- HTTPS enforced (HTTP redirects to HTTPS)
- TLS 1.2 minimum

## Remaining Tasks

1. **Project content**: Replace placeholder project cards with real projects when available
2. **Favicon**: Create favicon from `logo_picture.png`
3. **OG image**: Create social sharing image for meta tags
