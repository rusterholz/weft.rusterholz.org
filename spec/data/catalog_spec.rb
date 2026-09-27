# frozen_string_literal: true

RSpec.describe Catalog do
  it "lists every example weft documents" do
    expect(described_class.entries.length).to eq(21)
  end

  it "keeps weft's own order, which is the order the site walks them in" do
    slugs = described_class.entries.map(&:slug)

    expect(slugs.first).to eq("click-to-edit")
    expect(slugs.last).to eq("updating-other-content")
  end

  it "gives every entry a slug, a Title Case title and a one-line summary" do
    expect(described_class.entries).to all(have_attributes(slug: a_string_matching(/\A[a-z-]+\z/),
                                                           title: a_string_matching(/\A[A-Z]/),
                                                           summary: a_string_matching(/\S/)))
  end

  it "never writes an em dash, whatever weft's own catalog does" do
    expect(described_class.entries.map(&:summary).join).not_to include("—")
  end

  it "finds an example by its slug" do
    expect(described_class.find("click-to-edit").title).to eq("Click to Edit")
  end

  it "knows where an example lives on the site" do
    expect(described_class.find("click-to-edit").path).to eq("/examples/click-to-edit")
  end

  it "says so when asked for a slug it does not have" do
    expect { described_class.find("no-such-example") }.to raise_error(Catalog::Unknown, /no-such-example/)
  end

  describe ".neighbors_of" do
    let(:running) { %w[click-to-edit delete-row tabs].map { |slug| described_class.find(slug) } }

    it "finds the running examples either side, skipping the ones to come" do
      expect(described_class.neighbors_of("delete-row", among: running).map(&:slug)).to eq(%w[click-to-edit tabs])
    end

    it "has nothing before the first or after the last" do
      expect(described_class.neighbors_of("click-to-edit", among: running).first).to be_nil
      expect(described_class.neighbors_of("tabs", among: running).last).to be_nil
    end

    it "walks the running examples unless told otherwise" do
      expect(described_class.neighbors_of("click-to-edit")).to eq([nil, nil])
    end
  end

  it "derives a page's slug from the page's own name" do
    expect(described_class.slug_for(ClickToEditPage)).to eq("click-to-edit")
  end

  # A page named for something the catalog does not list would route at a URL
  # nothing links to, which is a typo nobody would notice.
  it "refuses a page that is not an example" do
    expect { described_class.slug_for(HomePage) }.to raise_error(Catalog::Unknown, /home/)
  end
end
