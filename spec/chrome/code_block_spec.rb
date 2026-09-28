# frozen_string_literal: true

require "nokogiri"

RSpec.describe CodeBlock do
  let(:path) { "examples/v0.2/click_to_edit/contact_data.rb" }

  # A call site, as a page is one: `receives` values come from the caller, and
  # Component.render only speaks for the wire.
  def rendered(**handed_over)
    html = Weft::Context.new({}, nil, wire_params: {}) { code_block(**handed_over) }.to_s
    Nokogiri::HTML5.fragment(html)
  end

  it "is the code and a way to copy it, with no name of its own: its call site names it" do
    expect(rendered(path: path).at("div").element_children.map(&:name)).to eq(%w[pre button])
  end

  # Copying takes the site's script, so without it the button would do nothing.
  it "offers to copy the code, hidden until the site's script reveals it" do
    button = rendered(path: path).at("button")

    expect(button.text).to eq("Copy")
    expect(button["type"]).to eq("button")
    expect(button["class"].split).to include("copy")
    expect(button).to have_attribute("hidden")
    expect(button).to have_attribute("data-reveal")
  end

  it "shows the file exactly as it is on disk" do
    expect(rendered(path: path).at("pre").text).to eq(File.read(File.join(APP_ROOT, path)))
  end

  it "highlights what it shows" do
    expect(rendered(path: path).css("pre > code span[class]")).not_to be_empty
  end

  it "takes its id from the file it shows, so a page of blocks can link each one" do
    expect(rendered(path: path).at("div")["id"]).to eq("code-examples-v0-2-click-to-edit-contact-data-rb")
  end

  it "refuses to render without a path" do
    expect { rendered }.to raise_error(Weft::NotReceived)
  end

  it "stays off the route table, where a path would be a request for any file" do
    expect(described_class).not_to be_routable
  end
end
