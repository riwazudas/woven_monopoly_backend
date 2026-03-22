class GameConfig
  DEFAULT_PLAYER_NAMES = ["Peter", "Billy", "Charlotte", "Sweedal"].freeze

  SUPPORTED_KEYS = %i[
    go_money
    player_names
    rent_multiplier
    dice_sequence
  ].freeze

  class << self
    def defaults
      @defaults ||= {
        go_money: 1,
        player_names: DEFAULT_PLAYER_NAMES,
        rent_multiplier: 1,
        dice_sequence: load_default_dice_sequence
      }.freeze

      deep_copy(@defaults)
    end

    def resolve(overrides = {})
      overrides = symbolize_keys(overrides || {})
      validate_override_keys!(overrides)

      merged = defaults.merge(overrides)
      validate!(merged)
      merged
    end

    private

    def load_default_dice_sequence
      path = Rails.root.join("rolls_1.json")
      JSON.parse(File.read(path))
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