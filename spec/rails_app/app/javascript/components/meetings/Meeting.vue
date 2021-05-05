<template>
  <div>
    <p id="notice">{{ notice }}</p>

    <h1>Meeting by Amazon Chime SDK</h1>

    <p><router-link v-bind:to="{ name: 'Meetings', params: { room_id: room_id } }">Show Meetings</router-link></p>

    <div v-if="meeting">
      <strong>Meeting</strong>
      <p>
        Meeting ID : <router-link v-bind:to="{ name: 'Meeting', params: { room_id: room_id, meeting_id: meeting.Meeting.MeetingId } }">{{ meeting.Meeting.MeetingId }}</router-link><br>
        External Meeting ID : {{ meeting.Meeting.ExternalMeetingId }}<br>
        Media Region : {{ meeting.Meeting.MediaRegion }}
      </p>
    </div>

    <div v-if="attendee">
      <strong>Attendee</strong>
      <p>
        Attendee ID : <a v-bind:href="`/rooms/${room_id}/meetings/${meeting.Meeting.MeetingId}/attendees/${attendee.Attendee.AttendeeId}`">{{ attendee.Attendee.AttendeeId }}</a><br>
        External User ID : {{ attendee.Attendee.ExternalUserId }}<br>
        Application Attendee Name : {{ attendee.Attendee.ApplicationMetadata.User.name }}
      </p>

      <div id="status">
        <strong>Status</strong>
        <div v-if="meetingOnline">
          <div id="meeting-status">
            <p>Meeting : Online <input type="button" value="Leave a meeting" v-on:click="leave()"></p>
            <div id="audio-status">
              <div v-if="meetingMuted">
                <p>Audio : Muted <input type="button" value="Unmute" v-on:click="unmute()"></p>
              </div>
              <div v-else>
                <p>Audio : Active <input type="button" value="Mute" v-on:click="mute()"></p>
              </div>
            </div>
          </div>
          <div id="attendee-status">
            <strong>Present Attendees</strong>
            <ul>
              <li v-for="attendeeName in presentAttendees" :key="attendeeName">{{ attendeeName }}</li>
            </ul>
          </div>
        </div>
        <div v-else>
          <div id="meeting-status">
            <p>Meeting : Offline <input type="button" value="Join a meeting" v-on:click="join()"></p>
          </div>
        </div>
      </div>

      <audio id="audio"></audio>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import {
  ConsoleLogger,
  DefaultDeviceController,
  DefaultMeetingSession,
  LogLevel,
  MeetingSessionConfiguration
} from 'amazon-chime-sdk-js'

export default {
  name: 'Meeting',
  props: {
    room_id: {
      required: true
    },
    meeting_id: {
      required: true
    },
    message: String
  },
  data () {
    return {
      meeting: null,
      attendee: null,
      notice: this.message,
      meetingOnline: false,
      meetingMuted: false,
      presentAttendees: []
    }
  },
  mounted () {
    axios
      .get(`/rooms/${this.room_id}/meetings/${this.meeting_id}`)
      .then(response => {
        this.meeting = { Meeting: response.data.Meeting };
        this.attendee = { Attendee: response.data.Attendee };

        const logger = new ConsoleLogger('ChimeMeetingLogs', LogLevel.INFO);
        const deviceController = new DefaultDeviceController(logger);
        const configuration = new MeetingSessionConfiguration(this.meeting, this.attendee);
        this.meetingSession = new DefaultMeetingSession(configuration, logger, deviceController);
      })
      .catch(error => {
          if (error.response.status == 404) {
            this.$router.push({ name: 'Meetings', params: { room_id: this.room_id, message: `${error.response.data.error.message}: ${error.response.data.error.type}` } });
          } else {
            this.notice = error;
          }
      })
  },
  methods: {
    // Customize this function to extract attendee name to show
    showApplicationUserName(attendee) {
      // return attendee.Attendee.AttendeeId;
      return `${attendee.Attendee.ApplicationMetadata.User.name} (${attendee.Attendee.AttendeeId})`;
    },
    async join() {
      try {
        const audioInputDevices = await this.meetingSession.audioVideo.listAudioInputDevices();
        const audioOutputDevices = await this.meetingSession.audioVideo.listAudioOutputDevices();
        await this.meetingSession.audioVideo.chooseAudioInputDevice(audioInputDevices[0].deviceId);
        await this.meetingSession.audioVideo.chooseAudioOutputDevice(audioOutputDevices[0].deviceId);
      } catch (error) {
        // handle error - unable to acquire audio device perhaps due to permissions blocking
        if (error instanceof PermissionDeniedError) {
          console.error('Permission denied', error);
        } else {
          console.error(error);
        }
      }
      const audioOutputElement = document.getElementById('audio');
      try {
        await this.meetingSession.audioVideo.bindAudioElement(audioOutputElement);
      } catch (error) {
        console.error('Failed to bind audio element', error);
      }
      this.meetingSession.audioVideo.start();
      this.meetingOnline = true;
      this.parepareAttendeeStatus();
    },
    leave() {
      this.meetingSession.audioVideo.stop();
      this.meetingOnline = false;
      this.meetingMuted = false;
      this.presentAttendees = [];
    },
    mute() {
      this.meetingSession.audioVideo.realtimeMuteLocalAudio();
      this.meetingMuted = true;
    },
    unmute() {
      const unmuted = this.meetingSession.audioVideo.realtimeUnmuteLocalAudio();
      if (unmuted) {
        this.meetingMuted = false;
      } else {
        console.log('You cannot unmute yourself');
      }
    },
    parepareAttendeeStatus() {
      this.presentAttendeeMap = {};
      const callback = (presentAttendeeId, present) => {
        if (present) {
          axios
            .get(`/rooms/${this.room_id}/meetings/${this.meeting_id}/attendees/${presentAttendeeId}`)
            .then(response => {
              this.presentAttendeeMap[presentAttendeeId] = response.data;
              this.updateAttendeeStatus(this.presentAttendeeMap);
            })
            .catch(error => {
              console.log(error);
            });
        } else {
          delete this.presentAttendeeMap[presentAttendeeId]
          this.updateAttendeeStatus(this.presentAttendeeMap);
        }
      };
      this.meetingSession.audioVideo.realtimeSubscribeToAttendeeIdPresence(callback);
    },
    updateAttendeeStatus(presentAttendeeMap) {
      this.presentAttendees = Object.values(presentAttendeeMap).map(attendee => this.showApplicationUserName(attendee));
    }
  }
}
</script>

<style scoped>
</style>