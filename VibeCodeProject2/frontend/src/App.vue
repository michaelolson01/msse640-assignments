<template>
  <div id="app">
    <Navbar v-if="isLoggedIn" />
    <div class="container">
      <router-view/>
    </div>
  </div>
</template>

<script>
import Navbar from './components/Navbar.vue'

export default {
  name: 'App',
  components: {
    Navbar
  },
  computed: {
    isLoggedIn() {
      return this.$store.state.user !== null
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: #f5f5f5;
}

#app {
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

button {
  cursor: pointer;
  font-size: 14px;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  transition: background-color 0.3s;
}

button:hover {
  opacity: 0.9;
}

.btn-primary {
  background-color: #4CAF50;
  color: white;
}

.btn-secondary {
  background-color: #888;
  color: white;
}

.btn-danger {
  background-color: #f44336;
  color: white;
}

input, select {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

input:focus, select:focus {
  outline: none;
  border-color: #4CAF50;
}
</style>
