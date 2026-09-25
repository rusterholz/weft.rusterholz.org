# frozen_string_literal: true

require "nokogiri"

RSpec.describe CodeBlock do
  let(:path) { "examples/v0.2/click_to_edit/contacts.rb" }

  # A call site, as a page is one: `receives` values come from the caller, and
  # Component.render only speaks for the wire.
  def rendered(**handed_over)
    html = Weft::Context.new({}, nil, wire_params: {}) { code_block(**handed_over) }.to_s
    Nokogiri::HTML5.fragment(html)
  end

  it "labels the block with the path it was handed" do
    expect(rendered(path: path).at("p > code").text).to eq(path)
  end

  it "shows the file exactly as it is on disk" do
    expect(rendered(path: path).at("pre").text).to eq(File.read(File.join(APP_ROOT, path)))
  end

  it "highlights what it shows" do
    expect(rendered(path: path).css("pre > code span[class]")).not_to be_empty
  end

  it "refuses to render without a path" do
    expect { rendered }.to raise_error(Weft::NotReceived)
  end

  it "stays off the route table, where a path would be a request for any file" do
    expect(described_class).not_to be_routable
  end
end
