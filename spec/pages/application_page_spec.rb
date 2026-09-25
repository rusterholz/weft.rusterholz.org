# frozen_string_literal: true

require "nokogiri"

RSpec.describe ApplicationPage do
  describe "the frame every page renders in" do
    let(:page_class) do
      Class.new(described_class) do
        abstract!
        def build(attributes = {})
          super
          h1 "The Page Itself"
        end
      end
    end

    def rendered(session: {})
      Current.request = Rack::Request.new(Rack::MockRequest.env_for("/", "rack.session" => session))
      Nokogiri::HTML5(page_class.render)
    end

    it "loads the site's stylesheet from this origin" do
      expect(rendered.css("link[rel=stylesheet]").map { |link| link["href"] }).to eq(["/static/css/site.css"])
    end

    it "puts the header, then the page's own content, then the bench" do
      body = rendered.at("body")

      expect(body.element_children.map(&:name)).to eq(%w[header main footer])
      expect(body.at("main > h1").text).to eq("The Page Itself")
    end

    it "leaves the theme to the visitor's system until they choose one" do
      expect(rendered.at("html")["data-theme"]).to be_nil
    end

    it "wears the theme the visitor chose" do
      expect(rendered(session: { "theme" => "dark" }).at("html")["data-theme"]).to eq("dark")
    end

    it "ignores a theme it does not know" do
      expect(rendered(session: { "theme" => "sepia" }).at("html")["data-theme"]).to be_nil
    end

    it "opens the hood on the page's own file" do
      hood = rendered.css("footer a").find { |link| link.text.start_with?("open the hood") }

      expect(hood.text).to eq("open the hood: spec/pages/application_page_spec.rb")
    end
  end

  describe "#prose" do
    def paragraphs_of(text)
      page = Class.new(described_class) do
        abstract!
        define_method(:build) do |attributes = {}|
          super(attributes)
          prose text
        end
      end
      Nokogiri::HTML5(page.render).css("main > p").map(&:text)
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
