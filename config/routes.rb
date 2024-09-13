Rails.application.routes.draw do
  root "buses#index"
  get "/stop", to: "buses#stop"
  get "/postcode", to: "buses#postcode"
end
