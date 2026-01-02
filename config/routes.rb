Rails.application.routes.draw do
  get "/app", to: "app#index"

  # RabbitHole routes
  post "/rabbit-hole", to: "rabbit_hole#create", as: :rabbit_hole_create
  get  "/rabbit-hole", to: "rabbit_hole#show", as: :rabbit_hole
  get  "/rabbit-hole/created", to: "rabbit_hole#created", as: :rabbit_hole_created
  get  "/rabbit-hole-form", to: "rabbit_hole#form", as: :rabbit_hole_form

  # よりみちびんご
  scope :yorimichi, module: "features/yorimichi_bingo", as: :yorimichi_bingo do
    get "/", to: "bingo_cards#start", as: :start
    post "/", to: "bingo_cards#create", as: :create
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
