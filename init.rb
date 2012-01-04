# Include hook code here
#I18n.load_path << File.join(File.dirname(__FILE__), 'config', 'locales')
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '*.yml')]
require 'topical_map_builder_integration'
ActionView::Base.send :include, TopicalMapCategoriesHelper