<template>
  <div class="decision-table-builder">
    <div class="instructions">
      <h3>📊 Build Your Decision Table</h3>
      <p>Create rules that cover all possible scenarios. Each rule should specify conditions and the resulting actions.</p>
    </div>

    <div class="table-container">
      <table class="decision-table">
        <thead>
          <tr class="section-header">
            <th class="label-column">Conditions</th>
            <th v-for="(rule, index) in rules" :key="'cond-rule-' + index" class="rule-column">
              <div class="rule-header">
                Rule {{ index + 1 }}
                <button @click="removeRule(index)" class="btn-small btn-danger" v-if="rules.length > 1">×</button>
              </div>
            </th>
            <th class="add-column">
              <button @click="addRule" class="btn-small btn-primary">+ Add Rule</button>
            </th>
          </tr>
        </thead>
        <tbody>
          <!-- Conditions Section -->
          <tr v-for="condition in conditions" :key="condition.id" class="condition-row">
            <td class="label-cell">{{ condition.name }}</td>
            <td v-for="(rule, ruleIndex) in rules" :key="'cond-' + ruleIndex">
              <select v-model="rule.conditions[condition.id]" class="condition-select">
                <option value="true">Yes</option>
                <option value="false">No</option>
                <option value="na">N/A</option>
              </select>
            </td>
            <td></td>
          </tr>

        </tbody>
        
        <!-- Actions Section -->
        <thead>
          <tr class="section-header">
            <th class="label-column">Actions</th>
            <th v-for="(rule, index) in rules" :key="'act-rule-' + index" class="rule-column">
              Rule {{ index + 1 }}
            </th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="action in actions" :key="action.id" class="action-row">
            <td class="label-cell">{{ action.name }}</td>
            <td v-for="(rule, ruleIndex) in rules" :key="'act-' + ruleIndex">
              <input 
                type="checkbox" 
                v-model="rule.actions[action.id]"
                class="action-checkbox"
              />
            </td>
            <td></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="controls">
      <button @click="submitTable" class="btn-primary btn-large">Submit Solution</button>
      <button @click="reset" class="btn-secondary">Reset Table</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DecisionTableBuilder',
  props: {
    level: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      conditions: [],
      actions: [],
      rules: []
    }
  },
  mounted() {
    this.initializeTable()
  },
  methods: {
    initializeTable() {
      const config = this.level.config
      
      // Parse the config structure which is an array of [type, ...items]
      if (Array.isArray(config)) {
        config.forEach(section => {
          if (Array.isArray(section) && section.length > 0) {
            const [type, ...items] = section
            if (type === 'conditions') {
              this.conditions = items
            } else if (type === 'actions') {
              this.actions = items
            }
          }
        })
      }
      
      this.addRule()
    },
    addRule() {
      const newRule = {
        conditions: {},
        actions: {}
      }
      
      this.conditions.forEach(c => {
        newRule.conditions[c.id] = 'na'
      })
      
      this.actions.forEach(a => {
        newRule.actions[a.id] = false
      })
      
      this.rules.push(newRule)
    },
    removeRule(index) {
      if (this.rules.length > 1) {
        this.rules.splice(index, 1)
      }
    },
    submitTable() {
      const solution = {
        rules: this.rules
      }
      this.$emit('submit', solution)
    },
    reset() {
      this.rules = []
      this.addRule()
    }
  }
}
</script>

<style scoped>
.decision-table-builder {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.instructions {
  margin-bottom: 30px;
  padding: 20px;
  background: #e8f5e9;
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

.table-container {
  overflow-x: auto;
  margin-bottom: 30px;
}

.decision-table {
  width: 100%;
  border-collapse: collapse;
  border: 2px solid #ddd;
}

.decision-table th,
.decision-table td {
  border: 1px solid #ddd;
  padding: 12px;
  text-align: center;
}

.decision-table th {
  background-color: #4CAF50;
  color: white;
  font-weight: 600;
}

.label-column {
  text-align: left;
  min-width: 200px;
}

.label-cell {
  text-align: left;
  font-weight: 500;
  background-color: #f8f9fa;
  color: #2c3e50;
}

.rule-column {
  min-width: 120px;
}

.rule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.condition-row {
  background-color: #fff;
}

.action-row {
  background-color: #f8f9fa;
}

.section-header th {
  background-color: #2e7d32;
  font-size: 14px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.condition-select {
  width: 100%;
  padding: 6px;
}

.action-checkbox {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.controls {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.btn-small {
  padding: 4px 8px;
  font-size: 12px;
}

.btn-large {
  padding: 12px 30px;
  font-size: 16px;
}

.add-column {
  background-color: #4CAF50;
}
</style>
