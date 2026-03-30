Rails.application.routes.draw do
  resource :session
  resources :links
  resources :passwords, param: :token
  resources :posts, except: [ :index ]

  get "blog", to: "posts#blog"
  get "blog/feed", to: "posts#feed", as: :blog_feed
  get "blog/new", to: "posts#new"
  get "blog/:year", to: "posts#by_year", as: :posts_by_year, constraints: { year: /\d{4}/ }
  get "blog/:year/:month", to: "posts#by_month", as: :posts_by_month, constraints: { year: /\d{4}/, month: /\d{2}/ }
  get "blog/:year/:month/:day", to: "posts#by_day", as: :posts_by_day, constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/ }
  get "blog/:year/:month/:day/:slug", to: "posts#show_by_date_slug", as: :post_by_date_slug

  get "about", to: "pages#about"
  get "projects", to: "pages#projects"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
end
