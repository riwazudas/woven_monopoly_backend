class BankruptcyHandler
  class << self
    def apply!(game)
      game.players.each do |player|
        next if player[:bankrupt]
        next unless player[:money].negative?

        bankrupt_player!(game: game, player: player)
      end

      active = game.active_players
      if active.length <= 1
        game.status = "finished"
        game.winner_id = active.first&.dig(:id)
        game.current_turn = 0
      elsif game.current_turn >= active.length
        game.current_turn = 0
      end
    end

    private

    def bankrupt_player!(game:, player:)
      player[:bankrupt] = true

      game.board.each do |tile|
        next unless tile[:type] == "property" && tile[:owner_id] == player[:id]

        tile[:owner_id] = nil
      end

      player[:properties] = []
    end
  end
end
