Rails.application.routes.draw do
  resources :categories do
    member do
      get :expand
      get :contract
    end
    resources :children, :controller => 'categories' do
      member do
        get :expand
        get :contract
      end
    end
  end
  namespace :topical_map_integration do
    match 'utils/proxy/' => 'utils#proxy'
  end
end