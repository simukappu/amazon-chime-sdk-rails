Rails.application.routes.draw do
  # Routes for Rails application with Action View
  root "rooms#index"
  devise_for :users
  resources :rooms do
    resources :entries, only: [:create, :destroy]
    resources :meetings, only: [:index, :show, :create, :destroy] do
      resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show]
    end
  end

  # Routes for REST API with Rails API application
  namespace :api do
    scope :"v1" do
      # Private API with authentication
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :rooms, defaults: { format: :json }, only: [:index, :show] do
        resources :meetings, defaults: { format: :json }, only: [:index, :show, :create, :destroy] do
          resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show, :create, :destroy]
        end
      end

      # Public API called from Amazon Chime SDK React Meeting Demo application
      namespace :public do
        resources :meetings, defaults: { format: :json, create_attendee_from_meeting: false }, only: [:index, :show, :destroy] do
          resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show, :destroy]
        end
      end
    end
  end
end
