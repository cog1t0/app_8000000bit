Rails.application.routes.draw do
  namespace :emi do
    root "home#index"
    get "karuta", to: "karuta#index"
    get "karuta/files/:name", to: "karuta#file", constraints: { name: /[^\/]+/ }, format: false, as: :karuta_file
  end

  root "app#index"
  get "/app", to: "app#index"

  # よりみちびんご
  scope :yorimichi, module: "features/yorimichi_bingo", as: :yorimichi_bingo do
    get "/", to: "bingo_cards#start", as: :start
    post "/", to: "bingo_cards#create", as: :create
    get "/:token/edit", to: "bingo_cards#edit", as: :edit
    patch "/:token", to: "bingo_cards#update", as: :update
    get "/:token", to: "bingo_cards#show", as: :card
    patch "/:token/toggle", to: "bingo_cards#toggle", as: :toggle
    post "/:token/reset", to: "bingo_cards#reset", as: :reset
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
