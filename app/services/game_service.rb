class GameService
  class << self
    def create_game(player_names = nil, config_overrides = {})
      overrides = symbolize_keys(config_overrides || {})
      overrides[:player_names] = player_names if player_names

      config = GameConfig.resolve(overrides)
      board = load_board
      game = GameData.new(player_names: config[:player_names], board: board, config: config)

      games_store[game.id] = game
      game.id
    end

    def roll_and_move(game_id)
      game = games_store.fetch(game_id) { raise KeyError, "game not found" }
      raise ArgumentError, "game is not active" unless game.status == "active"

      active_players = game.active_players
      current_player = active_players.fetch(game.current_turn)

      roll = game.next_dice_roll
      move_player!(game: game, player: current_player, roll: roll)

      BankruptcyHandler.apply!(game)
      advance_turn!(game) if game.status == "active"

      game
    end

    def fetch_game(game_id)
      games_store[game_id]
    end

    def clear!
      games_store.clear
    end

    private

    def move_player!(game:, player:, roll:)
      board_size = game.board.length
      previous_position = player[:position]
      new_position = (previous_position + roll) % board_size

      if previous_position + roll >= board_size
        player[:money] += game.config[:go_money]
      end

      player[:position] = new_position
      tile = game.board[new_position]
      TileHandler.apply(game: game, player: player, tile: tile)
    end

    def advance_turn!(game)
      active_count = game.active_players.length
      game.current_turn = (game.current_turn + 1) % active_count
    end

    def load_board
      configured = Rails.application.config.x.monopoly.board
      configured || BoardLoader.load
    end

    def games_store
      @games_store ||= {}
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) { |(key, value), out| out[key.to_sym] = value }
    end
  end
end
