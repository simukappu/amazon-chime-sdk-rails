require 'generators/chime_sdk/install_generator'

describe ChimeSdk::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs generating initializer task' do
    gen = generator
    expect(gen).to receive :copy_initializer
    gen.invoke_all
  end

  describe 'generating files' do
    before do
      run_generator
    end

    describe 'config/initializers/chime_sdk.rb as an initializer' do
      subject { file('config/initializers/chime_sdk.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain(/ChimeSdk.configure do |config|/) }
    end
  end
end