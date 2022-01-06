require 'generators/chime_sdk/js_generator'

describe ChimeSdk::Generators::JsGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs generating Amazon Chime SDK single .js file task' do
    gen = generator
    expect(gen).to receive :build_and_copy_chime_sdk_js
    gen.invoke_all
  end

  describe 'generating files' do
    context 'when npm is installed' do
      context 'without specified amazon-chime-sdk-js version' do
        before do
          run_generator
        end

        # This test takes a long time. Skip it by xdescribe if you are developing the gem.
        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.to exist }
        end
      end

      # https://www.npmjs.com/package/amazon-chime-sdk-js
      context 'with 1.0.0 as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(1.0.0)
        end

        # This test takes a long time. Skip it by xdescribe if you are developing the gem.
        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.to exist }
        end
      end

      # https://www.npmjs.com/package/amazon-chime-sdk-js
      context 'with 2.24.0 as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(2.24.0)
        end

        # This test takes a long time. Skip it by xdescribe if you are developing the gem.
        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.to exist }
        end
      end

      # https://www.npmjs.com/package/amazon-chime-sdk-js
      context 'with 0.9.0 as specified amazon-chime-sdk-js version' do
        subject { -> { run_generator %w(0.9.0) } }
        it { is_expected.to raise_error(SystemExit) }

        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.not_to exist }
        end
      end

      # https://www.npmjs.com/package/amazon-chime-sdk-js
      context 'with 1.2.0 as specified amazon-chime-sdk-js version' do
        subject { -> { run_generator %w(1.2.0) } }
        it { is_expected.to raise_error(SystemExit) }

        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.not_to exist }
        end
      end

      context 'with hoge as specified amazon-chime-sdk-js version' do
        subject { -> { run_generator %w(hoge) } }
        it { is_expected.to raise_error(SystemExit) }

        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.not_to exist }
        end
      end
    end
  end
end