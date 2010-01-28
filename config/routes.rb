ActionController::Routing::Routes.draw do |map|
  map.resources(:categories, :member => {:expand => :get, :contract => :get}) do |category|
    category.resources(:children, :controller => 'categories', :member => {:expand => :get, :contract => :get})
  end
end