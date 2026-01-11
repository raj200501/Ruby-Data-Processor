module RubyDataProcessor
  class Router
    def initialize
      @routes = []
    end

    def add(method, path, handler)
      pattern = path_to_regex(path)
      @routes << [method, pattern, handler]
    end

    def route(request)
      match = @routes.find { |method, pattern, _handler| method == request.method && pattern.match?(request.path) }
      return nil unless match

      method, pattern, handler = match
      params = pattern.match(request.path)
      handler.call(request, params)
    end

    private

    def path_to_regex(path)
      pattern = path.gsub(/:\w+/) { |match| "(?<#{$&[1..]}>[^/]+)" }
      Regexp.new("^#{pattern}$")
    end
  end
end
