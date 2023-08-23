# frozen_string_literal: true

module GreenDay
  class Config
    def initialize(hash)
      @hash = hash
    end

    def to_hash
      @hash.dup
    end

    def merge(config)
      self.class.new(
        deep_merge(config)
      )
    end

    private

    def deep_merge(config)
      merger = proc { |_key, v1, v2|
        v1.is_a?(Hash) && v2.is_a?(Hash) ? v1.merge(v2, &merger) : v2
      }
      @hash.merge(config.to_hash, &merger)
    end
  end
end
