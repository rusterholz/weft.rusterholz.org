# weft.rusterholz.org

Every example that ships with [Weft](https://github.com/rusterholz/weft),
running live, beside the code that rendered it.

**This is early:** one of the twenty-one examples is running so far. The rest
arrive a batch at a time.

Weft's documentation shows you what an interaction looks like in source. This
site runs that same source and puts the two side by side, so you can click the
thing and read what made it happen. The code shown on a page is read from the
file at render time, so it cannot drift from what actually ran.

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
| `examples/` | The examples themselves, one directory per documented Weft version |
| `app/pages/` | The site's own pages |
| `app/chrome/` | Site components, the parts pages are built from |
| `app/data/` | Who a visitor is, their theme, their own expiring copy of an example's data, and the catalog |
| `config/` | Boot: autoloading, then Weft's configuration |
| `public/` | Static assets, served from this origin |
| `spec/` | Unit specs laid out like the code, plus request specs driving the whole stack |
| `bin/` | Setup, the dev server, the checks, and the asset fetchers |
| `rubocop/` | House lint rules this project loads |
| `design/` | Internal design reference, never served |
| `docs/development.md` | Setup, testing, and the rules this repo keeps |

## License

MIT, the same as Weft itself. See [LICENSE.txt](LICENSE.txt).

The fonts in `public/fonts/` are not this repository's: they are licensed under
the SIL Open Font License 1.1, and [public/fonts/LICENSE.md](public/fonts/LICENSE.md)
names each one and where it came from.
