import React from 'react';
import './ControlPanel.css';

const ControlPanel = ({
  lightStatus,
  simulationStatus,
  onStartSimulation,
  onStopSimulation,
  onModeChange,
  onPedestrianRequest,
  onManualTick,
  onReset
}) => {
  const isRunning = simulationStatus?.isRunning;

  return (
    <div className="control-panel">
      <div className="control-section">
        <h3>Simulation Control</h3>
        <div className="button-group">
          <button
            className="btn btn-primary"
            onClick={onStartSimulation}
            disabled={isRunning}
          >
            ▶️ Start
          </button>
          <button
            className="btn btn-danger"
            onClick={onStopSimulation}
            disabled={!isRunning}
          >
            ⏸️ Stop
          </button>
          <button
            className="btn btn-secondary"
            onClick={onManualTick}
            disabled={isRunning}
          >
            ⏭️ Manual Tick
          </button>
          <button
            className="btn btn-warning"
            onClick={onReset}
          >
            🔄 Reset
          </button>
        </div>
      </div>

      <div className="control-section">
        <h3>Mode Selection</h3>
        <div className="button-group">
          <button
            className={`btn ${lightStatus?.mode === 'NORMAL' ? 'btn-active' : 'btn-outline'}`}
            onClick={() => onModeChange('NORMAL')}
          >
            Normal
          </button>
          <button
            className={`btn ${lightStatus?.mode === 'EMERGENCY' ? 'btn-active' : 'btn-outline'}`}
            onClick={() => onModeChange('EMERGENCY')}
          >
            🚨 Emergency
          </button>
          <button
            className={`btn ${lightStatus?.mode === 'MAINTENANCE' ? 'btn-active' : 'btn-outline'}`}
            onClick={() => onModeChange('MAINTENANCE')}
          >
            🔧 Maintenance
          </button>
        </div>
      </div>

      <div className="control-section">
        <h3>Actions</h3>
        <button
          className="btn btn-pedestrian"
          onClick={onPedestrianRequest}
          disabled={lightStatus?.mode !== 'NORMAL'}
        >
          🚶 Request Pedestrian Crossing
        </button>
      </div>

      <div className="control-section status-display">
        <h3>Status</h3>
        <div className="status-item">
          <span className="status-label">Simulation:</span>
          <span className={`status-value ${isRunning ? 'running' : 'stopped'}`}>
            {isRunning ? '🟢 Running' : '🔴 Stopped'}
          </span>
        </div>
        <div className="status-item">
          <span className="status-label">Transitions:</span>
          <span className="status-value">{lightStatus?.transitionCount || 0}</span>
        </div>
      </div>
    </div>
  );
};

export default ControlPanel;
