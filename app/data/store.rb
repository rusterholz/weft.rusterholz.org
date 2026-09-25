# frozen_string_literal: true

require "active_support/cache"
require "active_support/core_ext/numeric/bytes"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/object/deep_dup"

# Where the examples keep their data: a cache that forgets, since no example's
# data outlives its visitor (one browser session; see VisitorScope).
#
# Each example a visitor touches gets an ExampleSlice: all of that example's
# data, for that visitor alone, as one cache entry. So one visitor's edits never
# reach another's, and resetting an example is one delete. Two costs: a memory
# cache is per *process*, and read-modify-write is not atomic.
class Store
  TTL = 2.hours
  MAX_BYTES = 32.megabytes

  NoVisitor = Class.new(StandardError)

  class << self
    # The example's slice for the visitor in scope, holding `seed` until written.
    def for(example, seed: {})
      ExampleSlice.new(cache, key_for(example), seed)
    end

    private

    # Only the ActiveSupport::Cache::Store interface is used, so Redis is this line.
    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(expires_in: TTL, size: MAX_BYTES)
    end

    def key_for(example)
      raise NoVisitor, "No visitor in scope: is VisitorScope in the stack?" unless Current.visitor

      "#{Current.visitor}/#{example}"
    end
  end

  # One example's data for one visitor. An example's data class holds one of
  # these and exposes the few verbs its components need; components never do.
  class ExampleSlice
    def initialize(cache, key, seed)
      @cache = cache
      @key = key
      @seed = seed
    end

    # deep_dup, not dup: a cache miss hands the block's own object to the caller,
    # so a shallow copy would leave the seed itself open to editing.
    def fetch = @cache.fetch(@key) { @seed.deep_dup }

    def update
      state = fetch
      yield(state)
      @cache.write(@key, state)
      state
    end

    def reset! = @cache.delete(@key)
  end
end
