# frozen_string_literal: true

require "tempfile"

RSpec.describe SiteHelper do
  def example_file(stem) = File.join(EXAMPLES_ROOT, "click_to_edit", "#{stem}.rb")

  def source(ruby)
    Tempfile.create(%w[example .rb]) do |file|
      file.write(ruby)
      file.flush
      yield file.path
    end
  end

  it "finds the site's own components a file calls by their builder names" do
    expect(described_class.used_in([example_file("contact_editor")])).to eq([AuthenticityTokenField])
  end

  it "finds none where a file calls none" do
    expect(described_class.used_in([example_file("contact_data"), example_file("contact_card")])).to be_empty
  end

  it "reads the call, not a mention: a name in a string or a comment is not a use" do
    source(%(# authenticity_token\nputs "authenticity_token"\n)) do |path|
      expect(described_class.used_in([path])).to be_empty
    end
  end

  it "carries each helper's phrase, written once on the helper" do
    expect(AuthenticityTokenField.phrase).to eq(
      "the hidden field that carries the visitor's CSRF token, in every form that writes"
    )
  end

  it "says so when a file calls a site component that does not describe itself" do
    source("callout { para 'x' }\n") do |path|
      expect { described_class.used_in([path]) }.to raise_error(SiteHelper::Undescribed, /Callout/)
    end
  end
end
