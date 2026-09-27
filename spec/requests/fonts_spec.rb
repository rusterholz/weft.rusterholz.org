# frozen_string_literal: true

# The site's faces come from its own origin, like everything else it loads.
RSpec.describe "the vendored fonts" do
  let(:faces) do
    %w[spectral-400 spectral-italic-400 spectral-500 spectral-600 spline-sans-mono-400 spline-sans-mono-500]
  end

  it "are served from this origin as woff2" do
    faces.each do |face|
      get "/static/fonts/#{face}.woff2"

      expect(last_response.status).to eq(200), "#{face}: #{last_response.status}"
      expect(last_response.body.byteslice(0, 4)).to eq("wOF2"), "#{face} is not a woff2 file"
    end
  end
end
