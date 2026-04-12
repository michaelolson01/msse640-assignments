<template>
  <div class="leaderboard">
    <h3>🏆 Leaderboard</h3>
    
    <div v-if="loading" class="loading">Loading leaderboard...</div>
    
    <div v-else-if="error" class="error">
      {{ error }}
    </div>
    
    <div v-else-if="!scores || scores.length === 0" class="no-scores">
      No scores yet. Be the first to complete this level!
    </div>
    
    <div v-else class="leaderboard-list">
      <div 
        v-for="(score, index) in scores" 
        :key="index" 
        class="leaderboard-item"
        :class="{ 'current-user': isCurrentUser(score.username) }"
      >
        <div class="rank">
          <span v-if="index === 0" class="medal gold">🥇</span>
          <span v-else-if="index === 1" class="medal silver">🥈</span>
          <span v-else-if="index === 2" class="medal bronze">🥉</span>
          <span v-else class="rank-number">{{ index + 1 }}</span>
        </div>
        <div class="username">{{ score.username }}</div>
        <div class="score">{{ score.score }} pts</div>
        <div class="date">{{ formatDate(score['submitted-at']) }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../services/api'

export default {
  name: 'Leaderboard',
  props: {
    levelId: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      scores: [],
      loading: true,
      error: null
    }
  },
  async mounted() {
    await this.loadLeaderboard()
  },
  methods: {
    async loadLeaderboard() {
      try {
        const response = await api.getLeaderboard(this.levelId)
        if (response.success) {
          this.scores = response.data || []
        } else {
          this.error = response.message || 'Failed to load leaderboard'
          this.scores = []
        }
      } catch (error) {
        console.error('Error loading leaderboard:', error)
        this.error = 'Error loading leaderboard'
        this.scores = []
      } finally {
        this.loading = false
      }
    },
    isCurrentUser(username) {
      return username === this.$store.getters.username
    },
    formatDate(dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      return date.toLocaleDateString()
    }
  }
}
</script>

<style scoped>
.leaderboard {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.leaderboard h3 {
  color: #2c3e50;
  margin-bottom: 20px;
}

.loading, .no-scores, .error {
  text-align: center;
  padding: 30px;
  color: #7f8c8d;
}

.error {
  color: #d32f2f;
  background: #ffebee;
  border-radius: 4px;
}

.leaderboard-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.leaderboard-item {
  display: grid;
  grid-template-columns: 60px 1fr auto auto;
  gap: 20px;
  align-items: center;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.leaderboard-item:hover {
  background: #e9ecef;
}

.leaderboard-item.current-user {
  background: #e8f5e9;
  border: 2px solid #4CAF50;
}

.rank {
  text-align: center;
  font-size: 20px;
}

.medal {
  font-size: 28px;
}

.rank-number {
  font-weight: bold;
  color: #555;
}

.username {
  font-weight: 500;
  color: #2c3e50;
}

.score {
  font-weight: bold;
  color: #4CAF50;
  font-size: 18px;
}

.date {
  color: #7f8c8d;
  font-size: 13px;
}
</style>
