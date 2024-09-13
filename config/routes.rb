Rails.application.routes.draw do
  get "/stop/:stop", to: "buses#index"
  get "/postcode/:postcode", to: "buses#postcode"
end
