import { createStore } from 'vuex'

export default createStore({
  state: {
    user: null,
    levels: [],
    progress: {}
  },
  getters: {
    isLoggedIn: state => !!state.user,
    userId: state => state.user?.id,
    username: state => state.user?.username
  },
  mutations: {
    SET_USER(state, user) {
      state.user = user
      if (user) {
        localStorage.setItem('user', JSON.stringify(user))
      } else {
        localStorage.removeItem('user')
      }
    },
    SET_LEVELS(state, levels) {
      state.levels = levels
    },
    SET_PROGRESS(state, progress) {
      state.progress = {}
      progress.forEach(p => {
        state.progress[p['level-id']] = p
      })
    }
  },
  actions: {
    login({ commit }, user) {
      commit('SET_USER', user)
    },
    logout({ commit }) {
      commit('SET_USER', null)
      commit('SET_PROGRESS', [])
    },
    loadUser({ commit }) {
      const userStr = localStorage.getItem('user')
      if (userStr) {
        commit('SET_USER', JSON.parse(userStr))
      }
    },
    setLevels({ commit }, levels) {
      commit('SET_LEVELS', levels)
    },
    setProgress({ commit }, progress) {
      commit('SET_PROGRESS', progress)
    }
  }
})
