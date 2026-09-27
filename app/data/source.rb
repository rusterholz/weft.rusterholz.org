# frozen_string_literal: true

require "pathname"

# Where the site's own files live, for showing and linking them: a path inside
# this repository, and that file on GitHub at the commit that is running.
module Source
  class << self
    def path_of(absolute_path) = Pathname.new(absolute_path).relative_path_from(APP_ROOT).to_s

    # GIT_SHA is baked in at image build, so a deployed page links the code it runs.
    def url(repo_path) = "#{SITE_REPO_URL}/blob/#{ENV.fetch('GIT_SHA', 'main')}/#{repo_path}"
  end
end
