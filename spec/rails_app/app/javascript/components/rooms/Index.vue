<template>
  <div>
    <p id="notice">{{ notice }}</p>

    <h1>Rooms</h1>

    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th colspan="3"></th>
        </tr>
      </thead>

      <tbody>
        <tr v-for="room in rooms" :key="`${room.id}`">
          <td>{{ room.name }}</td>
          <td><router-link v-bind:to="{ name: 'Room', params: { room_id: room.id } }">Show</router-link></td>
          <td><a v-bind:href="`/rooms/${room.id}/edit`">(Edit)</a></td>
          <td><a v-bind:href="`/rooms/${room.id}`" data-method="delete" data-confirm="Are you sure?" rel="nofollow">(Destroy)</a></td>
        </tr>
      </tbody>
    </table>

    <br>

    <a href="/rooms/new">(New Room)</a>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Rooms',
  data () {
    return {
      rooms: [],
      notice: null
    }
  },
  mounted () {
    axios
      .get('/rooms')
      .then(response => {
        this.rooms = response.data;
      })
  }
}
</script>

<style scoped>
</style>