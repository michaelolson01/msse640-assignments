/**
 * TrafficLight State Machine
 * Demonstrates: State Transitions, Control Flow, and Data Flow
 */

class TrafficLight {
  // State enumeration
  static STATES = {
    RED: 'RED',
    YELLOW: 'YELLOW',
    GREEN: 'GREEN'
  };

  // Mode enumeration
  static MODES = {
    NORMAL: 'NORMAL',
    EMERGENCY: 'EMERGENCY',
    MAINTENANCE: 'MAINTENANCE'
  };

  // Default timing configuration (in seconds)
  static DEFAULT_TIMINGS = {
    RED: 30,
    YELLOW: 5,
    GREEN: 25
  };

  constructor(id, config = {}) {
    this.id = id;
    this.currentState = TrafficLight.STATES.RED;
    this.mode = TrafficLight.MODES.NORMAL;
    this.timings = { ...TrafficLight.DEFAULT_TIMINGS, ...config.timings };
    this.timeRemaining = this.timings[this.currentState];
    this.pedestrianRequested = false;
    this.emergencyActive = false;
    
    // Data flow tracking
    this.stateHistory = [];
    this.transitionCount = 0;
    this.lastTransitionTime = Date.now();
  }

  /**
   * STATE TRANSITION LOGIC
   * Valid transitions in NORMAL mode:
   * RED -> GREEN -> YELLOW -> RED
   */
  transition() {
    const previousState = this.currentState;
    
    // Control Flow: Different paths based on mode
    if (this.mode === TrafficLight.MODES.EMERGENCY) {
      this._transitionToEmergency();
    } else if (this.mode === TrafficLight.MODES.MAINTENANCE) {
      this._transitionToMaintenance();
    } else {
      this._transitionNormal();
    }

    // Data flow: Track state changes
    this._recordTransition(previousState, this.currentState);
    
    return {
      from: previousState,
      to: this.currentState,
      timestamp: Date.now()
    };
  }

  /**
   * Normal mode state transitions
   * Demonstrates: Sequential state flow
   */
  _transitionNormal() {
    switch (this.currentState) {
      case TrafficLight.STATES.RED:
        // Control Flow: Check for pedestrian request
        if (this.pedestrianRequested) {
          // Extend red time for pedestrian crossing
          this.timeRemaining = Math.max(this.timeRemaining, 10);
          this.pedestrianRequested = false;
        } else {
          this.currentState = TrafficLight.STATES.GREEN;
          this.timeRemaining = this.timings.GREEN;
        }
        break;

      case TrafficLight.STATES.GREEN:
        this.currentState = TrafficLight.STATES.YELLOW;
        this.timeRemaining = this.timings.YELLOW;
        break;

      case TrafficLight.STATES.YELLOW:
        this.currentState = TrafficLight.STATES.RED;
        this.timeRemaining = this.timings.RED;
        break;

      default:
        // Error handling: Invalid state
        console.error(`Invalid state: ${this.currentState}`);
        this.currentState = TrafficLight.STATES.RED;
        this.timeRemaining = this.timings.RED;
    }
  }

  /**
   * Emergency mode transition
   * All lights go to RED immediately
   */
  _transitionToEmergency() {
    this.currentState = TrafficLight.STATES.RED;
    this.timeRemaining = Infinity; // Stay red until emergency cleared
  }

  /**
   * Maintenance mode transition
   * Flashing yellow pattern
   */
  _transitionToMaintenance() {
    this.currentState = TrafficLight.STATES.YELLOW;
    this.timeRemaining = 1; // Flash every second
  }

  /**
   * Update timer - called every second
   * Demonstrates: Data flow of time variable
   */
  update(deltaTime = 1) {
    // Data flow: timeRemaining is USED here
    this.timeRemaining -= deltaTime;

    // Control flow: Check if transition needed
    if (this.timeRemaining <= 0) {
      this.transition();
    }

    return this.getStatus();
  }

  /**
   * Set operating mode
   * Demonstrates: Control flow branching
   */
  setMode(newMode) {
    if (!Object.values(TrafficLight.MODES).includes(newMode)) {
      throw new Error(`Invalid mode: ${newMode}`);
    }

    const previousMode = this.mode;
    this.mode = newMode;

    // Control flow: Handle mode-specific logic
    if (newMode === TrafficLight.MODES.EMERGENCY) {
      this.emergencyActive = true;
      this._transitionToEmergency();
    } else if (previousMode === TrafficLight.MODES.EMERGENCY) {
      // Exiting emergency mode
      this.emergencyActive = false;
      this.currentState = TrafficLight.STATES.RED;
      this.timeRemaining = this.timings.RED;
    }

    return this.getStatus();
  }

  /**
   * Request pedestrian crossing
   * Demonstrates: External input affecting control flow
   */
  requestPedestrianCrossing() {
    // Data flow: pedestrianRequested is DEFINED here
    this.pedestrianRequested = true;
    
    // Control flow: Only process if in appropriate state
    if (this.currentState === TrafficLight.STATES.GREEN) {
      // Shorten green time to transition to yellow sooner
      this.timeRemaining = Math.min(this.timeRemaining, 5);
    }

    return {
      accepted: true,
      currentState: this.currentState,
      timeRemaining: this.timeRemaining
    };
  }

  /**
   * Record state transition for testing/analysis
   * Demonstrates: Data flow tracking
   */
  _recordTransition(fromState, toState) {
    // Data flow: Variables are DEFINED and stored
    const transition = {
      from: fromState,
      to: toState,
      timestamp: Date.now(),
      mode: this.mode,
      transitionNumber: ++this.transitionCount
    };

    this.stateHistory.push(transition);
    this.lastTransitionTime = transition.timestamp;

    // Keep only last 100 transitions
    if (this.stateHistory.length > 100) {
      this.stateHistory.shift();
    }
  }

  /**
   * Get current status
   * Demonstrates: Data flow - variables are USED
   */
  getStatus() {
    return {
      id: this.id,
      currentState: this.currentState,
      mode: this.mode,
      timeRemaining: this.timeRemaining,
      pedestrianRequested: this.pedestrianRequested,
      emergencyActive: this.emergencyActive,
      transitionCount: this.transitionCount,
      lastTransitionTime: this.lastTransitionTime
    };
  }

  /**
   * Get state transition history
   * For testing and analysis
   */
  getHistory() {
    return {
      transitions: this.stateHistory,
      totalTransitions: this.transitionCount
    };
  }

  /**
   * Get valid next states
   * Useful for state transition testing
   */
  getValidNextStates() {
    const validTransitions = {
      [TrafficLight.MODES.NORMAL]: {
        [TrafficLight.STATES.RED]: [TrafficLight.STATES.GREEN],
        [TrafficLight.STATES.GREEN]: [TrafficLight.STATES.YELLOW],
        [TrafficLight.STATES.YELLOW]: [TrafficLight.STATES.RED]
      },
      [TrafficLight.MODES.EMERGENCY]: {
        [TrafficLight.STATES.RED]: [TrafficLight.STATES.RED],
        [TrafficLight.STATES.GREEN]: [TrafficLight.STATES.RED],
        [TrafficLight.STATES.YELLOW]: [TrafficLight.STATES.RED]
      },
      [TrafficLight.MODES.MAINTENANCE]: {
        [TrafficLight.STATES.YELLOW]: [TrafficLight.STATES.YELLOW]
      }
    };

    return validTransitions[this.mode][this.currentState] || [];
  }

  /**
   * Reset to initial state
   */
  reset() {
    this.currentState = TrafficLight.STATES.RED;
    this.mode = TrafficLight.MODES.NORMAL;
    this.timeRemaining = this.timings.RED;
    this.pedestrianRequested = false;
    this.emergencyActive = false;
    this.stateHistory = [];
    this.transitionCount = 0;
    this.lastTransitionTime = Date.now();
  }
}

module.exports = TrafficLight;
