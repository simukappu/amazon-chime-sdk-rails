<template>
  <div>
    <p id="notice">{{ notice }}</p>

    <h1>Meetings by Amazon Chime SDK</h1>

    <table>
      <thead>
        <tr>
          <th>Meeting ID</th>
          <th>External Meeting ID</th>
          <th>Media Region</th>
          <th colspan="1"></th>
        </tr>
      </thead>

      <tbody>
        <tr v-for="meeting in meetings" :key="`${meeting.Meeting.MeetingId}`">
          <td><router-link v-bind:to="{ name: 'Meeting', params: { room_id: room_id, meeting_id: meeting.Meeting.MeetingId } }">{{ meeting.Meeting.MeetingId }}</router-link></td>
          <td>{{ meeting.Meeting.ExternalMeetingId }}</td>
          <td>{{ meeting.Meeting.MediaRegion }}</td>
          <td><a href="#" v-on:click="delete_meeting(meeting.Meeting.MeetingId, 'Are you sure?')" data-remote="true">Destroy</a></td>
        </tr>
      </tbody>
    </table>

    <p><a href="#" v-on:click="create_meeting(room_id)" data-remote="true">Create Meeting</a></p>
    <p><router-link v-bind:to="{ name: 'Room', params: { room_id: room_id } }">Back to Room</router-link></p>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Meetings',
  props: {
    room_id: {
      required: true
    },
    message: String
  },
  data () {
    return {
      meetings: [],
      notice: this.message
    }
  },
  mounted () {
    axios
      .get(`/rooms/${this.room_id}/meetings`)
      .then(response => {
        this.meetings = response.data.meetings;
      })
      .catch(error => {
        if (error.response.status == 403) {
          this.$router.push({ name: 'Room', params: { room_id: this.room_id, message: error.response.data.notice } });
        }
        this.notice = error;
      })
  },
  methods: {
    create_meeting (room_id) {
      axios
        .post(`/rooms/${this.room_id}/meetings`)
        .then(response => {
          if (response.status == 201) {
            let meeting_id = response.data.Meeting.MeetingId;
            this.$router.push({ name: 'Meeting', params: { room_id: this.room_id, meeting_id: meeting_id, message: `Meeting <${meeting_id}> was successfully created.` } });
          }
        })
        .catch (error => {
          if (error.response.status == 403) {
            this.notice = error.response.data.notice;
          } else {
            this.notice = error;
          }
        })
    },
    delete_meeting(meeting_id, confirmation) {
      if (confirm(confirmation)) {
        axios
          .delete(`/rooms/${this.room_id}/meetings/${meeting_id}`)
          .then(response => {
            if (response.status == 204) {
              this.notice = `Meeting <${meeting_id}> was successfully destroyed.`;
            }
          })
          .catch (error => {
            console.log(error.response);
            this.notice = error;
          })
      }
    }
  }
}
</script>

<style scoped>
</style>