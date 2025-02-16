Rails.application.routes.draw do
  namespace :api do
    get 'sunrise_sunset', to: 'sunrise_sunset#index'
  end
end
