<template>
  <div>
    <div>
      <strong><router-link v-bind:to="{ name: 'Root' }">SPA with Rails API</router-link></strong>
      <a href="/">Rails App with Action View</a>
    </div>
    <div>
      <strong>Rails Application for Amazon Chime SDK Meeting (SPA with Rails API)</strong>
    </div>
    <div>
      <div v-if="userSignedIn">
        {{ currentUser.name }}
        <router-link v-bind:to="{ name: 'SignOut' }">Logout</router-link>
      </div>
      <div v-else>
        <router-link v-bind:to="{ name: 'SignIn' }">Login</router-link>
      </div>
    </div>
    <router-view />
  </div>
</template>

<script>
import Vue from 'vue'
import axios from 'axios'

axios.defaults.baseURL = "/api/v1"

export default {
  name: 'App',
  computed: {
    userSignedIn: function () {
      return this.$store.getters.userSignedIn;
    },
    currentUser: function () {
      return this.$store.getters.currentUser;
    }
  },
  created () {
    if (this.$store.getters.userSignedIn) {
      for (var authHeader of Object.keys(this.$store.getters.authHeaders)) {
        axios.defaults.headers.common[authHeader] = this.$store.getters.authHeaders[authHeader];
      }
    }
  }
}
</script>

<style scoped>
</style>