# frozen_string_literal: true

RSpec.describe ExamplePage do
  # Asked of the ordering directly, not of a rendered page: Module#constants
  # happens to answer in the right order in this process, so a page would render
  # correctly with nothing ordering it at all.
  it "puts the data class before the components, whatever order they arrive in" do
    arriving = [ClickToEdit::ContactEditor, ClickToEdit::ContactCard, ClickToEdit::Contacts]

    ordered = described_class.in_reading_order(arriving)

    expect(ordered).to eq([ClickToEdit::Contacts, ClickToEdit::ContactCard, ClickToEdit::ContactEditor])
  end

  it "orders components among themselves by name" do
    arriving = [ClickToEdit::ContactEditor, ClickToEdit::ContactCard]

    expect(described_class.in_reading_order(arriving)).to eq(arriving.reverse)
  end

  # Both directions at once, for every example as it lands: a class nobody
  # described stops the page, and a description naming nothing is dead copy that
  # would otherwise sit in the file unnoticed.
  it "describes exactly the classes it is made of, on every live example page" do
    live_pages = Catalog.entries.select(&:live?).map do |entry|
      Object.const_get("#{entry.slug.tr('-', '_').camelize}Page")
    end

    expect(live_pages).not_to be_empty
    live_pages.each do |page_class|
      described = page_class.described_keys.sort
      classes = page_class.example_classes.map { |klass| page_class.key_for(klass) }.sort

      expect(described).to eq(classes), "#{page_class} describes #{described.inspect}, not #{classes.inspect}"
    end
  end
end
