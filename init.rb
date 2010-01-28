ActiveResource::Base.send :include, ActiveResource::Acts::Tree
ActiveResource::Base.send :include, ActiveResource::Extensions::URL
ActiveResource::Base.send :include, ActiveResource::Extensions::CustomURL

# Include hook code here
require 'patches/active_resource_patch'
require 'topical_map_builder_integration'
ActionView::Base.send :include, TopicalMapCategoriesHelper