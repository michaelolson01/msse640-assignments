<template>
  <div class="pairwise-builder">
    <div class="instructions">
      <h3>🔬 Design Your Pairwise Test Set</h3>
      <p>Create a minimal set of test cases that covers all possible pairs of parameter values.</p>
    </div>

    <div class="parameters-info">
      <h4>Parameters:</h4>
      <div class="parameter-list">
        <div v-for="param in parameters" :key="param.id" class="parameter-item">
          <strong>{{ param.name }}:</strong>
          <span class="values">{{ (param.values || []).join(', ') }}</span>
        </div>
      </div>
    </div>

    <div class="test-cases-section">
      <div class="section-header">
        <h4>Test Cases ({{ testCases.length }})</h4>
        <button @click="addTestCase" class="btn-primary">+ Add Test Case</button>
      </div>

      <div class="test-cases-list">
        <div v-for="(test, index) in testCases" :key="'test-' + index" class="test-case-card">
          <div class="test-case-header">
            <h5>Test Case {{ index + 1 }}</h5>
            <button @click="removeTestCase(index)" class="btn-small btn-danger" v-if="testCases.length > 1">
              Remove
            </button>
          </div>

          <div class="test-case-params">
            <div v-for="param in parameters" :key="param.id" class="param-field">
              <label>{{ param.name }}:</label>
              <select v-model="test[param.id]">
                <option value="">-- Select --</option>
                <option v-for="value in (param.values || [])" :key="value" :value="value">
                  {{ value }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="coverage-info">
      <h4>Coverage Analysis</h4>
      <div class="coverage-stats">
        <div class="stat">
          <span>Test Cases:</span>
          <strong>{{ testCases.length }}</strong>
        </div>
        <div class="stat">
          <span>Estimated Coverage:</span>
          <strong>{{ estimatedCoverage }}%</strong>
        </div>
      </div>
    </div>

    <div class="controls">
      <button @click="submitTests" class="btn-primary btn-large">Submit Test Set</button>
      <button @click="reset" class="btn-secondary">Reset</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PairwiseTestBuilder',
  props: {
    level: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      parameters: [],
      testCases: []
    }
  },
  computed: {
    estimatedCoverage() {
      // Simple estimation - actual calculation would be more complex
      const totalPairs = this.calculateTotalPairs()
      if (totalPairs === 0) return 0
      
      const coveredPairs = this.estimateCoveredPairs()
      return Math.min(100, Math.round((coveredPairs / totalPairs) * 100))
    }
  },
  watch: {
    level: {
      handler() {
        this.initializeBuilder()
      },
      deep: true
    }
  },
  mounted() {
    this.initializeBuilder()
  },
  methods: {
    initializeBuilder() {
      if (!this.level) {
        console.warn('Level not loaded yet')
        return
      }
      
      let config = this.level.config
      this.parameters = []
      
      // Handle nested array structure from API
      // config is an array of arrays, each containing [label, param1, param2, ...]
      if (Array.isArray(config) && config.length > 0) {
        config.forEach((group, groupIdx) => {
          if (Array.isArray(group)) {
            // Skip the first item (label like "conditions" or "actions")
            // and extract the actual parameter objects
            for (let i = 1; i < group.length; i++) {
              const param = group[i]
              if (typeof param === 'object' && param !== null) {
                const id = param.id || `param-${groupIdx}-${i}`
                const name = param.name || param.id || `Parameter ${this.parameters.length + 1}`
                
                // Extract values - could be in various formats
                let values = []
                if (Array.isArray(param.values)) {
                  values = param.values
                } else if (param.values && typeof param.values === 'object') {
                  values = Object.keys(param.values)
                } else if (param.type === 'boolean') {
                  // Boolean parameters have true/false values
                  values = ['true', 'false']
                } else if (!param.values && !param.type) {
                  // Action parameters without explicit values - use yes/no or true/false
                  values = ['true', 'false']
                }
                
                this.parameters.push({
                  id,
                  name,
                  values: values || []
                })
              }
            }
          }
        })
      }
      
      console.log('Parameters loaded:', this.parameters)
      
      if (this.testCases.length === 0) {
        this.addTestCase()
      }
    },
    addTestCase() {
      const newTest = {}
      this.parameters.forEach(param => {
        newTest[param.id] = ''
      })
      this.testCases.push(newTest)
    },
    removeTestCase(index) {
      if (this.testCases.length > 1) {
        this.testCases.splice(index, 1)
      }
    },
    calculateTotalPairs() {
      let total = 0
      for (let i = 0; i < this.parameters.length; i++) {
        for (let j = i + 1; j < this.parameters.length; j++) {
          const param1 = this.parameters[i]
          const param2 = this.parameters[j]
          const values1 = (param1.values || []).length
          const values2 = (param2.values || []).length
          if (values1 > 0 && values2 > 0) {
            total += values1 * values2
          }
        }
      }
      return total
    },
    estimateCoveredPairs() {
      // Rough estimation based on number of complete test cases
      const completeTests = this.testCases.filter(test => {
        return this.parameters.every(param => test[param.id])
      })
      
      if (completeTests.length === 0) return 0
      
      // Each test case covers approximately n*(n-1)/2 pairs
      const pairsPerTest = (this.parameters.length * (this.parameters.length - 1)) / 2
      return Math.min(this.calculateTotalPairs(), completeTests.length * pairsPerTest)
    },
    submitTests() {
      // Filter out incomplete test cases
      const completeTests = this.testCases.filter(test => {
        return this.parameters.every(param => test[param.id])
      })

      if (completeTests.length === 0) {
        alert('Please complete at least one test case')
        return
      }

      this.$emit('submit', completeTests)
    },
    reset() {
      this.testCases = []
      this.addTestCase()
    }
  }
}
</script>

<style scoped>
.pairwise-builder {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.instructions {
  margin-bottom: 30px;
  padding: 20px;
  background: #e3f2fd;
  border-radius: 4px;
}

.instructions h3 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.instructions p {
  color: #555;
  line-height: 1.6;
}

.parameters-info {
  margin-bottom: 30px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 4px;
}

.parameters-info h4 {
  color: #2c3e50;
  margin-bottom: 15px;
}

.parameter-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.parameter-item {
  padding: 10px;
  background: white;
  border-radius: 4px;
  border-left: 3px solid #4CAF50;
}

.parameter-item strong {
  color: #2c3e50;
  margin-right: 10px;
}

.values {
  color: #555;
}

.test-cases-section {
  margin-bottom: 30px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h4 {
  color: #2c3e50;
}

.test-cases-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.test-case-card {
  border: 2px solid #ddd;
  border-radius: 8px;
  padding: 20px;
  background: #fafafa;
}

.test-case-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.test-case-header h5 {
  color: #2c3e50;
}

.test-case-params {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.param-field {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.param-field label {
  font-weight: 500;
  color: #555;
}

.param-field select {
  padding: 8px;
}

.coverage-info {
  margin-bottom: 30px;
  padding: 20px;
  background: #fff3cd;
  border-radius: 4px;
}

.coverage-info h4 {
  color: #2c3e50;
  margin-bottom: 15px;
}

.coverage-stats {
  display: flex;
  gap: 30px;
}

.stat {
  display: flex;
  gap: 10px;
  align-items: center;
}

.stat span {
  color: #555;
}

.stat strong {
  font-size: 20px;
  color: #ff9800;
}

.controls {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.btn-small {
  padding: 6px 12px;
  font-size: 12px;
}

.btn-large {
  padding: 12px 30px;
  font-size: 16px;
}
</style>
