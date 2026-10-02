# Visp Design System

## Direction

Visp is a Flutter adaptation of the **Amnezia Client** visual language. The reference is
the shared Qt/QML client from [amnezia-vpn/amnezia-client](https://github.com/amnezia-vpn/amnezia-client),
specifically `client/ui/qml/Modules/Style/AmneziaStyle.qml`.

The direction is deliberately *not* shadcn. The earlier slate/green token set is retired.
What Visp keeps from it is only the plumbing: semantic color roles, so components never
read raw hex values, and a single source of truth for both themes.

Three rules define the result:

1. **Flat surfaces, hairline borders, no shadows.** Depth comes from a 1 px border and
   the background/card contrast, not from elevation. The single exception is the amber
   glow around the active Blup element.
2. **Amber is the only accent.** `#FBB26A` marks action and selection. Success is green,
   error is red, and neither is allowed to become a second brand accent.
3. **The brand element is Blup Visp.** A soft abstract figure with a moving perimeter and
   a progress arc. It is the only decorative motion on the home screen and always
   accompanies a readable text status.

MynaUI stays the icon source: outline at rest, solid when a state is active, one stroke
weight. Do not mix variants inside one navigation state, and do not use emoji as
structural icons.

## Tokens

Every role has a dark and a light value. Components read roles, never raw colors.

### Dark (Amnezia dark, default)

| Role               | Value     | Use                                    |
|--------------------|-----------|----------------------------------------|
| `background`       | `#0E0E11` | app canvas                             |
| `foreground`       | `#D7D8DB` | body text on background                |
| `card`             | `#1C1D21` | cards, list groups, sheets             |
| `popover`          | `#1C1D21` | dialogs, menus                         |
| `primary`          | `#FBB26A` | main CTA, selected state, Blup ring    |
| `primaryPressed`   | `#A85809` | pressed accent                         |
| `primaryForeground`| `#1C1D21` | text on primary                        |
| `muted`            | `#242528` | inactive chips, disabled fills         |
| `mutedForeground`  | `#878B91` | secondary text, icons at rest          |
| `border`           | `#2C2D30` | hairline borders and dividers          |
| `borderStrong`     | `#3A3B3F` | borders that must read as interactive  |
| `warning`          | `#F2C879` | warnings, maintenance notices          |
| `destructive`      | `#EB5757` | errors and destructive actions         |
| `success`          | `#3FBF6B` | connected state                        |

### Light

Light is a Visp extension, not an Amnezia mode. It keeps the same role graph with
inverted surfaces so the theme switch stays honest. The amber accent darkens to `#9A5F14`
— it clears WCAG AA at 5.2:1 on white, which matters because the accent is used both as
small text (active nav label at 11 px, selected row) and as a button fill under a white
label. `primaryBright` stays at `#D9963F` for non-text decoration only.

### Compatibility aliases

`surface1`, `surface2`, `textPrimary`, `textSecondary`, and `danger` remain as aliases on
`SemanticColors`. They exist so the parser/engine code and older call sites keep working;
new UI code must use the canonical role names above.

## Radius and spacing

Amnezia uses one primary radius and one secondary radius. Visp follows exactly.

| Token                    | Value | Use                                  |
|--------------------------|-------|--------------------------------------|
| `AppRadius.sm`           | 8     | buttons, chips, inputs, small sheets |
| `AppRadius.s` / `.sAll`  | 16    | cards, list groups, dialogs, nav bar |
| `AppRadius.m` / `.mAll`  | 22    | medium surfaces, alerts             |
| `AppRadius.l` / `.lAll`  | 30    | large surfaces, bottom sheets       |
| `AppSpacing.xs`          | 4     | icon-to-label gaps                   |
| `AppSpacing.s`           | 8     | within-component gaps               |
| `AppSpacing.m`           | 12    | list padding, tight stacks          |
| `AppSpacing.l`           | 16    | card padding, section rhythm         |
| `AppSpacing.xl`          | 24    | screen gutters                      |
| `AppSpacing.xxl`         | 32    | between sections                    |

Note the deliberate overlap: spacing `l` (16) equals radius `s` (16). Card padding and
card radius therefore read as the same measure, which is what makes the Amnezia card feel
settled rather than cramped.

Nesting rule: a component inside a card uses radius 8, never 16. Equal radii read as a
squashed corner; the difference is what makes nesting look intentional.

Rows and controls are 56 px tall. That is the Amnezia row height and it is also the
minimum comfortable touch target.

## Typography

System sans stack, no custom families. Scale is tight because Amnezia leans on weight and
color for hierarchy, not on size jumps.

| Role          | Size / line height | Weight | Use                    |
|---------------|--------------------|--------|------------------------|
| `h1Strong`    | 28 / 34            | 700    | screen titles          |
| `h2Strong`    | 22 / 28            | 700    | dialog titles          |
| `title`       | 16 / 22            | 600    | card titles, list items |
| `body`        | 15 / 21            | 400    | body text, row titles  |
| `label`       | 13 / 18            | 400    | descriptions, helper   |
| `badge`       | 11 / 14            | 500    | chips, captions, nav labels |
| `button`      | 15 / 20            | 600    | button labels          |

Tabular figures for counters and traffic numbers. Uppercase section headers use `badge`
with `letterSpacing: 0.8`.

## Components

### VispButton

Flat, no shadow, radius 8. Heights come from `AppControlHeight`: 36 compact, 48 regular,
56 prominent. Pressed state fills with `accent` (secondary, tertiary) or drops to
`primaryPressed` (primary). Disabled primary buttons fall back to `muted`/`mutedForeground`
instead of fading out, so the button keeps its shape. Destructive actions go through
`VispButton.destructive`, which requires confirmation. Double-tap is guarded while the
confirmation dialog is open.

### VispCard

Radius 16, 1 px `border`, `card` background. No shadow — depth comes from the border and
the background/card contrast. `selected` switches the border to the accent. Cards never
nest; use `VispListGroup` for a set of rows.

### VispFocusRing

Keyboard focus is a 1 px accent outline plus a 2 px inset, not a thick halo. It stays
inside the control's bounds so focus never changes layout size. Never remove it.

### VispChip

Radius 8, `badge` type, 11 px label, optional 13 px icon. Tone carries meaning: neutral,
accent, warning, danger, info, beta. A chip never replaces an explanatory sentence.

### VispListRow / VispListGroup

56 px minimum row, radius 16 group with 1 px border and inset dividers. Selected row takes
the accent icon and label color.

### Blup

Perimeter stroke 1.2 px compact / 1.8 px full, animated wobble always present, soft
fill. During preparing/checking/connecting/reconnecting an amber arc sweeps the outer
ring — that arc is the only progress indicator while the action is busy, so the center
button shows the icon alone and does not duplicate it with a spinner.

### Navigation

Fixed 68 px bar, radius 16, `card` surface. Active destination uses a solid MynaUI icon
in amber plus a muted fill and accent border; inactive is outline in `mutedForeground`.
Labels never wrap or clip: they scale down as a whole via `FittedBox`.

## Motion

Restrained and functional. Interaction transitions are 200 ms with `Curves.easeOut`; no
spring overshoot, because Amnezia's motion reads as mechanical. The Blup perimeter is the
only ambient animation.

`prefers-reduced-motion` (and Android `disableAnimations` / `accessibleNavigation`) freezes
the Blup at a fixed pose. The progress arc and the directional wave are suppressed in that
mode, because a frozen arc is indistinguishable from a hung connection; the text status next
to the figure carries the state instead.

## Accessibility

Body text on `background` and on `card` clears WCAG AA. Muted text is used only for
secondary information at 13 px or larger, never for the only label of a control. Every
icon-only control has a tooltip and a semantic label. Focus rings are never suppressed.
Touch targets are at least 44 px, with 56 px preferred for rows.

## Glass

`liquid_glass_easy` is an optional layer, not the identity of the interface. Glass mode
offers `none` and `regular` only; the matte variant was removed because it muddied the
hairline borders. When glass is off, every component must still meet the contrast rules
above on its flat surface.