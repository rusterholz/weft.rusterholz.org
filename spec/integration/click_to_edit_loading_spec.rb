# frozen_string_literal: true

require "open3"

# The card and the editor each name the other in their class bodies. This
# process has long since loaded both, so each case boots a fresh one.
RSpec.describe "loading the Click to Edit components" do
  let(:expected) do
    "ClickToEdit::ContactCard edit get ClickToEdit::ContactEditor\n" \
      "ClickToEdit::ContactEditor cancel get ClickToEdit::ContactCard\n" \
      "ClickToEdit::ContactEditor save post ClickToEdit::ContactCard\n"
  end

  def boot(script)
    report = <<~RUBY
      %w[ClickToEdit::ContactCard ClickToEdit::ContactEditor].each do |name|
        Object.const_get(name).actions.each_value do |action|
          puts [name, action.name, action.method, action.renders.name].join(" ")
        end
      end
    RUBY
    output, status = Open3.capture2e("bundle", "exec", "ruby", "-e", script + report, chdir: APP_ROOT)
    expect(status).to be_success, output
    output.lines.sort.join
  end

  def lazily_loading(first)
    <<~RUBY
      require "bundler/setup"
      require "active_support"
      require "weft"
      require "zeitwerk"
      loader = Zeitwerk::Loader.new
      %w[app/data app/chrome app/pages].each { |dir| loader.push_dir(dir) }
      loader.push_dir(Dir["examples/v*"].max)
      loader.setup
      #{first}
    RUBY
  end

  it "resolves both directions when the card is loaded first" do
    expect(boot(lazily_loading("ClickToEdit::ContactCard"))).to eq(expected)
  end

  it "resolves both directions when the editor is loaded first" do
    expect(boot(lazily_loading("ClickToEdit::ContactEditor"))).to eq(expected)
  end

  it "resolves both directions when the site boots, eager-loading everything" do
    expect(boot(%(ENV["SESSION_SECRET"] = "x" * 64\nrequire "./config/environment"\n))).to eq(expected)
  end
end
