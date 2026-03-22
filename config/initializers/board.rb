Rails.application.config.x.monopoly ||= ActiveSupport::OrderedOptions.new
Rails.application.config.x.monopoly.board = BoardLoader.load