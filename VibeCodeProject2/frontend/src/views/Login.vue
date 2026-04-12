<template>
  <div class="login-page">
    <div class="login-container">
      <h1>{{ isRegister ? 'Register' : 'Login' }}</h1>
      
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label>Username</label>
          <input 
            v-model="username" 
            type="text" 
            required 
            placeholder="Enter username"
          />
        </div>

        <div class="form-group" v-if="isRegister">
          <label>Email (optional)</label>
          <input 
            v-model="email" 
            type="email" 
            placeholder="Enter email"
          />
        </div>

        <div class="form-group">
          <label>Password</label>
          <input 
            v-model="password" 
            type="password" 
            required 
            placeholder="Enter password"
          />
        </div>

        <div class="error-message" v-if="errorMessage">
          {{ errorMessage }}
        </div>

        <button type="submit" class="btn-primary btn-full">
          {{ isRegister ? 'Register' : 'Login' }}
        </button>
      </form>

      <div class="toggle-mode">
        <a href="#" @click.prevent="toggleMode">
          {{ isRegister ? 'Already have an account? Login' : "Don't have an account? Register" }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../services/api'

export default {
  name: 'Login',
  data() {
    return {
      username: '',
      email: '',
      password: '',
      isRegister: false,
      errorMessage: ''
    }
  },
  methods: {
    async handleSubmit() {
      this.errorMessage = ''
      
      try {
        let response
        if (this.isRegister) {
          response = await api.register(this.username, this.password, this.email)
        } else {
          response = await api.login(this.username, this.password)
        }

        if (response && response.success) {
          // Store user data
          this.$store.dispatch('login', response.data)
          
          // Try to load user progress, but don't fail if it doesn't work
          try {
            const progressResponse = await api.getProgress(response.data.id)
            if (progressResponse && progressResponse.success) {
              this.$store.dispatch('setProgress', progressResponse.data)
            }
          } catch (progressError) {
            console.warn('Could not load progress:', progressError)
            // Continue anyway - progress loading is not critical
          }
          
          // Navigate to levels page
          this.$router.push('/levels')
        } else {
          this.errorMessage = (response && response.error) || 'An error occurred'
        }
      } catch (error) {
        console.error('Login/Register error:', error)
        this.errorMessage = 'Network error. Please try again.'
      }
    },
    toggleMode() {
      this.isRegister = !this.isRegister
      this.errorMessage = ''
    }
  }
}
</script>

<style scoped>
.login-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
  padding: 20px;
}

.login-container {
  background: white;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  width: 100%;
  max-width: 400px;
}

.login-container h1 {
  text-align: center;
  color: #2c3e50;
  margin-bottom: 30px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #2c3e50;
  font-weight: 500;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.error-message {
  background-color: #fee;
  color: #c00;
  padding: 10px;
  border-radius: 4px;
  margin-bottom: 15px;
  text-align: center;
}

.btn-full {
  width: 100%;
  padding: 12px;
  font-size: 16px;
}

.toggle-mode {
  text-align: center;
  margin-top: 20px;
}

.toggle-mode a {
  color: #4CAF50;
  text-decoration: none;
}

.toggle-mode a:hover {
  text-decoration: underline;
}
</style>
