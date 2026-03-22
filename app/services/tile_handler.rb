class TileHandler
  class << self
    def apply(game:, player:, tile:)
      case tile[:type]
      when "go"
        :go
      when "free_parking"
        :free_parking
      when "property"
        handle_property(game: game, player: player, tile: tile)
      else
        raise ArgumentError, "unsupported tile type: #{tile[:type]}"
      end
    end

    private

    def handle_property(game:, player:, tile:)
      owner_id = tile[:owner_id]

      if owner_id.nil?
        buy_property(player: player, tile: tile)
        return :bought
      end

      return :already_owned if owner_id == player[:id]

      owner = game.players.find { |candidate| candidate[:id] == owner_id }
      unless owner
        tile[:owner_id] = nil
        buy_property(player: player, tile: tile)
        return :bought
      end

      rent = RentCalculator.calculate(
        tile: tile,
        owner: owner,
        board: game.board,
        rent_multiplier: game.config[:rent_multiplier]
      )

      player[:money] -= rent
      owner[:money] += rent unless owner[:bankrupt]
      :rent_paid
    end

    def buy_property(player:, tile:)
      price = tile.fetch(:price).to_i
      player[:money] -= price
      tile[:owner_id] = player[:id]
      player[:properties] << tile[:id]
    end
  end
end
