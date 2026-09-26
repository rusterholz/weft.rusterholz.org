# frozen_string_literal: true

require "nokogiri"

RSpec.describe Declarations do
  describe ".of" do
    it "reads a component's class-body declarations, exactly as its file writes them" do
      expect(described_class.of(ClickToEdit::ContactCard)).to eq(<<~RUBY.chomp)
        param :contact_id
        receives :contact_id
        derives(:contact) do |p|
          Contacts.find(p.contact_id)
        end

        transfers :edit, to: ContactEditor,
                         method: :get
      RUBY
    end

    it "keeps a block whole, at its own indentation" do
      expect(described_class.of(ClickToEdit::ContactEditor)).to include(<<~RUBY.chomp)
        transfers :save, to: ContactCard do |params|
          Contacts.update(params.contact_id,
                          first_name: params.first_name,
                          last_name: params.last_name,
                          email: params.email)
          nil
        end
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
                     at_rest: [ClickToEdit::ContactCard], slug: "click-to-edit",
                     behind: { ClickToEdit::Contacts => "where a visitor's contact is kept" }
      end.to_s
      Nokogiri::HTML5.fragment(html).at("aside")
    end

    it "gives each component a block, named, in the order given" do
      expect(margin.css(".declaration .name").map(&:text)).to eq(%w[ContactCard ContactEditor])
    end

    it "tints the components on the page at rest, and only those" do
      expect(margin.css(".declaration.at-rest .name").map(&:text)).to eq(%w[ContactCard])
    end

    it "shows each block's declarations as its file writes them, a line at a time" do
      lines = margin.css(".declaration pre").first.css(".line").map(&:text)

      expect(lines.join("\n")).to eq(described_class.of(ClickToEdit::ContactCard))
    end

    it "closes with what the components stand on" do
      expect(margin.at(".behind p").text).to eq("Behind both: Contacts, where a visitor's contact is kept.")
    end

    it "offers to put the visitor's copy of it back as it started" do
      form = margin.at(".behind form")

      expect(form["action"]).to eq("/_components/reset_example/reset")
      expect(form.at("input[name=slug]")["value"]).to eq("click-to-edit")
      expect(form.at("button").text).to eq("Reset This Example")
    end
  end
end
