Rails.application.config.x.monopoly ||= ActiveSupport::OrderedOptions.new
Rails.application.config.x.monopoly.game_config = GameConfig.defaults