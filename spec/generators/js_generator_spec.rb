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

      context 'with 1.3.0 as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(1.3.0)
        end

        # This test takes a long time. Skip it by xdescribe if you are developing the gem.
        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.to exist }
        end
      end

      context 'with 2.8.0 as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(2.8.0)
        end

        # This test takes a long time. Skip it by xdescribe if you are developing the gem.
        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.to exist }
        end
      end

      context 'with 1.3.1 as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(1.3.1)
        end

        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.not_to exist }
        end
      end

      context 'with 1.2.0 as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(1.2.0)
        end

        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.not_to exist }
        end
      end

      context 'with hoge as specified amazon-chime-sdk-js version' do
        before do
          run_generator %w(hoge)
        end

        describe 'app/assets/javascripts/amazon-chime-sdk.min.js' do
          subject { file('app/assets/javascripts/amazon-chime-sdk.min.js') }
          it { is_expected.not_to exist }
        end
      end
    end
  end
end