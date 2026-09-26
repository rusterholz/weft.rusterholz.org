# frozen_string_literal: true

require "nokogiri"

RSpec.describe ThemeToggle do
  let(:toggle) do
    html = Weft::Context.new({}, nil, wire_params: {}) do
      theme_toggle theme: "dark", return_to: "/examples/click-to-edit"
    end.to_s
    Nokogiri::HTML5.fragment(html)
  end

  it "is a form that still works without JavaScript" do
    form = toggle.at("form")

    expect(form["action"]).to eq("/_components/theme_toggle/choose")
    expect(form["method"]).to eq("post")
  end

  it "carries the theme it offers and the page to come back to" do
    fields = toggle.css("input[type=hidden]").to_h { |input| [input["name"], input["value"]] }

    expect(fields).to eq("theme" => "dark", "return_to" => "/examples/click-to-edit")
  end

  it "names what the button does for someone who cannot see the icon" do
    expect(toggle.at("button")["aria-label"]).to eq("Switch to dark theme")
  end

  it "has an id per theme, so the stylesheet can show the one that applies" do
    expect(toggle.at("div")["id"]).to eq("theme-toggle-dark")
  end
end
