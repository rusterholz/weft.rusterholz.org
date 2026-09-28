# frozen_string_literal: true

require "rack/session"

# Each of the site's wiring errors, raised by really wiring the site wrong, and
# answered with an honest 500: the site's error page for a page, weft's error
# fragment in place for a fragment or an action. Catalog::Unknown reaches the
# error page through Weft::Page's built-in edge. Test mode shows the exception,
# so each spec can name the error it reached.
RSpec.describe "a site wired wrong" do
  let(:title) { "<title>Something Went Wrong · weft</title>" }

  # A running example whose page is added here, taken away again afterwards.
  def tabs_page(&)
    stub_const("TabsPage", Class.new(ExamplePage))
    TabsPage.class_eval(&)
  end

  def tabs_panes
    stub_const("Tabs", Module.new)
    stub_const("Tabs::Panes", Class.new)
  end

  after { Weft.registry.evict(TabsPage) if defined?(TabsPage) }

  it "answers an example page with no walkthrough with the error page" do
    tabs_panes
    tabs_page { describes panes: "the panes", tabs_page: "a page to put it on" }

    get "/examples/tabs"

    expect(last_response.status).to eq(500)
    expect(last_response.body).to include(title, "ExamplePage::NoWalkthrough")
  end

  it "answers an example page that leaves a class undescribed with the error page" do
    tabs_panes
    tabs_page do
      describes tabs_page: "a page to put it on"
      define_method(:walkthrough) { para "Tabs." }
    end

    get "/examples/tabs"

    expect(last_response.status).to eq(500)
    expect(last_response.body).to include(title, "ExamplePage::Undescribed")
  end

  it "answers an example page with no example beside it with the error page" do
    tabs_page do
      describes tabs_page: "a page to put it on"
      define_method(:walkthrough) { para "Tabs." }
    end

    get "/examples/tabs"

    expect(last_response.status).to eq(500)
    expect(last_response.body).to include(title, "ExamplePage::NoSuchExample")
  end

  it "answers an example calling a site component that does not describe itself with the error page" do
    stub_const("Tabs", Module.new)
    stub_const("TabsPage", Class.new(ExamplePage))
    load_fixture "tabs_calling_callout.rb"

    get "/examples/tabs"

    expect(last_response.status).to eq(500)
    expect(last_response.body).to include(title, "SiteHelper::Undescribed")
  ensure
    forget_fixture(Tabs::TabStrip)
  end

  it "answers every page with the error page when a page is named for no example" do
    stub_const("MisnamedPage", Class.new(ExamplePage))

    get "/"

    expect(last_response.status).to eq(500)
    expect(last_response.body).to include(title, "SiteData::Catalog::Unknown")
  ensure
    Weft.registry.evict(MisnamedPage)
  end

  it "answers a Reset for an example with no classes beside it with a 500 in place, not a redirect" do
    tabs_page do
      describes tabs_page: "a page to put it on"
      define_method(:walkthrough) { para "Tabs." }
    end

    post_form "/_components/reset_example/reset", { slug: "tabs" }, "HTTP_HX_REQUEST" => "true"

    expect(last_response.status).to eq(500)
    expect(last_response.headers).not_to include("hx-redirect", "location")
    expect(last_response.body).to include("weft-error", "is not defined")
  end

  describe "with no VisitorScope in the stack" do
    let(:app) do
      Rack::Builder.new do
        use Rack::Session::Cookie, secret: ENV.fetch("SESSION_SECRET")
        run Weft::Router
      end
    end

    it "answers a page that reads the store with the error page" do
      get "/examples/click-to-edit"

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include(title, "SiteData::Store::NoVisitor")
    end

    it "answers an example's fragment with weft's error fragment, in place" do
      get "/_components/click_to_edit/contact_card", contact_id: "1"

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include("weft-error", "No visitor in scope")
    end
  end
end
