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
end