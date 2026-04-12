<template>
  <div class="level-page">
    <div v-if="loading" class="loading">Loading level...</div>
    
    <div v-else-if="level">
      <div class="level-header">
        <div>
          <h1>{{ level.title }}</h1>
          <p class="description">{{ level.description }}</p>
        </div>
        <button @click="goBack" class="btn-secondary">Back to Levels</button>
      </div>

      <!-- Decision Table Builder -->
      <div v-if="level.levelType === 'decision_table'" class="decision-table-section">
        <DecisionTableBuilder 
          :level="level"
          @submit="handleSubmit"
        />
      </div>

      <!-- Pairwise Builder -->
      <div v-else class="pairwise-section">
        <PairwiseTestBuilder 
          :level="level"
          @submit="handleSubmit"
        />
      </div>

      <!-- Results -->
      <div v-if="result" class="result-panel">
        <h2>Results</h2>
        <div class="score-display">
          <div class="total-score">
            <h3>Total Score</h3>
            <div class="score-value">{{ result.total }}</div>
            <div class="score-rating">{{ getScoreRating(result.total) }}</div>
          </div>
          
          <div class="score-breakdown">
            <div class="score-item">
              <span>Completeness:</span>
              <strong>{{ result.completeness }}/100</strong>
            </div>
            <div class="score-item">
              <span>Efficiency:</span>
              <strong>{{ result.efficiency }}/50</strong>
            </div>
            <div class="score-item">
              <span>Accuracy:</span>
              <strong>{{ result.accuracy }}/20</strong>
            </div>
          </div>
        </div>

        <div class="actions">
          <button @click="resetLevel" class="btn-secondary">Try Again</button>
          <button @click="goBack" class="btn-primary">Back to Levels</button>
        </div>
      </div>

      <!-- Leaderboard -->
      <div class="leaderboard-section">
        <Leaderboard :level-id="level.id" />
      </div>
    </div>
  </div>
</template>

<script>
import api from '../services/api'
import DecisionTableBuilder from '../components/DecisionTableBuilder.vue'
import PairwiseTestBuilder from '../components/PairwiseTestBuilder.vue'
import Leaderboard from '../components/Leaderboard.vue'

export default {
  name: 'DecisionTableLevel',
  components: {
    DecisionTableBuilder,
    PairwiseTestBuilder,
    Leaderboard
  },
  data() {
    return {
      level: null,
      loading: true,
      result: null
    }
  },
  async mounted() {
    await this.loadLevel()
  },
  methods: {
    async loadLevel() {
      try {
        const response = await api.getLevel(this.$route.params.id)
        if (response.success) {
          this.level = response.data
        }
      } catch (error) {
        console.error('Error loading level:', error)
      } finally {
        this.loading = false
      }
    },
    async handleSubmit(solution) {
      try {
        const response = await api.submitSolution(
          this.$store.getters.userId,
          this.level.id,
          solution
        )
        
        if (response.success) {
          this.result = response.data
          
          // Reload progress
          const progressResponse = await api.getProgress(this.$store.getters.userId)
          if (progressResponse.success) {
            this.$store.dispatch('setProgress', progressResponse.data)
          }
        }
      } catch (error) {
        console.error('Error submitting solution:', error)
      }
    },
    getScoreRating(score) {
      if (score >= 170) return '⭐⭐⭐ Gold!'
      if (score >= 140) return '⭐⭐ Silver'
      if (score >= 100) return '⭐ Bronze'
      return 'Keep trying!'
    },
    resetLevel() {
      this.result = null
      window.location.reload()
    },
    goBack() {
      this.$router.push('/levels')
    }
  }
}
</script>

<style scoped>
.level-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.loading {
  text-align: center;
  padding: 50px;
  color: #7f8c8d;
}

.level-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #eee;
}

.level-header h1 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.description {
  color: #7f8c8d;
  font-size: 16px;
  line-height: 1.6;
}

.result-panel {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin: 30px 0;
}

.result-panel h2 {
  color: #2c3e50;
  margin-bottom: 20px;
}

.score-display {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 30px;
  margin-bottom: 30px;
}

.total-score {
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.total-score h3 {
  color: #2c3e50;
  margin-bottom: 15px;
}

.score-value {
  font-size: 48px;
  font-weight: bold;
  color: #4CAF50;
  margin-bottom: 10px;
}

.score-rating {
  font-size: 20px;
  color: #ff9800;
}

.score-breakdown {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 15px;
}

.score-item {
  display: flex;
  justify-content: space-between;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 4px;
}

.score-item span {
  color: #555;
}

.score-item strong {
  color: #2c3e50;
  font-size: 18px;
}

.actions {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.leaderboard-section {
  margin-top: 30px;
}
</style>
