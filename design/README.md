# Design Reference

Internal reference material. **None of it is served, and none of it should be
copied into the site verbatim.**

These are artboards from the design exploration that settled how this site
looks: standalone HTML mockups of a whole example page, each in one candidate
direction. They are the authority on *values* (the grid, the spacing, the
tones, the type scale) and they are useful to read while building the real
pages. They are not the built site, and where the two disagree, the built site
is what ships.

| File | What it shows |
| --- | --- |
| `MarginaliaBarLight.dc.html`, `MarginaliaBarDark.dc.html` | The ratified desktop layout, both themes |
| `KnobsColumnLight.dc.html`, `KnobsColumnDark.dc.html` | The same layout plus the column bench, which lands much later. Carries every value the pair above does |
| `MarginaliaCrumbLight.dc.html` | The mobile crumb menu |
| `canvas.json` | The exploration's page index, for orientation |

## Two Things Not To Copy

Both are scaffolding from the canvas these were drawn on, and both break rules
the site keeps:

- **The `fonts.googleapis.com` stylesheet link.** Nothing the running site
  loads comes from a third party. Fonts are self-hosted and served from this
  origin.
- **The `<script src="./support.js">` tag.** That file was never copied here, so
  the boards do not render as standalone files. Open them for their inline CSS,
  which is intact and is the part worth reading.

`.dockerignore` keeps this directory out of the image.
