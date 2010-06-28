module Rack
  class Request
    # almost verbatim copy of the 'url' method; just we
    # don't append the full_path to the constructed url
    def scheme_and_host
      url = scheme + "://"
      url << host

      if scheme == "https" && port != 443 ||
          scheme == "http" && port != 80
        url << ":#{port}"
      end
      url
    end
  end
end
