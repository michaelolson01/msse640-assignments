const express = require('express');
const cors = require('cors');
const path = require('path');
const trafficController = require('./server/controllers/trafficController');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Traffic Light API routes
app.post('/api/traffic-lights', trafficController.createLight);
app.get('/api/traffic-lights', trafficController.getAllLights);
app.get('/api/traffic-lights/:id', trafficController.getLight);
app.put('/api/traffic-lights/:id/mode', trafficController.setMode);
app.post('/api/traffic-lights/:id/pedestrian', trafficController.requestPedestrian);
app.get('/api/traffic-lights/:id/history', trafficController.getHistory);
app.get('/api/traffic-lights/:id/valid-states', trafficController.getValidStates);

// Simulation control routes
app.post('/api/simulation/start', trafficController.startSimulation);
app.post('/api/simulation/stop', trafficController.stopSimulation);
app.post('/api/simulation/tick', trafficController.manualTick);
app.post('/api/simulation/reset', trafficController.resetSimulation);
app.get('/api/simulation/status', trafficController.getSimulationStatus);

// Legacy test routes
app.get('/api/hello', (req, res) => {
  res.json({ message: 'Traffic Light Simulator API' });
});

// Serve static assets in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'client/build')));
  
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'client/build', 'index.html'));
  });
}

app.listen(PORT, () => {
  console.log(`Traffic Light Simulator Server running on port ${PORT}`);
  console.log(`API available at http://localhost:${PORT}/api`);
});
