describe ChimeSdk::Controller::Attendees, type: :request do
  before(:all) do
    @meeting_id        = "01234567-89ab-cdef-ghij-klmnopqrstuv"
    @attendee_id       = "76543210-ba98-fedc-jihg-vutsrqponmlk"
    @dummy_meeting_id  = "91234567-89ab-cdef-ghij-klmnopqrstuv"
    @dummy_attendee_id = "96543210-ba98-fedc-jihg-vutsrqponmlk"

    @room = create(:room)
    @attendee_user = create(:user)
    @room.add_member(@attendee_user)
    test_attendee = {
      external_user_id: "ChimeSdkRailsApp-test-User-#{@attendee_user.id}",
      attendee_id: @attendee_id,
      join_token: "dummy"
    }
    dummy_attendee = {
      external_user_id: "ChimeSdkRailsApp-test-User-0",
      attendee_id: @dummy_attendee_id,
      join_token: "dummy"
    }

    # Use stubs for the AWS SDK for Ruby
    client = Aws::Chime::Client.new(stub_responses: true)
    client.stub_responses(:list_attendees, {
      attendees: [ test_attendee, dummy_attendee ]
    })
    client.stub_responses(:get_attendee, -> (context) {
      context.params[:meeting_id] == @meeting_id ?
        (context.params[:attendee_id] == @attendee_id ? { attendee: test_attendee } : 'NotFoundException') :
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

            it "returns application metadata in the attendee" do
              expect(JSON.parse(response.body)["Attendee"]["ApplicationMetadata"]["User"]["id"]).to eq(@attendee_user.id)
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