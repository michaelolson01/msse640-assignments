/**
 * Simulation Service
 * Manages traffic light simulation and timing
 */

const TrafficLight = require('../models/TrafficLight');

class SimulationService {
  constructor() {
    this.trafficLights = new Map();
    this.isRunning = false;
    this.intervalId = null;
    this.tickRate = 1000; // 1 second per tick
  }

  /**
   * Create a new traffic light
   */
  createTrafficLight(id, config = {}) {
    const light = new TrafficLight(id, config);
    this.trafficLights.set(id, light);
    return light.getStatus();
  }

  /**
   * Get traffic light by ID
   */
  getTrafficLight(id) {
    return this.trafficLights.get(id);
  }

  /**
   * Get all traffic lights
   */
  getAllTrafficLights() {
    const lights = [];
    this.trafficLights.forEach(light => {
      lights.push(light.getStatus());
    });
    return lights;
  }

  /**
   * Start simulation
   */
  start() {
    if (this.isRunning) {
      return { success: false, message: 'Simulation already running' };
    }

    this.isRunning = true;
    this.intervalId = setInterval(() => {
      this.tick();
    }, this.tickRate);

    return { success: true, message: 'Simulation started' };
  }

  /**
   * Stop simulation
   */
  stop() {
    if (!this.isRunning) {
      return { success: false, message: 'Simulation not running' };
    }

    this.isRunning = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }

    return { success: true, message: 'Simulation stopped' };
  }

  /**
   * Simulation tick - update all traffic lights
   */
  tick() {
    const updates = [];
    this.trafficLights.forEach(light => {
      const status = light.update(1);
      updates.push(status);
    });
    return updates;
  }

  /**
   * Manual tick for testing
   */
  manualTick() {
    return this.tick();
  }

  /**
   * Reset all traffic lights
   */
  reset() {
    this.trafficLights.forEach(light => {
      light.reset();
    });
    return { success: true, message: 'All traffic lights reset' };
  }

  /**
   * Delete traffic light
   */
  deleteTrafficLight(id) {
    const deleted = this.trafficLights.delete(id);
    return { 
      success: deleted, 
      message: deleted ? 'Traffic light deleted' : 'Traffic light not found' 
    };
  }

  /**
   * Get simulation status
   */
  getStatus() {
    return {
      isRunning: this.isRunning,
      tickRate: this.tickRate,
      lightCount: this.trafficLights.size,
      lights: this.getAllTrafficLights()
    };
  }
}

// Singleton instance
const simulationService = new SimulationService();

module.exports = simulationService;
