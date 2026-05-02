import React from 'react';
import './StateTransitionDiagram.css';

const StateTransitionDiagram = ({ currentState, mode }) => {
  const normalTransitions = [
    { from: 'RED', to: 'GREEN', label: 'Timer expires' },
    { from: 'GREEN', to: 'YELLOW', label: 'Timer expires' },
    { from: 'YELLOW', to: 'RED', label: 'Timer expires' }
  ];

  const isTransitionActive = (from, to) => {
    return currentState === from;
  };

  return (
    <div className="state-diagram">
      <div className="mode-indicator">
        <strong>Current Mode:</strong> {mode}
      </div>

      {mode === 'NORMAL' && (
        <div className="diagram-container">
          <svg viewBox="0 0 400 300" className="diagram-svg">
            {/* RED state */}
            <circle
              cx="200"
              cy="50"
              r="35"
              className={`state-circle ${currentState === 'RED' ? 'active' : ''}`}
              fill="#ffcccc"
              stroke="#ff0000"
              strokeWidth="3"
            />
            <text x="200" y="55" textAnchor="middle" className="state-text">
              RED
            </text>

            {/* GREEN state */}
            <circle
              cx="100"
              cy="200"
              r="35"
              className={`state-circle ${currentState === 'GREEN' ? 'active' : ''}`}
              fill="#ccffcc"
              stroke="#00aa00"
              strokeWidth="3"
            />
            <text x="100" y="205" textAnchor="middle" className="state-text">
              GREEN
            </text>

            {/* YELLOW state */}
            <circle
              cx="300"
              cy="200"
              r="35"
              className={`state-circle ${currentState === 'YELLOW' ? 'active' : ''}`}
              fill="#ffffcc"
              stroke="#ffaa00"
              strokeWidth="3"
            />
            <text x="300" y="205" textAnchor="middle" className="state-text">
              YELLOW
            </text>

            {/* Arrows */}
            {/* RED to GREEN */}
            <defs>
              <marker
                id="arrowhead"
                markerWidth="10"
                markerHeight="10"
                refX="9"
                refY="3"
                orient="auto"
              >
                <polygon points="0 0, 10 3, 0 6" fill="#333" />
              </marker>
            </defs>

            <path
              d="M 175 75 Q 125 125 115 165"
              fill="none"
              stroke={isTransitionActive('RED', 'GREEN') ? '#667eea' : '#999'}
              strokeWidth={isTransitionActive('RED', 'GREEN') ? '3' : '2'}
              markerEnd="url(#arrowhead)"
              className={isTransitionActive('RED', 'GREEN') ? 'active-path' : ''}
            />

            {/* GREEN to YELLOW */}
            <path
              d="M 135 200 L 265 200"
              fill="none"
              stroke={isTransitionActive('GREEN', 'YELLOW') ? '#667eea' : '#999'}
              strokeWidth={isTransitionActive('GREEN', 'YELLOW') ? '3' : '2'}
              markerEnd="url(#arrowhead)"
              className={isTransitionActive('GREEN', 'YELLOW') ? 'active-path' : ''}
            />

            {/* YELLOW to RED */}
            <path
              d="M 285 165 Q 250 100 225 75"
              fill="none"
              stroke={isTransitionActive('YELLOW', 'RED') ? '#667eea' : '#999'}
              strokeWidth={isTransitionActive('YELLOW', 'RED') ? '3' : '2'}
              markerEnd="url(#arrowhead)"
              className={isTransitionActive('YELLOW', 'RED') ? 'active-path' : ''}
            />
          </svg>

          <div className="transition-legend">
            <h4>Valid Transitions:</h4>
            <ul>
              {normalTransitions.map((trans, idx) => (
                <li
                  key={idx}
                  className={isTransitionActive(trans.from, trans.to) ? 'active-transition' : ''}
                >
                  <strong>{trans.from}</strong> → <strong>{trans.to}</strong>
                  <span className="transition-label">({trans.label})</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}

      {mode === 'EMERGENCY' && (
        <div className="emergency-mode-info">
          <div className="alert alert-danger">
            <h4>🚨 Emergency Mode</h4>
            <p>All lights transition to RED immediately and remain RED until emergency is cleared.</p>
          </div>
        </div>
      )}

      {mode === 'MAINTENANCE' && (
        <div className="maintenance-mode-info">
          <div className="alert alert-warning">
            <h4>🔧 Maintenance Mode</h4>
            <p>Light flashes YELLOW continuously (1 second intervals).</p>
          </div>
        </div>
      )}
    </div>
  );
};

export default StateTransitionDiagram;
