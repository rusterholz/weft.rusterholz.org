# frozen_string_literal: true

require "active_support/cache"
require "active_support/core_ext/numeric/bytes"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/object/deep_dup"

# Where the examples keep their data: a cache, per visitor, on a timer.
#
# Storage that is allowed to forget is what this site needs, since no example's
# data outlives its visitor, so the expiry is the feature and not a limitation.
# One entry holds one example's whole state, which keeps a reset to a single
# delete that every cache store implements. Two costs, both accepted: a memory
# cache is per *process*, and read-modify-write is not atomic.
class Store
  TTL = 2.hours
  MAX_BYTES = 32.megabytes

  NoVisitor = Class.new(StandardError)

  class << self
    # A handle on one example's data for the visitor in scope; `seed` is its start.
    def for(example, seed: {})
      Handle.new(cache, key_for(example), seed)
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

  # One example's state for one visitor. An example's data class holds one of
  # these and exposes the few verbs its components need; components never do.
  class Handle
    def initialize(cache, key, seed)
      @cache = cache
      @key = key
      @seed = seed
    end

    # deep_dup, not dup: a cache miss hands the block's own object to the caller,
    # so a shallow copy would leave the seed itself open to editing.
    def fetch = @cache.fetch(@key) { @seed.deep_dup }

    # Read, change, write back, so no call site can change data and not keep it.
    def update
      state = fetch
      yield(state)
      @cache.write(@key, state)
      state
    end

    def reset! = @cache.delete(@key)
  end
end
