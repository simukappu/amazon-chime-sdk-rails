# Integration tests with AWS Emulator (https://aws.amazon.com/products/developer-tools/emulator/).
# These tests call Amazon Chime SDK Meetings APIs of the emulator through the controllers instead of the stubbed client.
# Run them with AWS_EMULATOR=true and the environment variables pointing the AWS SDK at the emulator (see .github/workflows/build.yml).
describe "Amazon Chime SDK Meetings with AWS Emulator", type: :request, if: ENV['AWS_EMULATOR'] == 'true' do
  let(:api_root_path) { "/api/v1" }

  before(:all) do
    # Use a real client, which sends requests to AWS_ENDPOINT_URL
    ChimeSdk::MeetingCoordinator.reset_client(Aws::ChimeSDKMeetings::Client.new(region: 'us-east-1'))
    @room = create(:room)
    @other_room = create(:room)
    @user = create(:user)
    @room.add_member(@user)
    @other_room.add_member(@user)
  end

  after(:all) do
    ChimeSdk::MeetingCoordinator.reset_client(nil)
  end

  before do
    post "#{api_root_path}/auth/sign_in", params: { email: @user.email, password: "password" }
    @auth_headers = response.header.slice("access-token", "client", "uid")
  end

  def create_meeting_in(room)
    post "#{api_root_path}/rooms/#{room.id}/meetings", headers: @auth_headers
    expect(response).to have_http_status(201)
    JSON.parse(response.body)
  end

  def meeting_path_of(room, meeting_id)
    "#{api_root_path}/rooms/#{room.id}/meetings/#{meeting_id}"
  end

  it "creates a meeting with an attendee of the requesting user" do
    meeting = create_meeting_in(@room)
    expect(meeting["Meeting"]["ExternalMeetingId"]).to eq("#{ChimeSdk.config.prefix}PrivateRoom-#{@room.id}")
    expect(meeting["Attendee"]["ExternalUserId"]).to eq("#{ChimeSdk.config.prefix}User-#{@user.id}")
    expect(meeting["Attendee"]["JoinToken"]).to be_present
  end

  it "gets the meeting created in the room" do
    meeting_id = create_meeting_in(@room)["Meeting"]["MeetingId"]
    get meeting_path_of(@room, meeting_id), params: { create_attendee_from_meeting: false }, headers: @auth_headers
    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)["Meeting"]["MeetingId"]).to eq(meeting_id)
  end

  it "does not return a meeting of another room" do
    other_meeting_id = create_meeting_in(@other_room)["Meeting"]["MeetingId"]
    get meeting_path_of(@room, other_meeting_id), headers: @auth_headers
    expect(response).to have_http_status(404)
    get "#{meeting_path_of(@room, other_meeting_id)}/attendees", headers: @auth_headers
    expect(response).to have_http_status(404)
  end

  it "lists and gets attendees without their join tokens" do
    meeting = create_meeting_in(@room)
    meeting_path = meeting_path_of(@room, meeting["Meeting"]["MeetingId"])

    get "#{meeting_path}/attendees", headers: @auth_headers
    expect(response).to have_http_status(200)
    attendees = JSON.parse(response.body)["attendees"]
    expect(attendees.map { |attendee| attendee["Attendee"]["AttendeeId"] }).to include(meeting["Attendee"]["AttendeeId"])
    expect(attendees).to all(satisfy { |attendee| !attendee["Attendee"].key?("JoinToken") })

    get "#{meeting_path}/attendees/#{meeting["Attendee"]["AttendeeId"]}", headers: @auth_headers
    expect(response).to have_http_status(200)
    attendee = JSON.parse(response.body)["Attendee"]
    expect(attendee).not_to have_key("JoinToken")
    expect(attendee["ApplicationMetadata"]["User"]).to eq("id" => @user.id, "name" => @user.name)
  end

  it "deletes an attendee" do
    meeting = create_meeting_in(@room)
    attendee_path = "#{meeting_path_of(@room, meeting["Meeting"]["MeetingId"])}/attendees/#{meeting["Attendee"]["AttendeeId"]}"
    delete attendee_path, headers: @auth_headers
    expect(response).to have_http_status(204)
    get attendee_path, headers: @auth_headers
    expect(response).to have_http_status(404)
  end

  it "deletes a meeting" do
    meeting_id = create_meeting_in(@room)["Meeting"]["MeetingId"]
    delete meeting_path_of(@room, meeting_id), headers: @auth_headers
    expect(response).to have_http_status(204)
    get meeting_path_of(@room, meeting_id), headers: @auth_headers
    expect(response).to have_http_status(404)
  end
end
