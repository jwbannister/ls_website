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
│   └── styles.css          # All styles (single file is fine for 3 pages)
├── js/
│   └── main.js             # Minimal JS (mobile nav, form handling if needed)
├── images/
│   ├── logo-horizontal.png # For header
│   ├── logo-stacked.png    # For hero/footer
│   ├── logo-icon.png       # Standalone icon
│   └── projects/           # Project screenshots
├── favicon.ico             # Extract from micro icon in logo suite
├── logo/                   # Original logo assets
│   └── logos.png
└── .ai/                    # AI documentation (don't deploy)
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

### S3 + CloudFront Setup
1. Create S3 bucket (website hosting enabled)
2. Upload all files except `.ai/` and `.git/`
3. Create CloudFront distribution pointing to S3
4. Configure custom domain (lunarstaircase.com)
5. SSL certificate via ACM

### Domain Setup
- User owns lunarstaircase.com
- Point DNS to CloudFront
- Redirect www to apex (or vice versa)

*Detailed deployment steps can be added when ready.*

## Open Questions Before Building

1. **Project content**: What projects to showcase? Need:
   - Project names
   - Descriptions
   - Screenshots/images
   - Links (if applicable)
   - Or: should agent use placeholder content?

2. **Contact form**: Which option - Formspree, email only, or AWS Lambda?

3. **Additional content**:
   - Company tagline?
   - About text?
   - Any team info?
   - Social media links?

4. **Logo assets**: Need to extract individual PNG/SVG files from `logos.png`:
   - Horizontal version for header
   - Stacked version for hero
   - Icon for favicon

## Quick Start for Building Agent

1. Read all files in `.ai/` directory
2. Review logo suite at `/logo/logos.png`
3. Get answers to open questions from user
4. Extract logo variants as separate files
5. Create file structure
6. Build Home page first (establish patterns)
7. Build Projects and Contact pages
8. Test responsive behavior
9. Prepare for deployment
