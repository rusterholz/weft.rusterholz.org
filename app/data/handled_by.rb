# frozen_string_literal: true

module SiteData
  # Rack middleware, used in config.ru just outside Weft::Router. Names the class
  # that answered a request, and the action when one did, in a Weft-Site-Handled
  # header: "ClickToEdit::ContactCard#edit". The bench and the declarations
  # margin read it, so a click lights the declaration that handled it.
  #
  # This is weft not fitting the need yet. Weft 0.2 has no hook for what served
  # a request, so the site works it out here: it walks the path the way the
  # router does, through the registry's public API (the longest prefix naming a
  # component, then one more segment as the action). Weft is growing one:
  # request ids are planned for v0.3, and middleware around renders and actions
  # is on its roadmap. Revisit this when they land; until then it is on the
  # pin-move list in docs/development.md.
  class HandledBy
    HEADER = "weft-site-handled"

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      name = handler(env["PATH_INFO"], env["REQUEST_METHOD"])
      headers[HEADER] = name if name
      [status, headers, body]
    end

    private

    # The response is already made. A registry that cannot build its route table
    # raises here as it did inside weft, which answered with the error page;
    # that answer stands, naming nothing.
    def handler(path, request_method)
      verb = request_method == "HEAD" ? :get : request_method.downcase.to_sym
      component, action = component_and_action(path)
      return component_handler(component, action, verb) if component&.routable?

      page_handler(path, verb)
    rescue StandardError
      nil
    end

    # A declared action for this verb, or, for a GET with nothing after the
    # component's path, the component rendering itself.
    def component_handler(component, action, verb)
      if component.actions.key?([action, verb])
        action ? "#{component.name}##{action}" : component.name
      elsif verb == :get && action.nil?
        component.name
      end
    end

    def page_handler(path, verb)
      return unless verb == :get

      page, _route_params = Weft.registry.match_page(path)
      page&.name
    end

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
