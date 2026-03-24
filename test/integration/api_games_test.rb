require "test_helper"

class ApiGamesTest < ActionDispatch::IntegrationTest
  setup do
    GameService.clear!
  end

  test "creates a game and returns full initial state" do
    post "/api/games", params: {
      player_names: [ "Peter", "Billy" ],
      config: {
        go_money: 2,
        rent_multiplier: 3,
        roll_file: "rolls_1.json"
      }
    }

    assert_response :created

    body = JSON.parse(response.body)
    assert body["game_id"].is_a?(String)
    assert body["board"].is_a?(Array)
    assert_equal 2, body["players"].length
    assert_equal body["players"].first["id"], body["current_player_id"]
  end

  test "returns validation error when roll file is invalid" do
    post "/api/games", params: {
      player_names: [ "Peter", "Billy" ],
      config: {
        roll_file: "missing.json"
      }
    }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_match(/roll_file must be one of/, body["error"])
  end
end
