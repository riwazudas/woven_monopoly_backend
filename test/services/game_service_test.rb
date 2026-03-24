require "test_helper"

class GameServiceTest < ActiveSupport::TestCase
  setup do
    GameService.clear!
  end

  test "creates and stores game in memory" do
    game_id = GameService.create_game(["A", "B"], dice_sequence: [1])

    assert game_id.is_a?(String)
    assert GameService.fetch_game(game_id)
  end

  test "buy then pay rent with deterministic sequence" do
    game_id = GameService.create_game(["A", "B"], dice_sequence: [1, 1], rent_multiplier: 1)

    game_after_first_turn = GameService.roll_and_move(game_id)
    player_a = game_after_first_turn.players.find { |player| player[:name] == "A" }
    first_property = game_after_first_turn.board[1]

    assert_equal player_a[:id], first_property[:owner_id]
    assert_equal 15, player_a[:money]

    game_after_second_turn = GameService.roll_and_move(game_id)
    player_a = game_after_second_turn.players.find { |player| player[:name] == "A" }
    player_b = game_after_second_turn.players.find { |player| player[:name] == "B" }

    assert_equal 16, player_a[:money]
    assert_equal 15, player_b[:money]
  end

  test "collects go money when passing go" do
    game_id = GameService.create_game(["A", "B"], dice_sequence: [12], go_money: 1)

    game = GameService.roll_and_move(game_id)
    player_a = game.players.find { |player| player[:name] == "A" }

    assert_equal 17, player_a[:money]
    assert_equal 0, player_a[:position]
  end

  test "marks bankruptcy and determines winner" do
    game_id = GameService.create_game(["A", "B"], dice_sequence: [10, 10], rent_multiplier: 20)

    GameService.roll_and_move(game_id)
    game = GameService.roll_and_move(game_id)

    player_a = game.players.find { |player| player[:name] == "A" }
    player_b = game.players.find { |player| player[:name] == "B" }

    assert_equal true, player_b[:bankrupt]
    assert_equal "finished", game.status
    assert_equal player_a[:id], game.winner_id
  end
end
