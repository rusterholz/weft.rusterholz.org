# frozen_string_literal: true

require "nokogiri"

RSpec.describe Picker do
  def rendered(options)
    html = Weft::Context.new({}, nil, wire_params: {}) do
      picker options: options, current: options.first.first, label: "Version",
             disabled_reason: "Nothing else to pick."
    end.to_s
    Nokogiri::HTML5.fragment(html)
  end

  context "with one entry" do
    let(:one) { rendered([["v0.2.0", "/"]]) }

    it "disables itself, since there is nothing to pick" do
      expect(one.at("select")["disabled"]).not_to be_nil
    end

    it "says why, on the element a pointer can still reach" do
      expect(one.at(".picker")["title"]).to eq("Nothing else to pick.")
      expect(one.at(".picker > select")).not_to be_nil
    end

    it "shows the one entry it has" do
      expect(one.css("option").map(&:text)).to eq(["v0.2.0"])
    end
  end

  context "with two or more" do
    let(:two) { rendered([["v0.2.0", "/v0.2"], ["v0.3.0", "/v0.3"]]) }

    it "is live, with no reason to give" do
      expect(two.at("select")["disabled"]).to be_nil
      expect(two.at("[title]")).to be_nil
    end

    it "offers each entry's address, the current one selected" do
      options = two.css("option").map { |option| [option.text, option["value"], !option["selected"].nil?] }

      expect(options).to eq([["v0.2.0", "/v0.2", true], ["v0.3.0", "/v0.3", false]])
    end

    it "goes as soon as the choice changes, and has a button for when htmx is not running" do
      form = two.at("form")

      expect(form["hx-get"]).to eq("/_components/picker/go")
      expect(form["hx-trigger"]).to eq("change")
      expect(form.at("noscript")).not_to be_nil
    end
  end
end
