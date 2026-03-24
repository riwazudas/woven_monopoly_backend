require "test_helper"

class ApiMovesTest < ActionDispatch::IntegrationTest
  setup do
    GameService.clear!
  end

  test "roll endpoint returns move details and updated game" do
    post "/api/games", params: {
      player_names: [ "Peter", "Billy" ],
      config: {
        roll_file: "rolls_1.json"
      }
    }
    assert_response :created
    game_id = JSON.parse(response.body)["game_id"]

    post "/api/games/#{game_id}/moves/roll"
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 0, body["previous_position"]
    assert_equal 1, body["new_position"]
    assert_equal "property", body.dig("tile_landed_on", "type")
    assert body.key?("action_required")
    assert body.dig("updated_game", "players").is_a?(Array)
  end

  test "returns not found for unknown game" do
    post "/api/games/missing-game-id/moves/roll"

    assert_response :not_found
  end

  test "lists available roll files" do
    get "/api/roll_files"

    assert_response :success
    body = JSON.parse(response.body)
    assert body["roll_files"].is_a?(Array)
    assert_includes body["roll_files"], "rolls_1.json"
  end
end
