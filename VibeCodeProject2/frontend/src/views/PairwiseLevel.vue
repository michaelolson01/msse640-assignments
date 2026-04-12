<template>
  <div class="pairwise-level">
    <div v-if="loading" class="loading">Loading level...</div>
    
    <div v-else-if="level">
      <div class="level-header">
        <h1>{{ level.title }}</h1>
        <p>{{ level.description }}</p>
      </div>

      <div class="level-content">
      <div class="builder-section">
        <PairwiseTestBuilder 
          :level="level"
          @submit="submitSolution"
        />
      </div>

      <div class="results-section" v-if="results">
        <h2>Results</h2>
        <div class="score-display">
          <div class="score-item">
            <span class="label">Completeness:</span>
            <span class="value">{{ results.completeness }}%</span>
          </div>
          <div class="score-item">
            <span class="label">Efficiency:</span>
            <span class="value">{{ results.efficiency }}%</span>
          </div>
          <div class="score-item">
            <span class="label">Accuracy:</span>
            <span class="value">{{ results.accuracy }}%</span>
          </div>
          <div class="score-item total">
            <span class="label">Total Score:</span>
            <span class="value">{{ results.total }}%</span>
          </div>
        </div>
      </div>

      <!-- Leaderboard -->
      <div class="leaderboard-section">
        <Leaderboard :level-id="level.id" />
      </div>
    </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import PairwiseTestBuilder from '@/components/PairwiseTestBuilder.vue'
import Leaderboard from '@/components/Leaderboard.vue'
import api from '@/services/api'

export default {
  name: 'PairwiseLevel',
  components: {
    PairwiseTestBuilder,
    Leaderboard
  },
  data() {
    return {
      level: null,
      results: null,
      loading: false
    }
  },
  computed: {
    ...mapState(['user'])
  },
  methods: {
    async loadLevel() {
      try {
        this.loading = true
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
    async submitSolution(solution) {
      try {
        this.loading = true
        const response = await api.submitSolution(
          this.user.id,
          this.$route.params.id,
          solution
        )
        if (response.success) {
          this.results = response.data
        }
      } catch (error) {
        console.error('Error submitting solution:', error)
      } finally {
        this.loading = false
      }
    }
  },
  mounted() {
    this.loadLevel()
  }
}
</script>

<style scoped>
.loading {
  text-align: center;
  padding: 50px;
  color: #7f8c8d;
}

.pairwise-level {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.level-header {
  margin-bottom: 2rem;
  border-bottom: 2px solid #e0e0e0;
  padding-bottom: 1rem;
}

.level-header h1 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.level-header p {
  margin: 0;
  color: #666;
  font-size: 1rem;
}

.level-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

.builder-section {
  background: #f9f9f9;
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
}

.results-section {
  background: #f0f8ff;
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid #b0d4ff;
}

.results-section h2 {
  margin-top: 0;
  color: #333;
}

.score-display {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.score-item {
  display: flex;
  justify-content: space-between;
  padding: 0.75rem;
  background: white;
  border-radius: 4px;
  border-left: 4px solid #4CAF50;
}

.score-item.total {
  border-left-color: #2196F3;
  font-weight: bold;
  font-size: 1.1rem;
}

.score-item .label {
  color: #666;
}

.score-item .value {
  color: #333;
  font-weight: 600;
}

.leaderboard-section {
  margin-top: 30px;
}

@media (max-width: 768px) {
  .level-content {
    grid-template-columns: 1fr;
  }
}
</style>
