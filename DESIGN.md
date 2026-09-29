# Visp Design System

## Direction

Visp uses a calm, technical interface built with Flutter. The visual language is a
Flutter adaptation of **shadcn/ui** token semantics (semantic color roles, OKLCH-derived
neutrals, ring focus, bordered surfaces) combined with **Minimalism & Swiss Style**
direction (spacious, grid-based, high contrast, geometric, essential).

Direction was resolved with the `ui-ux-pro-max` skill for a *privacy/security tool,
dark mode, mobile*: slate neutrals, restrained motion, one primary action per screen,
and a green "connected" accent. The brand element is **Blup Visp**: a solid abstract
shape with a moving perimeter. It is the only decorative motion on the home screen and
always accompanies a readable text status.

Mynaui Icons stays the icon source: outline-based, one consistent stroke weight, 20 px in
rows, 24 px in prominent actions, 16 px inside chips. Never mix filled and outline
variants in one navigation state. Do not use emoji as structural icons.

## Tokens

shadcn-style semantic roles. Every token has a dark and a light value; components read
roles, never raw colors. Dark values are shadcn *slate*; the brand/primary role is green
(connected state).

### Dark

| Role               | Value                  | Use                                  |
|--------------------|------------------------|--------------------------------------|
| `background`       | `#020617` slate-950    | app canvas                           |
| `foreground`       | `#F8FAFC` slate-50     | body text on background              |
| `card`             | `#111827` gray-900     | cards, list groups                   |
| `card-foreground`  | `#F8FAFC`              | text on card                         |
| `popover`          | `#111827`              | sheets, menus                        |
| `popover-foreground` | `#F8FAFC`            | text on popover                      |
| `primary`          | `#22C55E` green-500    | main CTA, selected state             |
| `primary-foreground` | `#052E16` green-950  | text on primary                      |
| `secondary`        | `#1E293B` slate-800    | secondary buttons, muted blocks      |
| `secondary-foreground` | `#F8FAFC`           | text on secondary                    |
| `muted`            | `#1E293B` slate-800    | inactive chips, disabled fills       |
| `muted-foreground` | `#94A3B8` slate-400    | secondary text, captions             |
| `accent`           | `#1E293B` slate-800    | hover/press fills                    |
| `accent-foreground` | `#F8FAFC`             | text on accent                       |
| `destructive`      | `#7F1D1D` red-950-tint | destructive surfaces                 |
| `destructive-foreground` | `#FCA5A5`         | text on destructive                  |
| `border`           | `#1E293B` slate-800    | all 1 px borders/dividers            |
| `input`            | `#334155` slate-700    | input borders                        |
| `ring`             | `#22C55E` brand        | 2 px focus ring                      |
| `warning`          | `#E7C46A`              | warnings, beta channel               |
| `info`             | `#82B8E8`              | informational chips                  |
| `blupConnected`    | `#6FBF93`              | connected Blup Visp (spec 4.1.3)     |
| `blupError`        | `#E57B6E`              | error Blup Visp (spec 4.1.5)         |
| `blupIdle`         | `#4A5A4F`              | idle Blup Visp                       |

### Light

Warm near-white canvas with the same roles inverted; `background` `#F8FAFC`,
`card` `#FFFFFF`, `secondary`/`muted` `#F1F5F9`, `muted-foreground` `#475569`,
`border` `#E2E8F0`, `input` `#CBD5E1`, `primary` `#16A34A` with `#FFFFFF` foreground,
`ring` `#16A34A`. Never use color as the only status signal: text + icon + color.

### Shape and layout

```text
Radius:            4 sm / 6 md / 8 lg / 12 xl / 16 2xl   (card default lg=8)
Spacing:           4 px base grid; common gaps 8, 12, 16, 24, 32
Control heights:   36 compact, 44 regular, 52 prominent
Focus ring:        2 px ring color, 3 px offset outside the control (shadcn ring)
Touch targets:     44 pt minimum (48 dp on Android), 8 dp+ gaps, safe-area aware
Border weight:     1 px everywhere; elevation via border + surface step, not shadow
```

## Typography

Primary typeface is **Inter** (weights 400/500/600/700); the system sans is the offline
fallback on every platform (Roboto on Android, SF Pro on iOS/macOS, Segoe UI on
Windows). Swiss rules apply: medium/semibold headings, regular 1.4–1.5 body, short line
lengths, left-aligned, no all-caps paragraphs. Numbers for ping, traffic, limits and
session time use tabular figures. Type scale: 12 / 14 / 16 / 18 / 22 / 28.

## Components (shadcn variant contract)

- **Button:** `primary` (filled green), `secondary` (bordered), `tertiary` (text),
  `destructive` (danger tint + confirmation dialog). One primary CTA per screen; loading
  state disables the control and shows progress.
- **Input:** label above field, helper text below, error text with recovery path under
  the field, `ring` focus, no placeholder-only labels, semantic keyboards.
- **Card:** one surface for one decision; no cards inside cards; divider for rows.
- **Chip/Badge:** status, protocol, beta channel and permission labels; never replace
  explanatory text; removable values disclose overflow instead of shrinking.
- **Switch:** immediate visual response; haptics follow the global setting.
- **List row:** icon, title, one-line description, trailing state/action; min 52 px.
- **Tabs:** underline indicator (`Протоколы` | `Управление`); active tab uses
  `primary` underline as in spec 8.
- **Sheet/Dialog:** animate from the trigger source; swipe-down dismiss on mobile;
  confirm before dismissing with unsaved changes.
- **Toast:** auto-dismiss 3–5 s, no focus steal, includes a next action on error.

## Protocols (spec section 3)

Starter set of four connections, shipped as first-class profiles:

1. **AmneziaWG** — main fast option masking WireGuard fingerprints; default choice.
2. **Hysteria 2** — for mobile/lossy links; UDP restrictions can block it.
3. **olcRTC** — restricted-network variant using a WebRTC-related transport; fitness is
   proven in practice, not by name.
4. **XRay VLESS/REALITY** — alternative for networks where others are limited; XRay is
   the engine, VLESS/REALITY the connection method.

Importers parse `vless://` (incl. REALITY params `pbk`, `sid`, `fp`, `sni`, `flow`),
`hysteria2://` (`auth`, `obfs`, `sni`, `pinSHA256`), WireGuard/AmneziaWG `.conf` (INI,
incl. AmneziaWG junk-packet params `Jc/Jmin/Jmax/S1/S2/H1-H4`), and `olcrtc://` links.
Other formats (VMess, Trojan, Shadowsocks incl. 2022, TUIC, AnyTLS, NaiveProxy, OpenVPN
+ Cloak, ShadowTLS, Snell, plain WireGuard, SOCKS5/HTTP(S)) arrive with their engines.

**Engine states** (spec 3.4): `notInstalled` (import saves the profile anyway; download
starts on first connect), `downloading`, `ready`, `needsUpdate` (new verified stable
version in catalog), `unsupported`. Three distinct things are never conflated: engine
present on device, protocol downloading, protocol supported.

## Screens

### Home
Blup Visp occupies the visual center. Status text and the primary connect button sit
directly below it. A protocol selector button sits above/beside the CTA (spec 8.1);
secondary details show protocol, endpoint and session time. First viewport stays free of
dense cards.

### Servers
Grouped expandable rows by host. Each protocol is a row under its host with port,
readiness and profile settings. Search and filters stay above the list; grouping is
preserved. Switching server/protocol during a session warns about reconnect.

### Server details
Tabs `Протоколы` | `Управление`. Protocols tab lists profiles with short descriptions and
engine state chips; Management tab covers owner/agent/version actions.

### Studio
Same shell plus owner badge and scope banner (organization, server group, role).
Control Plane, agent, codes and audit appear only here. Empty state explains how to
connect the first server.

### Plugins
Installed, available and required dependencies in separate sections; each plugin row has
source, version, permissions and health; permission sheet with full dependency tree
before install.

### Settings
Grouped by Connection, DNS & routes, Updates, Haptics, Plugins, Privacy, About. Control
Plane and server agent are not settings for ordinary users.

## Motion and haptics

160–220 ms for navigation and sheets, 240–360 ms for Blup perimeter changes. Respect
reduced-motion everywhere. Nav switching: light impact; plus and destructive
confirmations: medium; errors: notification feedback. No haptic API → stay silent.
Motion conveys cause-effect (state changes animate; nothing is decorative-only), exits
~60–70 % of enter duration, animations are interruptible and never block input.

## Responsive rules

Phone: one column, bottom navigation, sheets for detail. Tablet: two-pane server and
plugin layouts. Desktop: max content width 1200 px, persistent side navigation allowed,
Studio scope stays visible. Interactive targets at least 44 pt; no horizontal scroll on
mobile; content respects safe areas and system gestures.

## Accessibility

Every icon button has a tooltip/accessible label. Contrast meets WCAG AA (4.5:1 text,
3:1 large/non-text). Focus order follows visual order; focus ring is always visible and
never obscured. Status is conveyed by text + icon + color. Keyboard navigation and
screen-reader semantics are required on desktop and mobile controls.

## Flutter implementation notes

`VispTheme` exposes `SemanticColors` (shadcn roles above), `AppTextStyles`, `AppSpacing`,
`AppRadius` and `AppControlHeight`. Mynaui icons sit behind the `VispIcon` adapter.
Protocol profiles carry `EngineState`; the connection layer is an interface so a real
native engine (gomobile/VPN service) can replace the mock without touching UI code.
