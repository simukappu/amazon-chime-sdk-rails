require 'generators/chime_sdk/controllers_generator'

describe ChimeSdk::Generators::ControllersGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)
  before { prepare_destination }

  it 'runs generating controllers tasks' do
    gen = generator
    expect(gen).to receive :generate_controllers
    expect(gen).to receive(:readme).and_return(true)
    gen.invoke_all
  end

  describe 'generating files' do
    context 'without prefix argument' do
      before do
        run_generator
      end

      describe 'app/controllers/meetings_controller' do
        subject { file('app/controllers/meetings_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class MeetingsController < ApplicationController/) }
        it { is_expected.to contain(" meetings_path(params)\n") }
      end

      describe 'app/controllers/meeting_attendees_controller' do
        subject { file('app/controllers/meeting_attendees_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class MeetingAttendeesController < ApplicationController/) }
        it { is_expected.to contain(" meetings_path(params)\n") }
      end
    end

    context 'with room as prefix' do
      before do
        run_generator %w(room)
      end

      describe 'app/controllers/room_meetings_controller' do
        subject { file('app/controllers/room_meetings_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class RoomMeetingsController < ApplicationController/) }
        it { is_expected.to contain(" room_meetings_path(@room, params)\n") }
      end

      describe 'app/controllers/room_meeting_attendees_controller' do
        subject { file('app/controllers/room_meeting_attendees_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class RoomMeetingAttendeesController < ApplicationController/) }
        it { is_expected.to contain(" room_meetings_path(@room, params)\n") }
      end
    end

    context 'with room as --parent option' do
      before do
        run_generator %w(--parent room)
      end

      describe 'app/controllers/meetings_controller' do
        subject { file('app/controllers/meetings_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class MeetingsController < ApplicationController/) }
        it { is_expected.to contain(" room_meetings_path(@room, params)\n") }
      end

      describe 'app/controllers/meeting_attendees_controller' do
        subject { file('app/controllers/meeting_attendees_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class MeetingAttendeesController < ApplicationController/) }
        it { is_expected.to contain(" room_meetings_path(@room, params)\n") }
      end
    end

    context 'with api as --namespace option' do
      before do
        run_generator %w(--namespace api)
      end

      describe 'app/controllers/api/meetings_controller' do
        subject { file('app/controllers/api/meetings_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class Api::MeetingsController < ApplicationController/) }
        it { is_expected.to contain(" api_meetings_path(params)\n") }
      end

      describe 'app/controllers/api/meeting_attendees_controller' do
        subject { file('app/controllers/api/meeting_attendees_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class Api::MeetingAttendeesController < ApplicationController/) }
        it { is_expected.to contain(" api_meetings_path(params)\n") }
      end
    end

    context 'with meetings as --controllers option' do
      before do
        run_generator %w(--controllers meetings)
      end

      describe 'app/controllers/meetings_controller' do
        subject { file('app/controllers/meetings_controller.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain(/class MeetingsController < ApplicationController/) }
        it { is_expected.to contain(" meetings_path(params)\n") }
      end

      describe 'app/controllers/meeting_attendees_controller' do
        subject { file('app/controllers/meeting_attendees_controller.rb') }
        it { is_expected.not_to exist }
      end
    end
  end
end