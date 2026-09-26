# frozen_string_literal: true

require "nokogiri"

RSpec.describe SiteHeader do
  let(:header) do
    html = Weft::Context.new({}, nil, wire_params: {}) do
      site_header trail: [["weft", "/"]], return_to: "/examples/click-to-edit"
    end.to_s
    Nokogiri::HTML5.fragment(html).at("header")
  end

  it "offers both themes, each coming back to this page" do
    toggles = header.css(".widgets form").map do |form|
      form.css("input[type=hidden]").to_h { |input| [input["name"], input["value"]] }
    end

    expect(toggles).to eq([{ "theme" => "dark", "return_to" => "/examples/click-to-edit" },
                           { "theme" => "light", "return_to" => "/examples/click-to-edit" }])
  end

  it "links weft on GitHub" do
    expect(header.at(".widgets a")["href"]).to eq(WEFT_REPO_URL)
  end
end
