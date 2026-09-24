# frozen_string_literal: true

require "active_support/cache"
require "active_support/core_ext/numeric/bytes"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/object/deep_dup"

# Where the examples keep their data: a cache, per visitor, on a timer.
#
# Storage that is allowed to forget is what this site needs, since no example's
# data outlives its visitor, so the expiry is the feature and not a limitation.
# One entry holds one whole slice, a slice being all that one example keeps for
# one visitor, which reduces a reset to the single delete every cache store has.
# Two costs, accepted: a memory cache is per *process*, and read-modify-write is
# not atomic.
class Store
  TTL = 2.hours
  MAX_BYTES = 32.megabytes

  NoVisitor = Class.new(StandardError)

  class << self
    # A handle on one slice for the visitor in scope; `seed` is that slice's start.
    def for(slice, seed: {})
      Handle.new(cache, key_for(slice), seed)
    end

    private

    # Only the ActiveSupport::Cache::Store interface is used, so Redis is this line.
    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(expires_in: TTL, size: MAX_BYTES)
    end

    def key_for(slice)
      raise NoVisitor, "No visitor in scope: is VisitorScope in the stack?" unless Current.visitor

      "#{Current.visitor}/#{slice}"
    end
  end

  # One slice. An example's data class holds one of these and exposes the few
  # verbs its components need; components never hold one.
  class Handle
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
