# frozen_string_literal: true

require "nokogiri"

RSpec.describe AuthenticityTokenField do
  before { Current.csrf_token = "this-visitors-token" }

  let(:fields) do
    html = Weft::Context.new({}, nil, wire_params: {}) do
      form(action: "/somewhere", method: "post") { authenticity_token }
    end.to_s
    Nokogiri::HTML5.fragment(html).at("form").element_children
  end

  it "is the one hidden field a writing form needs, holding the visitor's CSRF token" do
    expect(fields.map(&:to_h)).to eq([{ "type" => "hidden", "name" => "authenticity_token",
                                        "value" => "this-visitors-token" }])
  end
end
