<template>
  <div v-if="room">
    <p id="notice">{{ notice }}</p>

    <p>
      <strong>Name:</strong>
      {{ room.name }}
    </p>

    <p>
      <strong>Private Meeting:</strong>
      <p><router-link v-bind:to="{ name: 'Meetings', params: { room_id: room.id } }">Show Meetings</router-link></p>
      <p><a href="#" v-on:click="create_meeting(room)" data-remote="true">Create Meeting</a></p>
    </p>

    <p>
      <strong>Members:</strong>
      <div>
        <table>
          <tbody>
            <tr v-for="member in room.members" :key="`${member.name}`">
              <td>{{ member.name }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </p>

    <p>
      <strong>Manage members:</strong>
      <a v-bind:href="`/rooms/${room.id}`">(Show)</a>
    </p>

    <br>

    <a v-bind:href="`/rooms/${room.id}/edit`">(Edit)</a>
    <router-link v-bind:to="{ name: 'Rooms' }">Back</router-link>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Room',
  props: {
    room_id: {
      required: true
    },
    message: String
  },
  data () {
    return {
      room: null,
      notice: this.message
    }
  },
  mounted () {
    axios
      .get(`/rooms/${this.room_id}`)
      .then(response => {
        this.room = response.data;
      })
      .catch(error => {
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
    }
  }
}
</script>

<style scoped>
</style>