# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GreenDay::ConfigLoader do
  describe '#load_config' do
    subject(:config) { described_class.new.load_config }

    context 'when project config present' do
      it 'returns default config' do
        expect(config).to be_an_instance_of GreenDay::Config
      end
    end
  end
end
