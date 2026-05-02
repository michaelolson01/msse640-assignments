import React, { useState, useEffect } from 'react';
import './App.css';
import TrafficLight from './components/TrafficLight';
import ControlPanel from './components/ControlPanel';
import StateTransitionDiagram from './components/StateTransitionDiagram';
import TestingDashboard from './components/TestingDashboard';

function App() {
  const [lightId] = useState('light1');
  const [lightStatus, setLightStatus] = useState(null);
  const [simulationStatus, setSimulationStatus] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Initialize traffic light
  useEffect(() => {
    const initializeLight = async () => {
      try {
        // Create traffic light
        const response = await fetch('/api/traffic-lights', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ id: lightId })
        });
        
        if (!response.ok) {
          // Light might already exist, try to get it
          const getResponse = await fetch(`/api/traffic-lights/${lightId}`);
          if (getResponse.ok) {
            const data = await getResponse.json();
            setLightStatus(data.data);
          }
        } else {
          const data = await response.json();
          setLightStatus(data.data);
        }
        
        setLoading(false);
      } catch (err) {
        setError('Failed to initialize traffic light: ' + err.message);
        setLoading(false);
      }
    };

    initializeLight();
  }, [lightId]);

  // Poll for updates when simulation is running
  useEffect(() => {
    let interval;
    
    if (simulationStatus?.isRunning) {
      interval = setInterval(async () => {
        try {
          const response = await fetch(`/api/traffic-lights/${lightId}`);
          const data = await response.json();
          setLightStatus(data.data);
          
          // Fetch history
          const historyResponse = await fetch(`/api/traffic-lights/${lightId}/history`);
          const historyData = await historyResponse.json();
          setHistory(historyData.data.transitions);
        } catch (err) {
          console.error('Error polling status:', err);
        }
      }, 500);
    }
    
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [simulationStatus, lightId]);

  const handleStartSimulation = async () => {
    try {
      const response = await fetch('/api/simulation/start', { method: 'POST' });
      const data = await response.json();
      
      const statusResponse = await fetch('/api/simulation/status');
      const statusData = await statusResponse.json();
      setSimulationStatus(statusData.data);
    } catch (err) {
      setError('Failed to start simulation: ' + err.message);
    }
  };

  const handleStopSimulation = async () => {
    try {
      const response = await fetch('/api/simulation/stop', { method: 'POST' });
      const data = await response.json();
      
      const statusResponse = await fetch('/api/simulation/status');
      const statusData = await statusResponse.json();
      setSimulationStatus(statusData.data);
    } catch (err) {
      setError('Failed to stop simulation: ' + err.message);
    }
  };

  const handleModeChange = async (mode) => {
    try {
      const response = await fetch(`/api/traffic-lights/${lightId}/mode`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ mode })
      });
      const data = await response.json();
      setLightStatus(data.data);
    } catch (err) {
      setError('Failed to change mode: ' + err.message);
    }
  };

  const handlePedestrianRequest = async () => {
    try {
      const response = await fetch(`/api/traffic-lights/${lightId}/pedestrian`, {
        method: 'POST'
      });
      const data = await response.json();
      setLightStatus(prev => ({ ...prev, pedestrianRequested: true }));
    } catch (err) {
      setError('Failed to request pedestrian crossing: ' + err.message);
    }
  };

  const handleManualTick = async () => {
    try {
      await fetch('/api/simulation/tick', { method: 'POST' });
      
      const response = await fetch(`/api/traffic-lights/${lightId}`);
      const data = await response.json();
      setLightStatus(data.data);
      
      const historyResponse = await fetch(`/api/traffic-lights/${lightId}/history`);
      const historyData = await historyResponse.json();
      setHistory(historyData.data.transitions);
    } catch (err) {
      setError('Failed to tick: ' + err.message);
    }
  };

  const handleReset = async () => {
    try {
      await fetch('/api/simulation/reset', { method: 'POST' });
      
      const response = await fetch(`/api/traffic-lights/${lightId}`);
      const data = await response.json();
      setLightStatus(data.data);
      setHistory([]);
    } catch (err) {
      setError('Failed to reset: ' + err.message);
    }
  };

  if (loading) {
    return (
      <div className="App">
        <div className="loading">Loading Traffic Light Simulator...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="App">
        <div className="error">{error}</div>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚦 Traffic Light Simulator</h1>
        <p>Learn State Transitions, Control Flow, and Data Flow Testing</p>
      </header>

      <div className="main-content">
        <div className="left-panel">
          <div className="section">
            <h2>Traffic Light</h2>
            <TrafficLight status={lightStatus} />
          </div>

          <div className="section">
            <h2>Control Panel</h2>
            <ControlPanel
              lightStatus={lightStatus}
              simulationStatus={simulationStatus}
              onStartSimulation={handleStartSimulation}
              onStopSimulation={handleStopSimulation}
              onModeChange={handleModeChange}
              onPedestrianRequest={handlePedestrianRequest}
              onManualTick={handleManualTick}
              onReset={handleReset}
            />
          </div>
        </div>

        <div className="right-panel">
          <div className="section">
            <h2>State Transition Diagram</h2>
            <StateTransitionDiagram 
              currentState={lightStatus?.currentState}
              mode={lightStatus?.mode}
            />
          </div>

          <div className="section">
            <h2>Testing Dashboard</h2>
            <TestingDashboard
              lightStatus={lightStatus}
              history={history}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
