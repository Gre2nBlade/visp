# Visp Design System

## Direction

Visp uses a calm, technical interface built with Flutter. The visual language takes cues from HeroUI: clear component hierarchy, compact controls, rounded surfaces, visible focus states, responsive spacing and restrained motion. Mynaui Icons is the icon source; icons stay outline-based and use one consistent stroke weight.

The brand element is Blup Visp: a solid abstract shape with a moving perimeter. It is the only decorative motion on the home screen and always accompanies a readable text status.

## Tokens

```text
Background:       #0B0D0F
Surface 1:         #12161A
Surface 2:         #191F24
Border:            #2B343B
Text primary:      #F3F6F4
Text secondary:    #AAB6B0
Accent sage:       #8FD3AA
Accent bright:     #B6F0C9
Warning:           #E7C46A
Danger:            #EF8A7D
Info:              #82B8E8

Radius:            8 / 12 / 16 / 24
Spacing:           4 px base grid; common gaps 8, 12, 16, 24, 32
Control heights:   36 compact, 44 regular, 52 prominent
Focus ring:        2 px accent at 3 px outside the control
```

Light theme reuses the same semantic tokens with a warm near-white background and dark text. Never use color as the only status signal.

## Typography

Use a neutral sans family available on each platform. Headings use medium weight and short line lengths; body text uses regular weight and 1.4 line height. Numbers for ping, traffic and limits use tabular figures. Avoid all-caps paragraphs.

## Components

- **Button:** primary filled sage, secondary bordered, tertiary text. Every destructive action uses a danger confirmation dialog.
- **Input:** label above field, helper/error text below, visible focus ring, no placeholder-only labels.
- **Card:** one surface for one decision. Avoid cards inside cards. Use a divider for secondary rows.
- **Chip:** status, protocol, beta channel and permission labels. Chips never replace explanatory text.
- **Switch:** immediate visual response; haptic feedback follows the global setting.
- **List row:** icon, title, one-line description, trailing state/action. Minimum 52 px height.
- **Bottom navigation:** HeroUI-like floating bar with Home, Servers, Settings and optional Studio/Proxy. Mynaui icons: `home`, `server`, `settings`, `plus`, `shield-check`, `plug`, `database`.
- **Sheet:** use for profile details and actions; keep the current context visible.
- **Toast:** confirms completed local actions; errors include a next action.

## Screens

### Home

Blup Visp occupies the visual center. Status text and the primary connect button sit directly below it. Secondary details show protocol, endpoint and session time. Keep the first viewport free of dense cards.

### Servers

Use grouped expandable rows by host. Each protocol is a row under its host. Search and filters stay above the list. The selected profile is shown with a check icon and text.

### Studio

Studio uses the same shell but adds an owner badge and a clear scope banner: organization, server group and role. Control Plane, agent, codes and audit appear only here. Empty state explains how to connect the first server.

### Plugins

Show installed, available and required dependencies in separate sections. Each plugin row includes source, version, permissions and health. Before installation show a permission sheet with the complete dependency tree.

### Settings

Group settings by Connection, DNS & routes, Updates, Haptics, Plugins, Privacy and About. Control Plane and server agent are not settings for ordinary users.

## Icons

Use Mynaui Icons by semantic meaning, not by decoration. Recommended mappings:

```text
Home       home
Servers    server
Settings   settings
Studio     dashboard / building-2
Plugins    puzzle / plug
DNS        globe-2
WARP       route
Security   shield-check
Updates    refresh-ccw
Beta       flask-conical
Error      circle-alert
Success    circle-check
```

Icons are 20 px in rows, 24 px in prominent actions and 16 px inside chips. Do not mix filled and outline variants in one navigation state.

## Motion and haptics

Use 160–220 ms for navigation and sheets, 240–360 ms for Blup perimeter changes. Respect reduced-motion. Nav switching triggers light impact; plus and destructive confirmations use medium impact; errors use notification feedback. If the platform has no haptic API, keep the interaction silent.

## Responsive rules

Phone: one column, bottom navigation, sheets for detail. Tablet: two-pane server and plugin layouts. Desktop: max content width 1200 px, persistent side navigation is allowed, but Studio scope remains visible. Interactive targets are at least 44 px.

## Accessibility

Every icon button has a tooltip/accessible label. Contrast meets WCAG AA. Focus order follows visual order. Status is conveyed by text plus icon plus color. Keyboard navigation and screen readers are required on desktop and mobile semantic controls.

## Flutter implementation notes

Create a `VispTheme` with semantic colors, `AppTextStyles`, spacing and radius constants. Wrap Mynaui icons behind a small `VispIcon` adapter so icon replacements do not spread through feature code. Build components as reusable widgets and keep plugin screens inside the same theme contract.
