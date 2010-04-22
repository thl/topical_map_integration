ActiveResource::Base.send :include, ActiveResource::Acts::Tree
ActiveResource::Base.send :include, ActiveResource::Extensions::URL

# Include hook code here
require 'topical_map_builder_integration'
ActionView::Base.send :include, TopicalMapCategoriesHelper