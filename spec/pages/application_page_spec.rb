# frozen_string_literal: true

require "nokogiri"

RSpec.describe ApplicationPage do
  describe "#prose" do
    def paragraphs_of(text)
      page = Class.new(described_class) do
        abstract!
        define_method(:build) do |attributes = {}|
          super(attributes)
          prose text
        end
      end
      Nokogiri::HTML5(page.render).css("body > p").map(&:text)
    end

    it "makes one paragraph of each chunk between blank lines" do
      text = <<~TEXT
        First paragraph,
        wrapped in the source.

        Second paragraph.
      TEXT

      expect(paragraphs_of(text)).to eq(["First paragraph, wrapped in the source.", "Second paragraph."])
    end

    it "treats a run of blank lines as one break, and ignores them at either end" do
      expect(paragraphs_of("\n\nOne.\n\n\n\nTwo.\n\n")).to eq(%w[One. Two.])
    end

    it "treats a line holding only spaces as blank" do
      expect(paragraphs_of("One.\n   \nTwo.")).to eq(%w[One. Two.])
    end

    it "renders text, never markup" do
      expect(paragraphs_of("Use <b>bold</b> & friends.")).to eq(["Use <b>bold</b> & friends."])
    end
  end
end
