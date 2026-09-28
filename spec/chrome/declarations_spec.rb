# frozen_string_literal: true

require "nokogiri"

RSpec.describe Declarations do
  describe ".of" do
    it "reads a component's class-body declarations, exactly as its file writes them" do
      expect(described_class.of(ClickToEdit::ContactCard)).to eq(<<~RUBY.chomp)
        param :contact_id
        receives :contact_id
        derives(:contact) do |p|
          ContactData.find(p.contact_id)
        end

        transfers :edit, to: ContactEditor,
                         method: :get
      RUBY
    end

    it "keeps a block whole, at its own indentation" do
      expect(described_class.of(ClickToEdit::ContactEditor)).to include(<<~RUBY.chomp)
        transfers :save, to: ContactCard do |params|
          ContactData.update(params.contact_id,
                             first_name: params.first_name,
                             last_name: params.last_name,
                             email: params.email)
          nil
        end
      RUBY
    end

    it "keeps a declaration's own line breaks" do
      expect(described_class.of(ClickToEdit::ContactEditor)).to end_with(<<~RUBY.chomp)
        transfers :cancel, to: ContactCard,
                           method: :get
      RUBY
    end

    it "leaves out what is not weft's: the builder name, and the methods" do
      shown = described_class.of(ClickToEdit::ContactCard)

      expect(shown).not_to include("builder_method")
      expect(shown).not_to include("def ")
    end
  end

  describe "the margin" do
    let(:margin) do
      html = Weft::Context.new({}, nil, wire_params: {}) do
        declarations components: [ClickToEdit::ContactCard, ClickToEdit::ContactEditor],
                     at_rest: [ClickToEdit::ContactCard],
                     behind: { ClickToEdit::ContactData => "where a visitor's contact is kept" }
      end.to_s
      Nokogiri::HTML5.fragment(html).at("aside")
    end

    it "gives each component a block, named, in the order given" do
      expect(margin.css(".declaration .name").map(&:text)).to eq(%w[ContactCard ContactEditor])
    end

    it "tints the components on the page at rest, and only those" do
      expect(margin.css(".declaration.at-rest .name").map(&:text)).to eq(%w[ContactCard])
    end

    it "shows each block's declarations as its file writes them" do
      expect(margin.css(".declaration pre").first.text).to eq(described_class.of(ClickToEdit::ContactCard))
    end

    it "says a click lights what answered it, where the site's script is there to do it" do
      hint = margin.at(".heading + .hint")

      expect(hint.text).to eq("The one that answered your last click is lit.")
      expect(hint).to have_attribute("hidden")
      expect(hint).to have_attribute("data-reveal")
    end

    it "names each block's component, as the Weft-Site-Handled header names a fragment" do
      expect(margin.css(".declaration").map { |block| block["data-component"] }).
        to eq(%w[ClickToEdit::ContactCard ClickToEdit::ContactEditor])
    end

    it "marks each action's declaration with what the header names when that action answers" do
      marked = margin.css("pre [data-handles]").map { |span| [span["data-handles"], span.text.lines.first.strip] }

      expect(marked).to eq([
                             ["ClickToEdit::ContactCard#edit", "transfers :edit, to: ContactEditor,"],
                             ["ClickToEdit::ContactEditor#save", "transfers :save, to: ContactCard do |params|"],
                             ["ClickToEdit::ContactEditor#cancel", "transfers :cancel, to: ContactCard,"]
                           ])
    end

    it "closes with what the components stand on" do
      expect(margin.element_children.last.text).to eq("Behind both: ContactData, where a visitor's contact is kept.")
    end
  end
end
