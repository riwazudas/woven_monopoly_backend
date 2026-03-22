class RentCalculator
  class << self
    def calculate(tile:, owner:, board:, rent_multiplier: 1)
      base_rent = tile.fetch(:price).to_i * rent_multiplier
      return base_rent unless monopoly_owner_for_colour?(owner: owner, board: board, colour: tile[:colour])

      base_rent * 2
    end

    private

    def monopoly_owner_for_colour?(owner:, board:, colour:)
      return false if colour.nil?

      properties_in_colour = board.select do |tile|
        tile[:type] == "property" && tile[:colour] == colour
      end
      return false if properties_in_colour.length < 2

      properties_in_colour.all? { |tile| tile[:owner_id] == owner[:id] }
    end
  end
end
