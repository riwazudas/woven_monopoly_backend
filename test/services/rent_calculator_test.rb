require "test_helper"

class RentCalculatorTest < ActiveSupport::TestCase
  test "returns base rent multiplied by config multiplier" do
    owner = { id: "owner-1" }
    tile = { id: 2, type: "property", price: 3, colour: "Green", owner_id: "owner-1" }
    board = [tile]

    rent = RentCalculator.calculate(tile: tile, owner: owner, board: board, rent_multiplier: 2)

    assert_equal 6, rent
  end

  test "doubles rent when owner has full colour group" do
    owner = { id: "owner-1" }
    board = [
      { id: 2, type: "property", price: 2, colour: "Red", owner_id: "owner-1" },
      { id: 3, type: "property", price: 3, colour: "Red", owner_id: "owner-1" }
    ]

    rent = RentCalculator.calculate(tile: board[0], owner: owner, board: board, rent_multiplier: 1)

    assert_equal 4, rent
  end
end
