# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  post '/player_error', to: 'player#error'

  get 'xmltv', to: 'xmltv#index'
end
