<template>
  <div class="level-select">
    <h1>Select a Level</h1>

    <div v-if="loading" class="loading">Loading levels...</div>

    <div v-else>
      <div v-for="chapter in chapters" :key="chapter" class="chapter-section">
        <h2>Chapter {{ chapter }}: {{ getChapterTitle(chapter) }}</h2>
        
        <div class="levels-grid">
          <div 
            v-for="level in getLevelsByChapter(chapter)" 
            :key="level.id"
            class="level-card"
            :class="{ 
              completed: isCompleted(level.id),
              'in-progress': hasAttempts(level.id) && !isCompleted(level.id)
            }"
            @click="selectLevel(level)"
          >
            <div class="level-header">
              <h3>Level {{ level.levelNumber }}</h3>
              <span class="difficulty" :class="level.difficulty">
                {{ level.difficulty }}
              </span>
            </div>
            
            <h4>{{ level.title }}</h4>
            <p>{{ level.description }}</p>
            
            <div class="level-type">
              {{ level.levelType === 'decision_table' ? '📊 Decision Table' : '🔬 Pairwise Testing' }}
            </div>

            <div v-if="getProgress(level.id)" class="progress-info">
              <div class="score">
                Best Score: {{ getProgress(level.id)['best-score'] || 0 }}
              </div>
              <div class="attempts">
                Attempts: {{ getProgress(level.id).attempts || 0 }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../services/api'

export default {
  name: 'LevelSelect',
  data() {
    return {
      loading: true
    }
  },
  computed: {
    levels() {
      return this.$store.state.levels
    },
    chapters() {
      const chapterSet = new Set(this.levels.map(l => l.chapter))
      return Array.from(chapterSet).sort()
    }
  },
  async mounted() {
    await this.loadLevels()
    await this.loadProgress()
  },
  methods: {
    async loadLevels() {
      try {
        const response = await api.getLevels()
        if (response.success) {
          this.$store.dispatch('setLevels', response.data)
        }
      } catch (error) {
        console.error('Error loading levels:', error)
      } finally {
        this.loading = false
      }
    },
    async loadProgress() {
      try {
        const response = await api.getProgress(this.$store.getters.userId)
        if (response.success) {
          this.$store.dispatch('setProgress', response.data)
        }
      } catch (error) {
        console.error('Error loading progress:', error)
      }
    },
    getLevelsByChapter(chapter) {
      return this.levels
        .filter(l => l.chapter === chapter)
        .sort((a, b) => a.levelNumber - b.levelNumber)
    },
    getChapterTitle(chapter) {
      return chapter === 1 ? 'Decision Tables' : 'Pairwise Testing'
    },
    getProgress(levelId) {
      return this.$store.state.progress[levelId]
    },
    isCompleted(levelId) {
      const progress = this.getProgress(levelId)
      return progress && progress.completed
    },
    hasAttempts(levelId) {
      const progress = this.getProgress(levelId)
      return progress && progress.attempts > 0
    },
    selectLevel(level) {
      this.$router.push(`/level/${level.id}`)
    }
  }
}
</script>

<style scoped>
.level-select {
  padding: 20px;
}

.level-select h1 {
  color: #2c3e50;
  margin-bottom: 40px;
  text-align: center;
}

.loading {
  text-align: center;
  padding: 50px;
  color: #7f8c8d;
}

.chapter-section {
  margin-bottom: 50px;
}

.chapter-section h2 {
  color: #2c3e50;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #4CAF50;
}

.levels-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.level-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.level-card:hover {
  box-shadow: 0 4px 10px rgba(0,0,0,0.15);
  transform: translateY(-2px);
}

.level-card.completed {
  border-color: #4CAF50;
}

.level-card.in-progress {
  border-color: #ff9800;
}

.level-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.level-card h3 {
  color: #2c3e50;
  font-size: 18px;
}

.level-card h4 {
  color: #34495e;
  margin-bottom: 10px;
}

.level-card p {
  color: #7f8c8d;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 15px;
}

.difficulty {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.difficulty.easy {
  background-color: #d4edda;
  color: #155724;
}

.difficulty.medium {
  background-color: #fff3cd;
  color: #856404;
}

.difficulty.hard {
  background-color: #f8d7da;
  color: #721c24;
}

.level-type {
  font-size: 14px;
  color: #555;
  margin-bottom: 10px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  padding-top: 10px;
  border-top: 1px solid #eee;
  font-size: 13px;
  color: #666;
}

.score {
  font-weight: bold;
  color: #4CAF50;
}
</style>
