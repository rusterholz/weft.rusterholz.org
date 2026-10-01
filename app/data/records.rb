# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

module SiteData
  # The base an example's data class stands on, in place of your ORM's model
  # class: records kept by id in the visitor's own slice of the Store. The class
  # finds, lists and creates them; a record reads, updates and destroys itself.
  #
  #   class ContactData < SiteData::Records
  #     SEED = { "1" => { first_name: "Joe" } }.freeze
  #     stored_in "click_to_edit", seed: SEED
  #   end
  #
  #   ContactData.find("1").update(first_name: "Joseph")
  class Records
    attr_reader :id

    def initialize(id, attributes, slice)
      @id = id
      @attributes = attributes
      @slice = slice
    end

    def [](key) = @attributes[key]

    # A left-out field means "unchanged", and only the record's own fields change.
    # The record takes the result as well, so whatever already holds it, such as
    # the render after a transfer, shows the edit.
    def update(**attributes)
      records = @slice.update do |held|
        own = own_in(held)
        own.merge!(attributes.compact.slice(*own.keys))
      end
      @attributes = records.fetch(id).dup
      self
    end

    def destroy
      @slice.update do |held|
        own_in(held)
        held.delete(id)
      end
      self
    end

    private

    def own_in(records) = records.fetch(id) { raise self.class.not_found(id) }

    class << self
      def stored_in(slice_name, seed:)
        @slice_name = slice_name
        @seed = seed
      end

      def all = slice.fetch.map { |id, attributes| new(id, attributes, slice) }

      def find(id)
        attributes = slice.fetch.fetch(id) { raise not_found(id) }
        new(id, attributes, slice)
      end

      # Stores the fields as given, with no check against the seed's shape; an
      # example that refuses blanks says so before calling. Under the next id
      # after the highest held, so it lands after the rest.
      def create(**attributes)
        records = slice.update do |held|
          next_id = ((held.keys.map(&:to_i).max || 0) + 1).to_s
          held[next_id] = attributes
        end
        id = records.keys.last
        new(id, records[id].dup, slice)
      end

      def reset! = slice.reset!

      # Reading and writing a record nobody has get the same answer: Weft
      # renders its not-found page or fragment.
      def not_found(id) = Weft::NotFound.new("#{name.demodulize} has no #{id.inspect}")

      private

      def slice = Store.for(@slice_name, seed: @seed)
    end
  end
end
