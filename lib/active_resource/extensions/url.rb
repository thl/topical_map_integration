module ActiveResource
  module Extensions
    module URL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def collection_url(options = {})
          prefix_for_url + "#{prefix}#{collection_name}.#{options[:format] || format.extension}"
        end
        
        def element_url(id, options = {})
          prefix_for_url + "#{prefix}#{collection_name}/#{id}.#{options[:format] || format.extension}"
        end
        
        def prefix_for_url
          host = site.host
          host = connection.host_from_header if host=='127.0.0.1'
          "#{site.scheme}://#{host}:#{site.port}"
        end
      end
    end
  end
end
