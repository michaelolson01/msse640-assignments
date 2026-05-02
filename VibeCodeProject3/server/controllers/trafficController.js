/**
 * Traffic Light Controller
 * REST API endpoints for traffic light operations
 */

const simulationService = require('../services/simulationService');
const TrafficLight = require('../models/TrafficLight');

const trafficController = {
  /**
   * Create a new traffic light
   * POST /api/traffic-lights
   */
  createLight: (req, res) => {
    try {
      const { id, timings } = req.body;
      
      if (!id) {
        return res.status(400).json({ error: 'Traffic light ID is required' });
      }

      const config = timings ? { timings } : {};
      const light = simulationService.createTrafficLight(id, config);
      
      res.status(201).json({
        success: true,
        data: light
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Get all traffic lights
   * GET /api/traffic-lights
   */
  getAllLights: (req, res) => {
    try {
      const lights = simulationService.getAllTrafficLights();
      res.json({
        success: true,
        data: lights
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Get specific traffic light
   * GET /api/traffic-lights/:id
   */
  getLight: (req, res) => {
    try {
      const { id } = req.params;
      const light = simulationService.getTrafficLight(id);
      
      if (!light) {
        return res.status(404).json({ error: 'Traffic light not found' });
      }

      res.json({
        success: true,
        data: light.getStatus()
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Set traffic light mode
   * PUT /api/traffic-lights/:id/mode
   */
  setMode: (req, res) => {
    try {
      const { id } = req.params;
      const { mode } = req.body;
      
      const light = simulationService.getTrafficLight(id);
      if (!light) {
        return res.status(404).json({ error: 'Traffic light not found' });
      }

      const status = light.setMode(mode);
      res.json({
        success: true,
        data: status
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  },

  /**
   * Request pedestrian crossing
   * POST /api/traffic-lights/:id/pedestrian
   */
  requestPedestrian: (req, res) => {
    try {
      const { id } = req.params;
      const light = simulationService.getTrafficLight(id);
      
      if (!light) {
        return res.status(404).json({ error: 'Traffic light not found' });
      }

      const result = light.requestPedestrianCrossing();
      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Get traffic light history
   * GET /api/traffic-lights/:id/history
   */
  getHistory: (req, res) => {
    try {
      const { id } = req.params;
      const light = simulationService.getTrafficLight(id);
      
      if (!light) {
        return res.status(404).json({ error: 'Traffic light not found' });
      }

      const history = light.getHistory();
      res.json({
        success: true,
        data: history
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Get valid next states
   * GET /api/traffic-lights/:id/valid-states
   */
  getValidStates: (req, res) => {
    try {
      const { id } = req.params;
      const light = simulationService.getTrafficLight(id);
      
      if (!light) {
        return res.status(404).json({ error: 'Traffic light not found' });
      }

      const validStates = light.getValidNextStates();
      res.json({
        success: true,
        data: {
          currentState: light.currentState,
          currentMode: light.mode,
          validNextStates: validStates
        }
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Start simulation
   * POST /api/simulation/start
   */
  startSimulation: (req, res) => {
    try {
      const result = simulationService.start();
      res.json(result);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Stop simulation
   * POST /api/simulation/stop
   */
  stopSimulation: (req, res) => {
    try {
      const result = simulationService.stop();
      res.json(result);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Manual tick (for testing)
   * POST /api/simulation/tick
   */
  manualTick: (req, res) => {
    try {
      const updates = simulationService.manualTick();
      res.json({
        success: true,
        data: updates
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Get simulation status
   * GET /api/simulation/status
   */
  getSimulationStatus: (req, res) => {
    try {
      const status = simulationService.getStatus();
      res.json({
        success: true,
        data: status
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  /**
   * Reset simulation
   * POST /api/simulation/reset
   */
  resetSimulation: (req, res) => {
    try {
      const result = simulationService.reset();
      res.json(result);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = trafficController;
