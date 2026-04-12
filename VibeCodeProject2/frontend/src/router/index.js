import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Login from '../views/Login.vue'
import LevelSelect from '../views/LevelSelect.vue'
import DecisionTableLevel from '../views/DecisionTableLevel.vue'
import PairwiseLevel from '../views/PairwiseLevel.vue'
import store from '../store'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/levels',
    name: 'LevelSelect',
    component: LevelSelect,
    meta: { requiresAuth: true }
  },
  {
    path: '/level/:id',
    name: 'DecisionTableLevel',
    component: DecisionTableLevel,
    meta: { requiresAuth: true }
  },
  {
    path: '/pairwise/:id',
    name: 'PairwiseLevel',
    component: PairwiseLevel,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

// Navigation guard for authentication
router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!store.state.user) {
      next('/login')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
