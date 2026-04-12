import axios from 'axios'

const API_URL = 'http://localhost:8080/api'

export default {
  async register(username, password, email) {
    const response = await axios.post(`${API_URL}/register`, null, {
      params: { username, password, email }
    })
    return response.data
  },

  async login(username, password) {
    const response = await axios.post(`${API_URL}/login`, null, {
      params: { username, password }
    })
    return response.data
  },

  async getLevels() {
    const response = await axios.get(`${API_URL}/levels`)
    return response.data
  },

  async getLevel(id) {
    const response = await axios.get(`${API_URL}/level`, {
      params: { id }
    })
    return response.data
  },

  async submitSolution(userId, levelId, solution) {
    const response = await axios.post(`${API_URL}/submit`, {
      'user-id': userId,
      'level-id': levelId,
      solution: solution
    })
    return response.data
  },

  async getProgress(userId) {
    const response = await axios.get(`${API_URL}/progress`, {
      params: { 'user-id': userId }
    })
    return response.data
  },

  async getLeaderboard(levelId) {
    const response = await axios.get(`${API_URL}/leaderboard`, {
      params: { 'level-id': levelId }
    })
    return response.data
  },

  async getScores(userId, levelId = null) {
    const params = { 'user-id': userId }
    if (levelId) params['level-id'] = levelId
    const response = await axios.get(`${API_URL}/scores`, { params })
    return response.data
  }
}
