ActionController::Routing::Routes.draw do |map|
  map.resources(:categories, :member => {:expand => :get, :contract => :get}) do |category|
    category.resources(:children, :controller => 'categories', :member => {:expand => :get, :contract => :get})
  end
  
  map.namespace(:kmaps_integration) do |kmaps_integration|
    kmaps_integration.connect 'utils/proxy/', :controller => 'utils', :action => 'proxy'
  end
end