Rails.application.routes.draw do
  # Routes for App with Rails View
  root "rooms#index"
  devise_for :users
  resources :rooms do
    resources :entries, only: [:create, :destroy]
    resources :meetings, only: [:index, :show, :create, :destroy] do
      resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show]
    end
  end

  # Routes for SPA with Rails API
  resources :spa, only: [:index]
  namespace :api do
    scope :"v1" do
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :rooms, defaults: { format: :json }, only: [:index, :show] do
        resources :meetings, defaults: { format: :json }, only: [:index, :show, :create, :destroy] do
          resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show, :create, :destroy]
        end
      end
    end
  end
end
