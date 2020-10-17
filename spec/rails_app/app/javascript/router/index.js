import Vue from 'vue'
import VueRouter from 'vue-router'
import store from '../store'
import DeviseTokenAuth from '../components/DeviseTokenAuth.vue'
import Rooms from '../components/rooms/Index.vue'
import Room from '../components/rooms/Show.vue'
import Meetings from '../components/meetings/Index.vue'
import Meeting from '../components/meetings/Meeting.vue'

Vue.use(VueRouter)

const routes = [
  // Routes for common components
  {
    path: '/',
    name: 'Root',
    component: Rooms
  },
  {
    path: '/users/sign_in',
    name: 'SignIn',
    component: DeviseTokenAuth
  },
  {
    path: '/users/sign_out',
    name: 'SignOut',
    component: DeviseTokenAuth,
    props: { isLogout: true }
  },

  // Routes for Rooms
  {
    path: '/rooms',
    name: 'Rooms',
    component: Rooms
  },
  {
    path: '/rooms/:room_id',
    name: 'Room',
    component: Room,
    props: true,
    meta: { requiresAuth: true }
  },

  // Routes for Meetings
  {
    path: '/rooms/:room_id/meetings',
    name: 'Meetings',
    component: Meetings,
    props: true,
    meta: { requiresAuth: true }
  },
  {
    path: '/rooms/:room_id/meetings/:meeting_id',
    name: 'Meeting',
    component: Meeting,
    props: true,
    meta: { requiresAuth: true }
  }
]

const router = new VueRouter({
  routes
})

router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth) && !store.getters.userSignedIn) {
      next({ name: 'SignIn', query: { redirect: to.fullPath }});
  } else {
    next();
  }
})

export default router