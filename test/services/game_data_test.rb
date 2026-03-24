require "test_helper"

class GameDataTest < ActiveSupport::TestCase
  test "initializes deterministic game state" do
    board = [
      { id: 1, name: "GO", type: "go", position: 0 }
    ]
    config = {
      go_money: 1,
      player_names: ["A", "B"],
      rent_multiplier: 1,
      dice_sequence: [1, 2, 3]
    }

    game = GameData.new(player_names: ["A", "B"], board: board, config: config)

    assert game.id.is_a?(String)
    assert_equal 2, game.players.length
    assert_equal "active", game.status
    assert_equal 0, game.current_roll_index
    assert_equal [1, 2, 3], game.dice_rolls
  end

  test "returns next deterministic dice roll and increments index" do
    game = GameData.new(
      player_names: ["A"],
      board: [{ id: 1, name: "GO", type: "go", position: 0 }],
      config: {
        go_money: 1,
        player_names: ["A"],
        rent_multiplier: 1,
        dice_sequence: [4]
      }
    )

    assert_equal 4, game.next_dice_roll
    assert_equal 1, game.current_roll_index

    error = assert_raises(ArgumentError) { game.next_dice_roll }
    assert_match(/no dice rolls remaining/, error.message)
  end
end
