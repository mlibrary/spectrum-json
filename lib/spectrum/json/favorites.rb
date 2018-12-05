module Spectrum
  module Json
    class Favorites
      class << self
        attr_accessor :config

        def configure!(config)
          self.config = config
        end

        def suggest(username)
          params = { user: username }
          JSON.parse(Net::HTTP.get(uri('suggest', params)))
        end

        def list(username)
          params = { user: username }
          JSON.parse(Net::HTTP.get(uri('list', params)))
        end

        def favorite(username, items)
          return unless (silo = favoriteable_silo(items))
          params = {
            user: username,
            items: favoriteable_items(items),
            tags: [silo].flatten
          }
          JSON.parse(Net::HTTP.get(uri('add', params)))
        end

        def unfavorite(username, items)
          return unless (silo = favoriteable_silo(items))
          params = {
            user: username,
            items: favoriteable_items(items),
            tags: [silo].flatten
          }
          JSON.parse(Net::HTTP.get(uri('remove', params)))
        end

        def tag(username, tag, items)
          return if items.empty? || tag.empty?
          params = {
            user: username,
            items: favoriteable_items(items),
            tags: [tag].flatten
          }
          JSON.parse(Net::HTTP.get(uri('add', params)))
        end

        def untag(username, tag, items)
          return if items.empty? || tag.empty?
          params = {
            user: username,
            items: favoriteable_items(items),
            tags: [tag].flatten
          }
          JSON.parse(Net::HTTP.get(uri('remove', params)))
        end

        private

        def favoriteable_items(items)
          ret = {}
          items.each_with_index { |item, idx| ret[idx.to_s] = favoriteable_item(item) }
          ret
        end

        def favoriteable_item(item)
          {
            id: favoriteable_url(item),
            title: {
              0 => fetch_field(item, 'title')
            }
          }
        end

        def favoriteable_url(item)
          ret = []
          case (datastore = fetch_field(item, 'datastore'))
          when 'mirlyn'
            ret.push('http://mirlyn.lib.umich.edu/Record/' + fetch_field(item, 'id'))
          when 'articles'
            ret.push('http://www.lib.umich.edu/articles/details/' + fetch_field(item, 'id'))
            ret.push('http://mgetit.lib.umich.edu/?' + fetch_field(item, 'openurl'))
          when 'databases'
            ret.push('http://www.lib.umich.edu/node/' + fetch_field(item, 'id'))
          when 'journals'
            ret.push(fetch_field(item, 'id'))
          else
            ret.push(datastore + ':' + fetch_field(item, 'id'))
          end
        end

        def fetch_field(item, field_name)
          item&.find {|field| field[:uid] == field_name}.fetch(:value, nil)
        end

        def favoriteable_silo(items)
          case (datastore = fetch_field(items&.first, 'datastore'))
          when 'mirlyn'
            'mirlyn-favorite'
          when 'articles'
            'articles-favorite'
          when 'databases'
            'databases-favorite'
          when 'journals'
            'journals-favorite'
          when 'website'
            'website-favorite'
          else
            datastore
          end
        end

        def uri(type, params)
          URI(config.service + '/' + type).tap { |u| u.query = params.to_query }
        end
      end
    end
  end
end
