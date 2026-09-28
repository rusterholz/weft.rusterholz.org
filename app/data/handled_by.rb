# frozen_string_literal: true

require "rack/protection"
require "uri"

module SiteData
  # Rack middleware, used in config.ru just outside Weft::Router. Names the class
  # that answered a request, and the action when one did, in a Weft-Site-Handled
  # header: "ClickToEdit::ContactCard#edit". The bench and the declarations
  # margin read it, so a click lights the declaration that handled it.
  #
  # This is weft not fitting the need yet. Weft 0.2 has no hook for what served
  # a request, so the site works it out here: it walks the path the way the
  # router does, through the registry's public API. Weft is growing one:
  # request ids are planned for v0.3, and middleware around renders and actions
  # is on its roadmap. Revisit this when they land; until then it is on the
  # pin-move list in docs/development.md.
  class HandledBy
    HEADER = "weft-site-handled"

    # The router's path is PATH_INFO as Rack::Protection cleans it (no doubled
    # slashes, no dot segments) and Sinatra's pattern decodes it, with this parser.
    TRAVERSAL = Rack::Protection::PathTraversal.new(nil)
    DECODER = URI::RFC2396_Parser.new

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      name = handler(router_path(env["PATH_INFO"]), env["REQUEST_METHOD"])
      headers[HEADER] = name if name
      [status, headers, body]
    end

    private

    def router_path(path_info)
      return "/" if path_info.to_s.empty?

      DECODER.unescape(TRAVERSAL.cleanup(path_info))
    end

    # The router's order: an action for this verb, then for a GET a component at
    # exactly this path, then a page. A route table that cannot build raises again
    # here, after weft answered with its error page; that answer stands, unnamed.
    def handler(path, request_method)
      verb = request_method == "HEAD" ? :get : request_method.downcase.to_sym
      action_handler(path, verb) || (render_handler(path) if verb == :get)
    rescue StandardError
      nil
    end

    # A nameless action answers at the component's own path, so it is named as the component is.
    def action_handler(path, verb)
      component, action = component_and_action(path)
      return unless component&.routable? && component.actions.key?([action, verb])

      action ? "#{component.name}##{action}" : component.name
    end

    def render_handler(path)
      component = Weft.registry.lookup(path)
      return component.name if component&.routable?

      page, _route_params = Weft.registry.match_page(path)
      page&.name
    end

    # The longest prefix naming a component, then one more segment as the action.
    def component_and_action(path)
      segments = path.split("/").reject(&:empty?)
      (segments.length - 1).downto(0) do |last|
        component = Weft.registry.lookup("/#{segments[0..last].join('/')}")
        next unless component

        action = segments[last + 1]&.to_sym
        return [component, action]
      end
      nil
    end
  end
end
