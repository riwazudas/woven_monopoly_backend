require Rails.root.join("app/services/board_loader")

Rails.application.config.x.monopoly ||= ActiveSupport::OrderedOptions.new
Rails.application.config.x.monopoly.board = BoardLoader.load