# frozen_string_literal: true

RSpec.describe "the branded error page" do
  around do |example|
    original = Weft.configuration.verbose_error_pages
    example.run
  ensure
    Weft.configure { |c| c.verbose_error_pages = original }
  end

  it "replaces the gem's own document when a page raises" do
    get ExplodingPage.page_path

    expect(last_response.status).to eq(500)
    expect(last_response.body).to include("<title>Something Went Wrong · weft</title>")
  end

  it "shows the exception where verbose error pages are on" do
    Weft.configure { |c| c.verbose_error_pages = true }

    get ExplodingPage.page_path

    expect(last_response.body).to include(ExplodingPage::BANG)
  end

  it "shows nothing of the exception where they are off" do
    Weft.configure { |c| c.verbose_error_pages = false }

    get ExplodingPage.page_path

    expect(last_response.body).to include("This page could not be rendered.")
    expect(last_response.body).not_to include(ExplodingPage::BANG)
  end
end
