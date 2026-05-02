import React from 'react';
import './TrafficLight.css';

const TrafficLight = ({ status }) => {
  if (!status) return <div>No traffic light data</div>;

  const { currentState, mode, timeRemaining, pedestrianRequested, emergencyActive } = status;

  return (
    <div className="traffic-light-container">
      <div className="traffic-light-pole">
        <div className="traffic-light-box">
          <div className={`light red ${currentState === 'RED' ? 'active' : ''}`}>
            <div className="light-glow"></div>
          </div>
          <div className={`light yellow ${currentState === 'YELLOW' ? 'active' : ''}`}>
            <div className="light-glow"></div>
          </div>
          <div className={`light green ${currentState === 'GREEN' ? 'active' : ''}`}>
            <div className="light-glow"></div>
          </div>
        </div>
      </div>

      <div className="traffic-light-info">
        <div className="info-row">
          <span className="label">Current State:</span>
          <span className={`value state-${currentState.toLowerCase()}`}>
            {currentState}
          </span>
        </div>
        <div className="info-row">
          <span className="label">Mode:</span>
          <span className="value">{mode}</span>
        </div>
        <div className="info-row">
          <span className="label">Time Remaining:</span>
          <span className="value">
            {timeRemaining === Infinity ? '∞' : `${timeRemaining}s`}
          </span>
        </div>
        {pedestrianRequested && (
          <div className="info-row pedestrian-alert">
            <span className="label">🚶 Pedestrian Crossing Requested</span>
          </div>
        )}
        {emergencyActive && (
          <div className="info-row emergency-alert">
            <span className="label">🚨 Emergency Mode Active</span>
          </div>
        )}
      </div>
    </div>
  );
};

export default TrafficLight;
