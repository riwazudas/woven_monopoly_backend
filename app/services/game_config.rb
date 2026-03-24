class GameConfig
  DEFAULT_PLAYER_NAMES = [ "Peter", "Billy", "Charlotte", "Sweedal" ].freeze

  SUPPORTED_KEYS = %i[
    go_money
    player_names
    rent_multiplier
    roll_file
    dice_sequence
  ].freeze

  class << self
    def defaults
      @defaults ||= {
        go_money: 1,
        player_names: DEFAULT_PLAYER_NAMES,
        rent_multiplier: 1,
        roll_file: default_roll_file,
        dice_sequence: load_default_dice_sequence
      }.freeze

      deep_copy(@defaults)
    end

    def resolve(overrides = {})
      overrides = symbolize_keys(overrides || {})
      validate_override_keys!(overrides)

      if overrides.key?(:roll_file)
        overrides[:dice_sequence] = load_dice_sequence(overrides[:roll_file])
      end

      merged = defaults.merge(overrides)
      validate!(merged)
      merged
    end

    def available_roll_files
      Dir.glob(Rails.root.join("rolls_*.json")).map { |path| File.basename(path) }.sort
    end

    private

    def default_roll_file
      "rolls_1.json"
    end

    def load_default_dice_sequence
      load_dice_sequence(default_roll_file)
    end

    def load_dice_sequence(roll_file)
      file_name = roll_file.to_s
      unless available_roll_files.include?(file_name)
        raise ArgumentError, "roll_file must be one of: #{available_roll_files.join(", ")}"
      end

      JSON.parse(File.read(Rails.root.join(file_name)))
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) { |(key, value), out| out[key.to_sym] = value }
    end

    def validate_override_keys!(overrides)
      unknown_keys = overrides.keys - SUPPORTED_KEYS
      return if unknown_keys.empty?

      raise ArgumentError, "unsupported config keys: #{unknown_keys.join(", ")}"
    end

    def validate!(config)
      unless config[:go_money].is_a?(Numeric) && config[:go_money].positive?
        raise ArgumentError, "go_money must be a positive number"
      end

      unless config[:rent_multiplier].is_a?(Numeric) && config[:rent_multiplier].positive?
        raise ArgumentError, "rent_multiplier must be a positive number"
      end

      unless config[:player_names].is_a?(Array) && config[:player_names].all? { |name| name.is_a?(String) && !name.empty? }
        raise ArgumentError, "player_names must be an array of non-empty strings"
      end

      unless config[:dice_sequence].is_a?(Array) && config[:dice_sequence].all? { |roll| roll.is_a?(Integer) && roll.positive? }
        raise ArgumentError, "dice_sequence must be an array of positive integers"
      end
    end

    def deep_copy(object)
      Marshal.load(Marshal.dump(object))
    end
  end
end
