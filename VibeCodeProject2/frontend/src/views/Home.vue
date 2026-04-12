<template>
  <div class="home">
    <div class="hero">
      <h1>Welcome to TestCraft Academy</h1>
      <p class="subtitle">Master Decision Tables and Pairwise Testing through Interactive Challenges</p>
      
      <div class="features">
        <div class="feature">
          <h3>📊 Decision Tables</h3>
          <p>Learn to create comprehensive decision tables for complex business rules</p>
        </div>
        <div class="feature">
          <h3>🔬 Pairwise Testing</h3>
          <p>Master efficient test design with pairwise testing techniques</p>
        </div>
        <div class="feature">
          <h3>🏆 Progressive Learning</h3>
          <p>Start simple and advance through increasingly challenging levels</p>
        </div>
      </div>

      <div class="cta">
        <router-link to="/login" class="btn-large btn-primary">Get Started</router-link>
      </div>
    </div>

    <div class="about">
      <h2>How It Works</h2>
      <ol>
        <li><strong>Choose a Level:</strong> Select from decision table or pairwise testing challenges</li>
        <li><strong>Solve the Problem:</strong> Use the interactive tools to build your solution</li>
        <li><strong>Get Feedback:</strong> Receive instant scoring and validation</li>
        <li><strong>Progress:</strong> Unlock new levels as you improve your skills</li>
      </ol>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home',
  mounted() {
    // Redirect to levels if already logged in
    if (this.$store.getters.isLoggedIn) {
      this.$router.push('/levels')
    }
  }
}
</script>

<style scoped>
.home {
  max-width: 1000px;
  margin: 0 auto;
}

.hero {
  text-align: center;
  padding: 60px 20px;
}

.hero h1 {
  font-size: 48px;
  color: #2c3e50;
  margin-bottom: 20px;
}

.subtitle {
  font-size: 20px;
  color: #7f8c8d;
  margin-bottom: 50px;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
  margin: 50px 0;
}

.feature {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.feature h3 {
  font-size: 24px;
  margin-bottom: 15px;
  color: #2c3e50;
}

.feature p {
  color: #7f8c8d;
  line-height: 1.6;
}

.cta {
  margin-top: 50px;
}

.btn-large {
  display: inline-block;
  padding: 15px 40px;
  font-size: 18px;
  text-decoration: none;
  border-radius: 6px;
}

.about {
  background: white;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-top: 50px;
}

.about h2 {
  color: #2c3e50;
  margin-bottom: 30px;
  text-align: center;
}

.about ol {
  max-width: 600px;
  margin: 0 auto;
  text-align: left;
}

.about li {
  margin-bottom: 20px;
  line-height: 1.6;
  color: #555;
}

.about strong {
  color: #2c3e50;
}
</style>
