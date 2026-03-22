require Rails.root.join("app/services/game_config")

Rails.application.config.x.monopoly ||= ActiveSupport::OrderedOptions.new
Rails.application.config.x.monopoly.game_config = GameConfig.defaults