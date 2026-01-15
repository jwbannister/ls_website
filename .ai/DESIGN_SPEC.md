# Design Specification

## Color Palette

Based on the logo suite in `/logo/logos.png`:

| Token | Color | Usage |
|-------|-------|-------|
| `--color-bg-primary` | `#0a1628` | Main page background (deep navy) |
| `--color-bg-secondary` | `#132238` | Cards, sections, elevated surfaces |
| `--color-accent-warm` | `#f4b942` | Moon yellow - CTAs, highlights, important elements |
| `--color-accent-cool` | `#4ecdc4` | Cyan/teal - secondary accents, links, "STAIRCASE" text |
| `--color-text-primary` | `#ffffff` | Main body text |
| `--color-text-secondary` | `#94a3b8` | Muted text, descriptions |
| `--color-text-accent` | `#4ecdc4` | Accent text (matches cyan) |

*Note: Extract exact hex values from logo file if these need adjustment.*

## Typography

Use **Google Fonts** - choose one:
- **Poppins** - Modern geometric, clean (recommended)
- **Nunito** - Slightly softer, rounded, friendly

```css
/* Recommended weights */
font-family: 'Poppins', sans-serif;
/* 400 - body text */
/* 500 - subheadings */
/* 600 - headings */
/* 700 - logo text, bold emphasis */
```

### Type Scale

| Element | Size | Weight |
|---------|------|--------|
| H1 | 3rem (48px) | 700 |
| H2 | 2rem (32px) | 600 |
| H3 | 1.5rem (24px) | 600 |
| Body | 1rem (16px) | 400 |
| Small | 0.875rem (14px) | 400 |

## Layout

- **Max content width**: 1200px
- **Padding**: 1.5rem (mobile), 3rem (desktop)
- **Section spacing**: 6rem vertical between major sections
- **Card border-radius**: 1rem
- **Consistent 8px grid** for spacing

## Components

### Header/Navigation
- Fixed or sticky at top
- Horizontal logo variant (icon + wordmark)
- Nav links: Home, Projects, Contact
- Mobile: hamburger menu

### Hero Section (Home)
- Large stacked logo or tagline
- Brief company description
- CTA button (warm yellow accent)

### Project Cards
- Dark card (`--color-bg-secondary`)
- Thumbnail/screenshot
- Project title
- Brief description
- Tech tags (optional)
- Link to learn more or external URL

### Footer
- Icon-only logo
- Copyright
- Social links (if any)
- Back to top (optional)

## Responsive Breakpoints

```css
/* Mobile first */
@media (min-width: 640px) { /* Tablet */ }
@media (min-width: 1024px) { /* Desktop */ }
```

## Visual Effects (Optional Enhancements)

- Subtle gradient overlays on dark backgrounds
- Moon glow effect on accent elements
- Gentle hover transitions (0.2s ease)
- Water ripple or reflection motifs for section dividers

## Assets Needed

| Asset | Location | Status |
|-------|----------|--------|
| Logo suite | `/logo/logos.png` | ✅ Exists |
| Favicon (micro icon) | `/favicon.ico` | ❌ Need to extract |
| Project screenshots | `/images/projects/` | ❌ Need from user |
| OG image | `/images/og-image.png` | ❌ Need to create |

## Accessibility

- Ensure 4.5:1 contrast ratio for text
- Focus states on all interactive elements
- Alt text on all images
- Semantic HTML structure
- Skip navigation link
