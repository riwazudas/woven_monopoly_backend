class GameData
  attr_reader :id, :board, :players, :config, :dice_rolls
  attr_accessor :current_turn, :status, :current_roll_index, :winner_id

  def initialize(player_names:, board:, config:)
    @id = SecureRandom.uuid
    @board = deep_copy(board)
    @config = deep_copy(config)
    @dice_rolls = Array(@config.fetch(:dice_sequence))
    @players = Array(player_names).map.with_index do |name, index|
      {
        id: SecureRandom.uuid,
        name: name,
        order: index,
        money: 16,
        position: 0,
        properties: [],
        bankrupt: false
      }
    end

    @current_turn = 0
    @status = "active"
    @current_roll_index = 0
    @winner_id = nil
  end

  def next_dice_roll
    raise ArgumentError, "no dice rolls remaining" if current_roll_index >= dice_rolls.length

    roll = dice_rolls[current_roll_index]
    self.current_roll_index += 1
    roll
  end

  def active_players
    players.reject { |player| player[:bankrupt] }
  end

  def to_h
    {
      id: id,
      board: board,
      players: players,
      current_turn: current_turn,
      status: status,
      dice_rolls: dice_rolls,
      current_roll_index: current_roll_index,
      winner_id: winner_id,
      config: config
    }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end

  private

  def deep_copy(object)
    Marshal.load(Marshal.dump(object))
  end
end
