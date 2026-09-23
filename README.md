# weft.rusterholz.org

Every example that ships with [Weft](https://github.com/rusterholz/weft),
running live, beside the code that rendered it.

**This is early. Nothing is built yet** except the scaffolding and one
placeholder page. What follows is what the site is being built to be, not a
description of what it currently does.

Weft's documentation shows you what an interaction looks like in source. This
site will run that same source and put the two side by side, so you can click
the thing and read what made it happen. The code shown on a page is to be read
from the file at render time, so that it cannot drift from what actually ran.

It is a Weft application itself, which is the other half of the point: the
catalog is built out of the framework it documents.

## Running It

Requires Ruby 3.4.7 (see `.ruby-version`).

```bash
bin/setup
bin/dev      # http://127.0.0.1:9393
```

## Layout

| Path | What lives there |
| --- | --- |
| `app/pages/` | The site's own pages |
| `config/` | Boot: autoloading, then Weft's configuration |
| `public/` | Static assets, served from this origin |
| `spec/` | Request specs, driving the whole stack |
| `bin/` | Setup, the dev server, the checks, and the asset fetcher |
| `rubocop/` | House lint rules this project loads |
| `design/` | Internal design reference, never served |
| `docs/development.md` | Setup, testing, and the rules this repo keeps |

## License

MIT, the same as Weft itself. See [LICENSE.txt](LICENSE.txt).
