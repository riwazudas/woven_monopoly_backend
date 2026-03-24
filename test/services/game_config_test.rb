require "test_helper"

class GameConfigTest < ActiveSupport::TestCase
  test "returns deterministic defaults" do
    defaults = GameConfig.defaults

    assert_equal 1, defaults[:go_money]
    assert_equal [ "Peter", "Billy", "Charlotte", "Sweedal" ], defaults[:player_names]
    assert_equal 1, defaults[:rent_multiplier]
    assert_equal "rolls_1.json", defaults[:roll_file]
    assert defaults[:dice_sequence].is_a?(Array)
    assert defaults[:dice_sequence].all? { |roll| roll.is_a?(Integer) && roll.positive? }
  end

  test "merges valid overrides with roll file" do
    config = GameConfig.resolve(go_money: 2, rent_multiplier: 2, player_names: [ "A", "B" ], roll_file: "rolls_2.json")

    assert_equal 2, config[:go_money]
    assert_equal 2, config[:rent_multiplier]
    assert_equal [ "A", "B" ], config[:player_names]
    assert_equal "rolls_2.json", config[:roll_file]
    assert config[:dice_sequence].is_a?(Array)
    assert config[:dice_sequence].all? { |roll| roll.is_a?(Integer) && roll.positive? }
  end

  test "returns available roll files" do
    roll_files = GameConfig.available_roll_files

    assert roll_files.is_a?(Array)
    assert_includes roll_files, "rolls_1.json"
  end

  test "rejects unknown roll file" do
    error = assert_raises(ArgumentError) { GameConfig.resolve(roll_file: "missing.json") }

    assert_match(/roll_file must be one of/, error.message)
  end

  test "rejects unknown keys" do
    error = assert_raises(ArgumentError) { GameConfig.resolve(unknown: true) }
    assert_match(/unsupported config keys/, error.message)
  end
end
