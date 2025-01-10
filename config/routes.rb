# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  post '/player_error', to: 'player#error'

  get 'xmltv', to: 'xmltv#index'
  scope '/xmltv' do
    get 'discover', to: 'xmltv#discover'
    get 'lineup', to: 'xmltv#lineup'
    get 'lineup_status', to: 'xmltv#lineup_status'
    get 'channel/:id', to: 'xmltv#channel'
    get 'epg', to: 'xmltv#epg'
  end
end
