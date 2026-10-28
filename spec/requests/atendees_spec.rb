describe ChimeSdk::Controller::Attendees, type: :request do
  before(:all) do
    @meeting_id        = "01234567-89ab-cdef-ghij-klmnopqrstuv"
    @attendee_id       = "76543210-ba98-fedc-jihg-vutsrqponmlk"
    @dummy_meeting_id  = "91234567-89ab-cdef-ghij-klmnopqrstuv"
    @dummy_attendee_id = "96543210-ba98-fedc-jihg-vutsrqponmlk"
    @other_meeting_id  = "81234567-89ab-cdef-ghij-klmnopqrstuv"
    @other_app_attendee_id = "86543210-ba98-fedc-jihg-vutsrqponmlk"

    @room = create(:room)
    @other_room = create(:room)
    @attendee_user = create(:user)
    @room.add_member(@attendee_user)
    test_attendee = {
      external_user_id: "ChimeSdkRailsApp-test-User-#{@attendee_user.id}",
      attendee_id: @attendee_id,
      join_token: "dummy",
      capabilities: {
        audio: "SendReceive",
        video: "SendReceive",
        content: "SendReceive"
      }
    }
    dummy_attendee = {
      external_user_id: "ChimeSdkRailsApp-test-User-0",
      attendee_id: @dummy_attendee_id,
      join_token: "dummy",
      capabilities: {
        audio: "SendReceive",
        video: "SendReceive",
        content: "SendReceive"
      }
    }

    meeting_of = -> (meeting_id, room) {
      {
        meeting_id: meeting_id,
        external_meeting_id: "ChimeSdkRailsApp-test-PrivateRoom-#{room.id}",
        media_region: "us-east-1",
        media_placement: { audio_host_url: "dummy" }
      }
    }

    other_app_attendee = test_attendee.merge(
      external_user_id: "OtherApp-test-User-#{@attendee_user.id}",
      attendee_id: @other_app_attendee_id
    )

    # Use stubs for the AWS SDK for Ruby
    client = Aws::ChimeSDKMeetings::Client.new(stub_responses: true)
    client.stub_responses(:get_meeting, -> (context) {
      case context.params[:meeting_id]
      when @meeting_id then { meeting: meeting_of.(@meeting_id, @room) }
      when @other_meeting_id then { meeting: meeting_of.(@other_meeting_id, @other_room) }
      else 'ForbiddenException'
      end
    })
    client.stub_responses(:list_attendees, {
      attendees: [ test_attendee, dummy_attendee ]
    })
    client.stub_responses(:get_attendee, -> (context) {
      context.params[:meeting_id] == @meeting_id ?
        (case context.params[:attendee_id]
         when @attendee_id then { attendee: test_attendee }
         when @other_app_attendee_id then { attendee: other_app_attendee }
         else 'NotFoundException'
         end) :
        'ForbiddenException'
    })
    client.stub_responses(:create_attendee, -> (context) {
      context.params[:meeting_id] == @meeting_id ? {
        attendee: {
          external_user_id: context.params[:external_user_id],
          attendee_id: @attendee_id,
          join_token: "dummy"
        }
      } : 'BadRequestException'
    })
    client.stub_responses(:delete_attendee, -> (context) {
      context.params[:attendee_id] == @attendee_id ? {} : 'NotFoundException'
    })
    ChimeSdk::MeetingCoordinator.reset_client(client)
  end

  context "Rails API" do
    let(:api_root_path) { "/api/v1" }
    let(:api_path) { "#{api_root_path}/rooms/#{@room.id}" }
    let(:api_meetings_path) { "#{api_path}/meetings/#{@meeting_id}" }

    before do
      @user = create(:user)
    end

    context "requests from unauthorized user" do
      describe "GET /meetings/:meeting_id/attendees" do
        it "returns response with 401 status" do
          get "#{api_meetings_path}/attendees", headers: @auth_headers
          expect(response).to have_http_status(401)
        end
      end
    end

    context "requests from authorized user" do
      before do
        # Sign in with Devise Token Auth
        post "#{api_root_path}/auth/sign_in", params: { email: @user.email, password: "password" }
        @auth_headers = response.header.slice("access-token", "client", "uid")
      end

      context "when the authorized user is not a member of the private room" do
        describe "GET /meetings/:meeting_id/attendees" do
          it "returns response with 403 status" do
            get "#{api_meetings_path}/attendees", headers: @auth_headers
            expect(response).to have_http_status(403)
          end
        end
      end

      context "when the authorized user is a member of the private room" do
        before do
          @room.add_member(@user)
        end

        describe "GET /meetings/:meeting_id/attendees" do
          before do
            get "#{api_meetings_path}/attendees", headers: @auth_headers
          end

          it "returns response with 200 status" do
            expect(response).to have_http_status(200)
          end

          it "returns attendees list" do
            expect(JSON.parse(response.body)["attendees"].length).to eq(2)
          end

          it "returns valid attendee in the list" do
            expect(JSON.parse(response.body)["attendees"][0]["Attendee"]["AttendeeId"]).to eq(@attendee_id)
          end

          it "does not return join tokens of attendees in the list" do
            JSON.parse(response.body)["attendees"].each do |attendee|
              expect(attendee["Attendee"]).not_to have_key("JoinToken")
            end
          end
        end

        describe "GET /meetings/:meeting_id/attendees/:attendee_id" do
          context "when the attendee is found" do
            before do
              get "#{api_meetings_path}/attendees/#{@attendee_id}", headers: @auth_headers
            end

            it "returns response with 200 status" do
              expect(response).to have_http_status(200)
            end

            it "returns valid attendee" do
              expect(JSON.parse(response.body)["Attendee"]["AttendeeId"]).to eq(@attendee_id)
            end

            it "does not return join token of the attendee" do
              expect(JSON.parse(response.body)["Attendee"]).not_to have_key("JoinToken")
            end

            it "returns application metadata in the attendee" do
              expect(JSON.parse(response.body)["Attendee"]["ApplicationMetadata"]["User"]["id"]).to eq(@attendee_user.id)
            end

            it "returns only id and name of the user in application metadata" do
              expect(JSON.parse(response.body)["Attendee"]["ApplicationMetadata"]["User"].keys).to match_array(["id", "name"])
            end
          end

          context "when the attendee is created by another application" do
            before do
              get "#{api_meetings_path}/attendees/#{@other_app_attendee_id}", headers: @auth_headers
            end

            it "does not resolve the user from external user id" do
              expect(response).to have_http_status(200)
              expect(JSON.parse(response.body)["Attendee"]["ApplicationMetadata"]["User"]).to be_nil
            end
          end

          context "when the attendee is not found" do
            before do
              get "#{api_meetings_path}/attendees/#{@dummy_attendee_id}", headers: @auth_headers
            end

            it "returns response with 404 status" do
              expect(response).to have_http_status(404)
            end
          end

          context "when the attendee is not in the meeting" do
            before do
              get "#{api_path}/meetings/#{@dummy_meeting_id}/attendees/#{@dummy_attendee_id}", headers: @auth_headers
            end

            it "returns response with 403 status" do
              expect(response).to have_http_status(403)
            end
          end
        end

        describe "POST /meetings/:meeting_id/attendees" do
          before do
            post "#{api_meetings_path}/attendees", headers: @auth_headers
          end

          it "returns response with 201 status" do
            expect(response).to have_http_status(201)
          end

          it "returns created attendee" do
            expect(JSON.parse(response.body)["Attendee"]["AttendeeId"]).to eq(@attendee_id)
          end
        end

        context "when the meeting belongs to another private room" do
          let(:other_meeting_path) { "#{api_path}/meetings/#{@other_meeting_id}" }

          it "returns response with 404 status to GET /meetings/:meeting_id/attendees" do
            expect(ChimeSdk::MeetingCoordinator).not_to receive(:list_attendees)
            get "#{other_meeting_path}/attendees", headers: @auth_headers
            expect(response).to have_http_status(404)
          end

          it "returns response with 404 status to GET /meetings/:meeting_id/attendees/:attendee_id" do
            expect(ChimeSdk::MeetingCoordinator).not_to receive(:get_attendee)
            get "#{other_meeting_path}/attendees/#{@attendee_id}", headers: @auth_headers
            expect(response).to have_http_status(404)
          end

          it "returns response with 404 status to POST /meetings/:meeting_id/attendees" do
            expect(ChimeSdk::MeetingCoordinator).not_to receive(:create_attendee)
            post "#{other_meeting_path}/attendees", headers: @auth_headers
            expect(response).to have_http_status(404)
          end

          it "returns response with 404 status to DELETE /meetings/:meeting_id/attendees/:attendee_id" do
            expect(ChimeSdk::MeetingCoordinator).not_to receive(:delete_attendee)
            delete "#{other_meeting_path}/attendees/#{@attendee_id}", headers: @auth_headers
            expect(response).to have_http_status(404)
          end
        end

        describe "DELETE /meetings/:meeting_id/attendees/:attendee_id" do
          context "when the attendee is found" do
            before do
              delete "#{api_meetings_path}/attendees/#{@attendee_id}", headers: @auth_headers
            end

            it "returns response with 204 status" do
              expect(response).to have_http_status(204)
            end
          end

          context "when the attendee is not found" do
            before do
              get "#{api_meetings_path}/attendees/#{@dummy_attendee_id}", headers: @auth_headers
            end

            it "returns response with 404 status" do
              expect(response).to have_http_status(404)
            end
          end
        end
      end
    end
  end
end