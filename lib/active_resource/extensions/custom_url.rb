module ActiveResource
  module Extensions
    module CustomURL
      def self.included(base)
        base.class_eval do
          include ActiveResource::Extensions::CustomURL::InstanceMethods
        end
      end

      module InstanceMethods
        def get_url(method_name, options = {})
          self.class.prefix_for_url + "#{self.class.prefix}#{self.class.collection_name}/#{id}/#{method_name}.#{options[:format] || self.class.format.extension}"
        end        
      end
    end
  end
end
