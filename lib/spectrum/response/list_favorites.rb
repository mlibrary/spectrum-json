module Spectrum
  module Response
    class ListFavorites < Action
      def spectrum
        return needs_authentication unless request.logged_in?
        uri = URI('https://www.lib.umich.edu/favorites/api/list')
        uri.query = {'username' => request.username}.to_query
        req = Net::HTTP::Get.new(uri)
        ret = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(req)
        end
        ::Spectrum::Response::RawJSON.new(ret.body)
      end
    end
  end
end
