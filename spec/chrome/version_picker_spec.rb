# frozen_string_literal: true

require "nokogiri"

RSpec.describe VersionPicker do
  let(:picker) do
    Nokogiri::HTML5.fragment(Weft::Context.new({}, nil, wire_params: {}) { version_picker }.to_s)
  end

  it "shows the weft this site runs" do
    expect(picker.css("option").map(&:text)).to eq(["v#{Weft::VERSION}"])
  end

  it "stays disabled while one version is documented, and says so" do
    expect(picker.at("select")["disabled"]).not_to be_nil
    expect(picker.at(".picker")["title"]).to eq("Only one version of weft is documented so far.")
  end
end
