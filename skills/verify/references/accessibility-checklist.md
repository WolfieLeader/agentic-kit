# Accessibility Checklist

Domain reference for verify extension reviewers. Load when reviewing UI components, forms, navigation, or any user-facing interface.

## Keyboard Navigation

- All interactive elements reachable via Tab
- Focus order matches visual layout
- Focus indicator visible (no outline: none without replacement)
- Escape closes modals/popups, returns focus to trigger
- No keyboard traps (user can always Tab out)

## Semantic HTML

- Headings: logical hierarchy (h1 → h2 → h3), no skipped levels
- Landmarks: main, nav, header, footer used appropriately
- Lists: ul/ol for grouped items, not div soup
- Buttons vs links: button for actions, anchor for navigation
- Tables: th with scope, caption for data tables

## ARIA

- aria-label on icon-only buttons and links
- aria-live regions for dynamic content updates (toasts, alerts)
- aria-expanded on toggleable controls (accordions, dropdowns)
- Role attributes only when no semantic HTML equivalent exists
- aria-hidden on decorative elements

## Forms

- Every input has a visible, associated label (not just placeholder)
- Error messages linked to inputs via aria-describedby
- Required fields marked with aria-required and visual indicator
- Form validation errors announced to screen readers
- Autocomplete attributes on common fields (name, email, address)

## Visual

- Color contrast: minimum 4.5:1 for normal text, 3:1 for large text
- Information not conveyed by color alone (add icons, patterns, or text)
- Text resizable to 200% without content loss
- Reduced motion respected (@media prefers-reduced-motion)
