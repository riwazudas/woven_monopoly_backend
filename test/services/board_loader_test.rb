require "test_helper"

class BoardLoaderTest < ActiveSupport::TestCase
  test "loads board into square perimeter with fixed corners" do
    board = BoardLoader.load

    assert_equal 12, board.length

    assert_equal "go", board[0][:type]
    assert_equal "free_parking", board[3][:type]
    assert_equal "free_parking", board[6][:type]
    assert_equal "free_parking", board[9][:type]

    board.each_with_index do |tile, index|
      assert_equal index + 1, tile[:id]
      assert_equal index, tile[:position]
    end
  end

  test "raises on unsupported tile type" do
    invalid_board_path = Rails.root.join("tmp", "invalid_board.json")
    File.write(
      invalid_board_path,
      JSON.dump([
        { name: "GO", type: "go" },
        { name: "Jail", type: "jail" }
      ])
    )

    error = assert_raises(ArgumentError) { BoardLoader.load(path: invalid_board_path) }
    assert_match(/unsupported tile type/, error.message)
  ensure
    File.delete(invalid_board_path) if invalid_board_path && File.exist?(invalid_board_path)
  end
end