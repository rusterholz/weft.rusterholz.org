# Two stages so the compiler that builds puma's native extension does not ride
# along into the image that runs on the internet.

FROM ruby:3.4.7-slim AS gems

ENV BUNDLE_FROZEN=true \
    BUNDLE_WITHOUT=development:test

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && rm -rf /usr/local/bundle/cache


FROM ruby:3.4.7-slim

# Matches .ruby-version, and the tag is pinned to the patch so an image rebuilt
# in six months runs the Ruby this site was tested on.

ENV BUNDLE_WITHOUT=development:test \
    RACK_ENV=production

WORKDIR /app

COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY . .

RUN useradd --create-home --shell /usr/sbin/nologin site && chown -R site:site /app
USER site

EXPOSE 8080

CMD ["bundle", "exec", "puma", "--port", "8080"]
