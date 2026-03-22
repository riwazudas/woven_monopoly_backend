class BoardLoader
  SUPPORTED_TILE_TYPES = %w[go property free_parking].freeze
  FREE_PARKING_NAME = "Free Parking".freeze

  class << self
    def load(path: Rails.root.join("board.json"))
      raw_tiles = JSON.parse(File.read(path))

      go_tile, non_corner_tiles = parse_tiles(raw_tiles)
      side_capacity = (non_corner_tiles.length / 4.0).ceil
      required_side_tiles = side_capacity * 4

      filled_side_tiles = non_corner_tiles + Array.new(required_side_tiles - non_corner_tiles.length) do
        free_parking_tile
      end

      build_square_perimeter(go_tile, filled_side_tiles, side_capacity)
    end

    private

    def parse_tiles(raw_tiles)
      raise ArgumentError, "board must contain an array of tiles" unless raw_tiles.is_a?(Array)

      go_tile = nil
      non_corner_tiles = []

      raw_tiles.each do |tile|
        normalized = normalize_tile(tile)

        if normalized[:type] == "go"
          raise ArgumentError, "board must contain exactly one GO tile" if go_tile

          go_tile = normalized
        else
          non_corner_tiles << normalized
        end
      end

      raise ArgumentError, "board must contain exactly one GO tile" unless go_tile

      [go_tile, non_corner_tiles]
    end

    def normalize_tile(tile)
      raise ArgumentError, "tile must be an object" unless tile.is_a?(Hash)

      type = tile.fetch("type").to_s
      unless SUPPORTED_TILE_TYPES.include?(type)
        raise ArgumentError, "unsupported tile type: #{type}"
      end

      {
        name: tile.fetch("name"),
        type: type,
        price: tile["price"],
        colour: tile["colour"]
      }
    end

    def build_square_perimeter(go_tile, side_tiles, side_capacity)
      output = []
      output << go_tile

      4.times do |side_index|
        start = side_index * side_capacity
        output.concat(side_tiles.slice(start, side_capacity))

        # Corner slots are fixed: GO plus 3 Free Parking corners.
        output << free_parking_tile if side_index < 3
      end

      output.each_with_index.map do |tile, index|
        {
          id: index + 1,
          name: tile[:name],
          type: tile[:type],
          price: tile[:price],
          colour: tile[:colour],
          position: index
        }
      end
    end

    def free_parking_tile
      {
        name: FREE_PARKING_NAME,
        type: "free_parking",
        price: nil,
        colour: nil
      }
    end
  end
end