# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GreenDay::Cli do
  let!(:cli) { described_class.new }

  describe 'new [contest name]' do
    # https://atcoder.jp/contests/abc150
    subject { cli.new('abc150') }

    before :example do
      subject
    end

    after :example do
      FileUtils.remove_entry_secure('abc150')
    end

    it 'creates contest name dir and file for submit' do
      aggregate_failures do
        expect(File.exist?('abc150/A.rb')).to be_truthy
        expect(File.exist?('abc150/B.rb')).to be_truthy
        expect(File.exist?('abc150/C.rb')).to be_truthy
        expect(File.exist?('abc150/D.rb')).to be_truthy
        expect(File.exist?('abc150/E.rb')).to be_truthy
        expect(File.exist?('abc150/F.rb')).to be_truthy
      end
    end

    it 'creates spec file' do
      aggregate_failures do
        expect(File.exist?('abc150/spec/A_spec.rb')).to be_truthy
        expect(File.exist?('abc150/spec/B_spec.rb')).to be_truthy
        expect(File.exist?('abc150/spec/C_spec.rb')).to be_truthy
        expect(File.exist?('abc150/spec/D_spec.rb')).to be_truthy
        expect(File.exist?('abc150/spec/E_spec.rb')).to be_truthy
        expect(File.exist?('abc150/spec/F_spec.rb')).to be_truthy
      end
    end

    it 'writes spec code' do
      expect(File.read('abc150/spec/A_spec.rb')).to eq(
        <<~SPEC
          RSpec.describe 'test' do
            it 'test with "2 900\\n"' do
              io = IO.popen("ruby abc150/A.rb", "w+")
              io.puts("2 900\\n")
              io.close_write
              expect(io.readlines.join).to eq("Yes\\n")
            end

            it 'test with "1 501\\n"' do
              io = IO.popen("ruby abc150/A.rb", "w+")
              io.puts("1 501\\n")
              io.close_write
              expect(io.readlines.join).to eq("No\\n")
            end

            it 'test with "4 2000\\n"' do
              io = IO.popen("ruby abc150/A.rb", "w+")
              io.puts("4 2000\\n")
              io.close_write
              expect(io.readlines.join).to eq("Yes\\n")
            end

          end
        SPEC
      )
    end
  end

  describe 'login' do
    subject { cli.login }

    # need Atcoder password and username in .env
    # see env.sample
    before :example do
      allow($stdin).to receive(:gets) do
        inputs.shift
      end
    end

    after :example do
      FileUtils.remove(GreenDay::AtcoderClient::COOKIE_FILE_NAME, force: true)
    end

    context 'valid name and password' do
      let(:inputs) { [ENV['USER_NAME'], ENV['PASSWORD']] }

      it 'creates cookie-store' do
        subject

        expect(File.exist?('.cookie-store')).to be_truthy
      end
    end

    context 'invalid name and password' do
      let(:inputs) { %w[invalid_name invalid_password] }

      it 'raises error' do
        expect { subject }.to raise_error(GreenDay::Error)
      end
    end
  end
end
