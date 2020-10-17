require 'generators/chime_sdk/views_generator'

describe ChimeSdk::Generators::ViewsGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs generating views tasks' do
    gen = generator
    expect(gen).to receive :generate_views
    gen.invoke_all
  end

  describe 'generating files' do
    context 'without prefix argument' do
      before do
        run_generator
      end

      describe 'app/views/meetings/index.html.erb' do
        subject { file('app/views/meetings/index.html.erb') }
        it { is_expected.to exist }
      end

      describe 'app/views/meetings/show.html.erb' do
        subject { file('app/views/meetings/show.html.erb') }
        it { is_expected.to exist }
      end
    end

    context 'with room as prefix argument' do
      before do
        run_generator %w(room)
      end

      describe 'rapp/views/oom_meetings/index.html.erb' do
        subject { file('app/views/room_meetings/index.html.erb') }
        it { is_expected.to exist }
      end

      describe 'app/views/room_meetings/show.html.erb' do
        subject { file('app/views/room_meetings/show.html.erb') }
        it { is_expected.to exist }
      end
    end
  end
end