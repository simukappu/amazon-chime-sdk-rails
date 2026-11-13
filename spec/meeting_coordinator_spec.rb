describe ChimeSdk::MeetingCoordinator do
  describe ".meeting_as_json" do
    it "returns nil for features which are not configured for the meeting" do
      meeting = Aws::ChimeSDKMeetings::Types::Meeting.new(
        meeting_id: "01234567-89ab-cdef-ghij-klmnopqrstuv",
        media_placement: Aws::ChimeSDKMeetings::Types::MediaPlacement.new(audio_host_url: "dummy"),
        meeting_features: Aws::ChimeSDKMeetings::Types::MeetingFeaturesConfiguration.new(
          audio: Aws::ChimeSDKMeetings::Types::AudioFeatures.new(echo_reduction: "AVAILABLE")
        )
      )
      features = described_class.meeting_as_json(meeting)[:Meeting]["MeetingFeatures"]
      expect(features[:Audio][:EchoReduction]).to eq("AVAILABLE")
      expect(features[:Video][:MaxResolution]).to be_nil
      expect(features[:Content][:MaxResolution]).to be_nil
      expect(features[:Attendee][:MaxCount]).to be_nil
    end
  end
end
