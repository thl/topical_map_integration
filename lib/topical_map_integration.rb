require 'topical_map_integration/engine'

# Include hook code here
#I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales')
I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.yml')]
# ActionView::Base.send :include, TopicalMapCategoriesHelper

module TopicalMapIntegration
  module Util
    MARGIN = "&nbsp;" * 5
  end
end
