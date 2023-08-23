# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GreenDay::Config do
  describe '#merge' do
    subject { described_class.new(default_config).merge(user_config) }

    let(:default_config) do
      YAML.safe_load(<<~CONFIG
        generate:
          root:  'contests'
          spec_dir_flatten: false
          spec_dir: 'spec'
      CONFIG
                    )
    end
    let(:user_config) do
      YAML.safe_load(<<~CONFIG
        generate:
          root:  'src'
          spec_dir_flatten: true
      CONFIG
                    )
    end

    it 'returns merged config' do
      expect(subject.to_hash).to eq(
        'generate' => {
          'root' => 'src',
          'spec_dir_flatten' => true,
          'spec_dir' => 'spec'
        }
      )
    end
  end
end
