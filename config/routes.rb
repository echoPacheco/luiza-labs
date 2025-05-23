Rails.application.routes.draw do
  namespace :api do
    post 'orders/upload', to: 'orders#upload'
    get 'orders', to: 'orders#index'
  end

  get "up" => "rails/health#show", as: :rails_health_check

end
