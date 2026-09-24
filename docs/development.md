# Development Guide

Setting up, running, and checking this site. For what the site *is*, see the
[README](../README.md).

## Setup

```bash
bin/setup     # bundle install
bin/dev       # http://127.0.0.1:9393
bin/check     # specs, lint, doc drift
```

`bin/dev` runs with `RACK_ENV=development`, which turns on Zeitwerk reloading:
edit a page and the next request picks it up without bouncing the server.

It serves on 9393 rather than Rack's default 9292, because weft's own demo app
uses 9292 and the two get run side by side. When they collide the symptom is
confusing rather than obvious: the server that lost the race exits, and your
browser cheerfully shows you the other application. Override with `PORT`.

## The Version Pin Is Exact, and That Is the Point

The Gemfile pins `gem "weft", "0.2.0"` exactly. Not a pessimistic constraint,
not a path, not a git ref, and never the gem's development branch.

This site is weft's first consumer from outside the gem's own repository. Half
its value is being a catalog; the other half is being an honest check on
whether the released gem is pleasant to build against. That second half
evaporates the moment the site reaches for something unreleased, because then
it is testing code no adopter can install.

So, concretely: **from this site's point of view, the next version of weft does
not exist.** No unreleased API, no "this gets nicer in the next release" in the
code. If building something here makes you want a feature the pinned version
does not have, that is a finding worth reporting to the gem, not a reason to
reach past the pin.

The one deliberate exception is editorial rather than technical. Where a later
weft is known to rename something this site teaches, a page may say so in a
prominent note. Moving the pin is its own piece of work: port the examples,
freeze the outgoing version's pages, then bump.

### Read weft's Docs at the Tag, Never From a Checkout

When you need weft's documentation, read the released version of it:

```bash
git -C ../weft show v0.2.0:docs/configuration.md
git -C ../weft show v0.2.0:docs/examples/click-to-edit.md
```

This is not pedantry, and it is the rule people break first. A checkout of the
gem sits on its development branch, and that branch's docs describe the *next*
release. At the time of writing, `docs/configuration.md` there documents three
settings (`strict_params`, `digest_length`, `mint_key`) that do not exist
anywhere in the pinned version's source. Following that page gets you either a
boot failure or, worse, a silently wrong page that no test catches.

`git show <tag>:<path>` reads from the object database, so it gives you the
released text even when the checkout is mid-edit on something else.

## Testing

```bash
bundle exec rspec
```

Request specs drive the whole `config.ru` stack through `rack-test` rather than
hitting `Weft::Router` directly. The gem's own suite does the latter, which is
right when the subject is one component in isolation. Here it would skip the
middleware every example has to work through, and it would lose the property
that makes a spec legible: cookies persist across a spec's requests, so one
spec is one visitor.

## Assets Are Vendored, Including the Ones Nothing Uses Yet

Nothing the running site loads comes from a third party. Fonts and scripts are
served from this origin.

The reason is speed first. Since browsers partitioned their HTTP caches, a font
or script on a public CDN is no longer shared between sites, so the "someone
else already downloaded it" argument is simply gone. What remains is a
render-blocking request over a fresh DNS lookup, TCP handshake and TLS
negotiation to a host the browser has no connection to. A file on this origin
rides a connection that is already open. Secondary reasons: it keeps visitor IP
addresses from leaking to a third party on a site whose audience is developers,
it narrows the content-security policy, and an always-on site should not depend
on anyone else to render.

```bash
bundle exec bin/fetch-htmx
```

That vendors htmx and its server-sent-events extension into `public/js`,
checking each download against the subresource-integrity hashes the pinned gem
carries. Reading the hashes off the gem instead of hard-coding a version is
what makes the check bite in both directions: a tampered download fails, and so
does a stale vendored file after the pin moves. Re-run it at every pin move and
commit whatever changes.

**The SSE extension is vendored now although nothing uses it yet.** Its first
consumer is the live-updating example, which is a long way off. It is here
early because both files come from the same two constants in the same gem, so
fetching them together keeps `bin/fetch-htmx` a single honest act rather than a
script with a dormant branch. If you are reading `public/js` and wondering why
`sse.js` is there and unreferenced: that is why, and it is expected.

The files are committed rather than fetched during the image build, so building
the image never depends on a third-party host being reachable.

## How an Example Is Built

Two files per example, side by side, under one directory per documented weft
version:

```
examples/v0.2/click_to_edit.rb        # module ClickToEdit: the components
examples/v0.2/click_to_edit_page.rb   # ClickToEditPage: prose and composition
```

The directory name is derived at boot from the version of weft actually loaded,
and only that one directory is on the autoload path. Move the pin without porting
the examples and the boot says so, because the directory will not be there.

**Each example is a module, and that is load-bearing.** Two of the twenty-one
define a `ContactsTable` and two define a `PEOPLE`, while weft validates a single
global route table. Namespacing keeps them apart and gives each component an
unsurprising route: `ClickToEdit::ContactCard` serves at
`/_components/click_to_edit/contact_card`.

`app/data` is loaded by a second Zeitwerk loader that never reloads, because the
store's cache lives on a class-level variable there. Reloaded, the class is a new
object with an empty cache, and every request in development would look like a
first visit. The price is that changing something in `app/data` needs a restart.

Namespacing costs one piece of wiring, in `config/environment.rb`. Weft evicts
classes from its route table as Zeitwerk unloads them, but Zeitwerk only reports
the constants files are named for. An example's components live inside one of
those, so on reload the old copies stay registered and the fresh ones collide.
The boot file adds a second `on_unload` that reaches into the module and evicts
what is inside it. Remove it and `bin/dev` answers every request with a route
collision, while the specs stay green, because the test environment does not
reload.

**Components never touch the store.** The example's data class does, and exposes
the two or three verbs its components need:

```ruby
class Contacts
  class << self
    def all = store.fetch

    private

    def store = Store.for("click_to_edit", seed: SEED)
  end
end
```

That is the "bring your own persistence" lesson in the shape weft's
[application patterns](https://github.com/rusterholz/weft/blob/v0.2.0/docs/app-patterns.md)
prescribe for service classes. The seed is declared once, where the handle is
built, so a read and a write cannot disagree about where an example starts.

**A page declares nothing but its prose and its composition.** Its URL, heading
and document title all come from the catalog, found from the page's own class
name, so the two can never drift. `ExamplePage` supplies the frame and calls the
page's `walkthrough`; a page that forgets to define one says so.

### The Docs' Examples Are Fragments, and a Page Is Not

This is the one thing to know before porting the next example. weft's
documentation writes each example as a standalone fragment, and shows it being
fetched with its values in the query string: `GET /_components/contact_card?contact_id=1`.
A page has no query string, so a component embedded in one is handed its values
by the call site instead, and **call-site keywords are not params** in weft. They
become HTML attributes, and weft warns when one collides with a declared param.

The fix is the dual weft's DSL already documents: declare `receives` alongside
the `param`.

```ruby
param :contact_id
receives :contact_id
```

Now the page can write `contact_card contact_id: "1"`, the hand-off fills the
value when the component is embedded, and the wire fills it when htmx fetches the
component on its own. Expect to need this on the first component of most
examples, and on no others.

### Specs

One request spec per example, driving the whole stack, because one spec is one
visitor. Assert the flow a person actually walks, then assert that a second
visitor does not see the first one's edit:

```ruby
get "/examples/click-to-edit"
post "/_components/click_to_edit/contact_editor/save", contact_id: "1", first_name: "Joseph"
clear_cookies
get "/_components/click_to_edit/contact_card", contact_id: "1"   # back to Joe
```

Assert isolation against the component, not the page: a page also shows the
example's source, which mentions the seeded values whatever the visitor has done
to them.

### Showing the Code

`CodeBlock` reads the file at render time and highlights it, and every example
goes through it, so how code is presented is one place. Two things it knows that
are easy to get wrong again:

- The path is a build argument and never a declared param. A param would put a
  file path on the wire and make this a component that reads any file it is asked
  for.
- Arbre renders a tag holding a single text child on one line, and indents one
  holding a nested tag. Inside a `<pre>` that indenting changes the code on the
  page, so the `<code>` wrapper goes in as text.

Rouge 5 supports wrapping only its three non-nesting HTML formatters, so richer
presentation later means a formatter subclass rather than a wrapper.

## Documentation Drift

```bash
bundle exec bin/doc-drift-check
```

Prose has no compiler. This checks that intra-repo links and anchors resolve,
that identifiers presented as methods exist, that settings named on `Weft`
answer on the real namespace, and that keyword arguments in fenced Ruby
examples match weft's actual signatures.

It is a vendored copy of a shared checker, and everything below its `CONFIG` is
verbatim from the original so the two stay diffable. Only `CONFIG` is ours. One
choice in it is worth knowing about: the pinned gem's own `lib/` is on the
source list, resolved through its loaded spec rather than a hard-coded path.
Without that, every weft method this site's prose names would read as a ghost
identifier, because it is defined in the gem and not here.

## Continuous Integration

`.github/workflows/ci.yml` runs on pushes to `main` and on every pull request.
Work happens on branches and arrives through a PR, so that pairing covers every
commit once rather than twice. Two jobs:

- **Specs, lint, doc drift.** The same three commands `bin/check` runs, split so
  a failure names itself.
- **Image builds.** `docker build`, proving the Dockerfile still produces an
  image. Nothing is pushed to a registry.

So a green run here and a green `bin/check` locally mean the same thing, with
one difference worth knowing: **CI builds on Linux.** A dependency that needs a
native extension can resolve on your machine and fail there, which is exactly
why the lockfile carries the `x86_64-linux` platform alongside your own. When
you change the `Gemfile`, check the lockfile picked up both.

There is no deploy job and there are no secrets. Deploying is separate work.

A red run is a stop. Nothing here is flaky by design, so a failure means a real
disagreement between your machine and a clean checkout on Linux.

### The Session Secret Is Not a CI Secret

`config.ru` assembles the session in front of the Router, and the visitor id it
carries is what gives each visitor their own expiring copy of an example's data.

`Rack::Session::Cookie` takes the key from `SESSION_SECRET`, and the key is
not a signing secret. `rack-session` hands it to
`Rack::Session::Encryptor`, which requires **at least 64 bytes** and splits it
into a 32-byte cipher key plus an HMAC key, then **encrypts** the session
payload under a random IV and authenticates the result. The whole session lives
in the cookie, encrypted and tamper-evident, and the server keeps no session
store at all. So a visitor can neither read their own visitor id nor forge one:
the older signed-cookie path survives in the library only to read legacy cookies
back.

Three paths, deliberately different:

- **The application reads `ENV.fetch("SESSION_SECRET")` with no default.** An app
  that silently boots on a hard-coded session key is a real security defect, so a
  missing secret is a refusal to start, loudly, rather than a fallback. Since
  there is no default in `config.ru`, there is no default in production either.
- **Test mode supplies a fixed throwaway value** from `spec_helper.rb`,
  unconditionally, so an exported secret cannot leak into a test run. The specs
  need *a* key, not *the* key, and making CI carry a credential to run a handful
  of request specs would be a cost with no benefit.
- **`bin/dev` exports a throwaway value too**, for the same reason and in the same
  spirit: in the script, where it is visibly not a secret, rather than in the
  application, where it would quietly become production's default as well.

The real secret appears for the first time at deploy, and only there.

### A Secure Cookie Needs a Truthful Proxy

In production the session cookie is marked `secure`, and rack-session takes that
literally: it **withholds the cookie entirely** from any request it cannot see as
https. A container running by hand, reached over plain http, therefore sets no
session cookie at all, which is correct and worth knowing before it looks like a
bug. Sending `X-Forwarded-Proto: https` brings it back.

That matters once something terminates TLS in front of this app, because the app
sees plain http from the proxy and decides from the forwarded scheme. If the
proxy does not send one, or Rack does not trust the address it came from, every
request looks like a brand-new visit and nobody keeps anything -- with no error
anywhere. Check it against a real request, not a local one, the first time this
site is deployed.

## Deploying

Not yet. The site runs locally and builds into an image; putting it on the
internet is separate work, and nothing here is wired for it.

The image is the deployable unit, and it is worth running by hand when the
Dockerfile changes:

```bash
docker build -t weft-site .
docker run --rm -p 8080:8080 weft-site
```
