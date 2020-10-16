describe ChimeSdk::Controller::Meetings, type: :request do
  before(:all) do
    @meeting_id       = "01234567-89ab-cdef-ghij-klmnopqrstuv"
    @attendee_id      = "76543210-ba98-fedc-jihg-vutsrqponmlk"
    @dummy_meeting_id = "91234567-89ab-cdef-ghij-klmnopqrstuv"

    @room = create(:room)
    dummy_media_placement = {
      audio_host_url: "dummy",
      audio_fallback_url: "dummy",
      screen_data_url: "dummy",
      screen_sharing_url: "dummy",
      screen_viewing_url: "dummy",
      signaling_url: "dummy",
      turn_control_url: "dummy"
    }
    test_meeting = {
      meeting_id: @meeting_id,
      external_meeting_id: "ChimeSdkRailsApp-test-PrivateRoom-#{@room.id}",
      media_placement: dummy_media_placement,
      media_region: "us-east-1"
    }
    dummy_meeting = {
      meeting_id: @dummy_meeting_id,
      external_meeting_id: "ChimeSdkRailsApp-test-PrivateRoom-0",
      media_placement: dummy_media_placement,
      media_region: "us-east-1"
    }

    # Use stubs for the AWS SDK for Ruby
    client = Aws::Chime::Client.new(stub_responses: true)
    client.stub_responses(:list_meetings, {
      meetings: [ test_meeting, dummy_meeting ]
    })
    client.stub_responses(:get_meeting, -> (context) {
      context.params[:meeting_id] == @meeting_id ? { meeting: test_meeting } : 'NotFoundException'
    })
    client.stub_responses(:create_meeting, {
      meeting: test_meeting
    })
    client.stub_responses(:delete_meeting, -> (context) {
      context.params[:meeting_id] == @meeting_id ? {} : 'NotFoundException'
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
    ChimeSdk::MeetingCoordinator.reset_client(client)
  end

  context "Rails API" do
    let(:api_root_path) { "/api/v1" }
    let(:api_path) { "#{api_root_path}/rooms/#{@room.id}" }

    before do
      @user = create(:user)
    end

    context "requests from unauthorized user" do
      describe "GET /meetings" do
        it "returns response with 401 status" do
          get "#{api_path}/meetings", headers: @auth_headers
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
        describe "GET /meetings" do
          it "returns response with 403 status" do
            get "#{api_path}/meetings", headers: @auth_headers
            expect(response).to have_http_status(403)
          end
        end
      end

      context "when the authorized user is a member of the private room" do
        before do
          @room.add_member(@user)
        end

        describe "GET /meetings" do
          context "without any parameters and ChimeSdk.config.create_meeting_by_get_request is disabled" do
            before do
              get "#{api_path}/meetings", headers: @auth_headers
            end

            it "returns response with 200 status" do
              expect(response).to have_http_status(200)
            end

            it "returns meetings list filtered by prefix" do
              expect(JSON.parse(response.body)["meetings"].length).to eq(1)
            end

            it "returns valid meeting in the list" do
              expect(JSON.parse(response.body)["meetings"][0]["Meeting"]["MeetingId"]).to eq(@meeting_id)
            end
          end

          context "with true as create_meeting parameter" do
            before do
              get "#{api_path}/meetings", headers: @auth_headers, params: { create_meeting: true }
            end

            it "returns response with 201 status" do
              expect(response).to have_http_status(201)
            end

            it "returns created meeting" do
              expect(JSON.parse(response.body)["Meeting"]["MeetingId"]).to eq(@meeting_id)
            end
          end
        end

        describe "GET /meetings/:meeting_id" do
          context "when the meeting is found" do
            before do
              get "#{api_path}/meetings/#{@meeting_id}", headers: @auth_headers
            end

            it "returns response with 200 status" do
              expect(response).to have_http_status(200)
            end

            it "returns valid meeting" do
              expect(JSON.parse(response.body)["Meeting"]["MeetingId"]).to eq(@meeting_id)
            end

            it "returns application metadata in the meeting" do
              expect(JSON.parse(response.body)["Meeting"]["ApplicationMetadata"]["Room"]["id"]).to eq(@room.id)
            end

            it "returns created attendee since ChimeSdk.config.create_attendee_from_meeting is enabled" do
              expect(JSON.parse(response.body)["Attendee"]["AttendeeId"]).to eq(@attendee_id)
            end
          end

          context "when the meeting is not found" do
            before do
              get "#{api_path}/meetings/#{@dummy_meeting_id}", headers: @auth_headers
            end

            it "returns response with 404 status" do
              expect(response).to have_http_status(404)
            end
          end
        end

        describe "POST /meetings" do
          context "when ChimeSdk.config.create_meeting_with_attendee is enabled" do
            before do
              post "#{api_path}/meetings", headers: @auth_headers
            end

            it "returns response with 201 status" do
              expect(response).to have_http_status(201)
            end

            it "returns created meeting" do
              expect(JSON.parse(response.body)["Meeting"]["MeetingId"]).to eq(@meeting_id)
            end

            it "returns created attendee" do
              expect(JSON.parse(response.body)["Attendee"]["AttendeeId"]).to eq(@attendee_id)
            end
          end

          context "when ChimeSdk.config.create_meeting_with_attendee is disabled" do
            before do
              ChimeSdk.config.create_meeting_with_attendee = false
              post "#{api_path}/meetings", headers: @auth_headers
            end

            after do
              ChimeSdk.config.create_meeting_with_attendee = true
            end

            it "returns response with 201 status" do
              expect(response).to have_http_status(201)
            end

            it "returns created meeting" do
              expect(JSON.parse(response.body)["Meeting"]["MeetingId"]).to eq(@meeting_id)
            end

            it "does not return created attendee" do
              expect(JSON.parse(response.body)["Attendee"]).to be_nil
            end
          end
        end

        describe "DELETE /meetings/:meeting_id" do
          context "when the meeting is found" do
            before do
              delete "#{api_path}/meetings/#{@meeting_id}", headers: @auth_headers
            end

            it "returns response with 204 status" do
              expect(response).to have_http_status(204)
            end
          end

          context "when the meeting is not found" do
            before do
              get "#{api_path}/meetings/#{@dummy_meeting_id}", headers: @auth_headers
            end

            it "returns response with 404 status" do
              expect(response).to have_http_status(404)
            end
          end
        end
      end
    end
  end

  context "Rails View" do
    let(:api_path) { "/rooms/#{@room.id}" }

    before do
      @user = create(:user)
    end

    context "requests from unauthorized user" do
      describe "GET /meetings" do
        before do
          get "#{api_path}/meetings"
        end

        it "returns response with 302 status" do
          expect(response).to have_http_status(302)
        end

        it "redirects to user sign_in path" do
          expect(response.body).to redirect_to("/users/sign_in")
        end
      end
    end

    context "requests from authorized user" do
      before do
        # Sign in with Devise
        sign_in @user
      end

      context "when the authorized user is not a member of the private room" do
        describe "GET /meetings" do
          before do
            get "#{api_path}/meetings"
          end

          it "returns response with 302 status" do
            expect(response).to have_http_status(302)
          end

          it "redirects to parent resource path" do
            expect(response.body).to redirect_to(api_path)
          end
        end
      end

      context "when the authorized user is a member of the private room" do
        before do
          @room.add_member(@user)
        end

        describe "GET /meetings" do
          context "without any parameters and ChimeSdk.config.create_meeting_by_get_request is disabled" do
            before do
              get "#{api_path}/meetings"
            end

            it "returns response with 200 status" do
              expect(response).to have_http_status(200)
              expect(response.body).to include("Meetings by Amazon Chime SDK")
            end

            it "returns valid meeting in the list" do
              expect(response.body).to include(@meeting_id)
            end
          end

          context "with true as create_meeting parameter" do
            before do
              get "#{api_path}/meetings", params: { create_meeting: true }
            end

            it "returns response with 302 status" do
              expect(response).to have_http_status(302)
            end

            it "redirects to created meeting path" do
              expect(response.body).to redirect_to("#{api_path}/meetings/#{@meeting_id}")
            end
          end
        end

        describe "GET /meetings/:meeting_id" do
          context "when the meeting is found" do
            before do
              get "#{api_path}/meetings/#{@meeting_id}"
            end

            it "returns response with 200 status" do
              expect(response).to have_http_status(200)
              expect(response.body).to include("Meeting by Amazon Chime SDK")
            end

            it "returns valid meeting" do
              expect(response.body).to include(@meeting_id)
            end

            it "returns created attendee since ChimeSdk.config.create_attendee_from_meeting is enabled" do
              expect(response.body).to include(@attendee_id)
            end
          end

          context "when the meeting is not found" do
            before do
              get "#{api_path}/meetings/#{@dummy_meeting_id}"
            end

            it "returns response with 302 status" do
              expect(response).to have_http_status(302)
            end

            it "redirects to meetings path" do
              expect(response.body).to redirect_to("#{api_path}/meetings")
            end

            it "returns resource_not_found error as notice" do
              expect(flash[:notice]).to include("Resource not found")
            end
          end
        end

        describe "POST /meetings" do
          context "when ChimeSdk.config.create_meeting_with_attendee is enabled" do
            before do
              post "#{api_path}/meetings"
            end

            it "returns response with 302 status" do
              expect(response).to have_http_status(302)
            end

            it "redirects to created meeting path" do
              expect(response.body).to redirect_to("#{api_path}/meetings/#{@meeting_id}")
            end

            it "returns created message as notice" do
              expect(flash[:notice]).to include("Meeting <#{@meeting_id}> was successfully created")
            end
          end

          context "when ChimeSdk.config.create_meeting_with_attendee is disabled" do
            before do
              ChimeSdk.config.create_meeting_with_attendee = false
              post "#{api_path}/meetings"
            end

            after do
              ChimeSdk.config.create_meeting_with_attendee = true
            end

            it "returns response with 302 status" do
              expect(response).to have_http_status(302)
            end

            it "redirects to created meeting path" do
              expect(response.body).to redirect_to("#{api_path}/meetings/#{@meeting_id}")
            end

            it "returns created message as notice" do
              expect(flash[:notice]).to include("Meeting <#{@meeting_id}> was successfully created.")
            end
          end
        end

        describe "DELETE /meetings/:meeting_id" do
          context "when the meeting is found" do
            before do
              delete "#{api_path}/meetings/#{@meeting_id}"
            end

            it "returns response with 302 status" do
              expect(response).to have_http_status(302)
            end

            it "redirects to meetings path" do
              expect(response.body).to redirect_to("#{api_path}/meetings")
            end

            it "returns resource_not_found error as notice" do
              expect(flash[:notice]).to include("Meeting <#{@meeting_id}> was successfully destroyed.")
            end
          end

          context "when the meeting is not found" do
            before do
              get "#{api_path}/meetings/#{@dummy_meeting_id}"
            end

            it "returns response with 302 status" do
              expect(response).to have_http_status(302)
            end

            it "redirects to meetings path" do
              expect(response.body).to redirect_to("#{api_path}/meetings")
            end

            it "returns resource_not_found error as notice" do
              expect(flash[:notice]).to include("Resource not found")
            end
          end
        end
      end
    end
  end
end