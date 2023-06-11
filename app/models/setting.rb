class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  field :gb_api_key, type: :string, default: ''
  field :premium, type: :boolean, default: true
  field :play_jwplayer, type: :boolean, default: false
  field :quality_play_order, type: :string, default: 'hd,high,low'
end
