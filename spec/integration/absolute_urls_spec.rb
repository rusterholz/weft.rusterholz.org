# frozen_string_literal: true

# The domain is provisional and every outside address is one edit away from
# changing, so absolute URLs live in config and the code refers to them by name.
RSpec.describe "absolute URLs in the site's code" do
  it "appear only in config" do
    code = Dir[File.join(APP_ROOT, "{app,examples}", "**", "*.rb")]

    offenders = code.select { |path| File.read(path).match?(%r{\bhttps?://}) }

    expect(offenders.map { |path| path.delete_prefix("#{APP_ROOT}/") }).to be_empty
  end
end
