import React, { useState } from 'react';
import './TestingDashboard.css';

const TestingDashboard = ({ lightStatus, history }) => {
  const [activeTab, setActiveTab] = useState('state');

  const getDataFlowInfo = () => {
    if (!lightStatus) return [];

    return [
      {
        variable: 'currentState',
        value: lightStatus.currentState,
        lifecycle: 'DEFINED → USED',
        description: 'Tracks the current state of the traffic light'
      },
      {
        variable: 'timeRemaining',
        value: lightStatus.timeRemaining === Infinity ? '∞' : lightStatus.timeRemaining,
        lifecycle: 'DEFINED → USED → KILLED',
        description: 'Countdown timer, reset on each transition'
      },
      {
        variable: 'mode',
        value: lightStatus.mode,
        lifecycle: 'DEFINED → USED',
        description: 'Operating mode affecting control flow'
      },
      {
        variable: 'pedestrianRequested',
        value: lightStatus.pedestrianRequested ? 'true' : 'false',
        lifecycle: 'DEFINED → USED → KILLED',
        description: 'Flag set by pedestrian button, cleared after use'
      },
      {
        variable: 'transitionCount',
        value: lightStatus.transitionCount,
        lifecycle: 'DEFINED → USED',
        description: 'Accumulator tracking total state changes'
      }
    ];
  };

  const getControlFlowPaths = () => {
    if (!lightStatus) return [];

    const paths = [
      {
        path: 'Normal Cycle',
        condition: 'mode === NORMAL',
        active: lightStatus.mode === 'NORMAL',
        description: 'RED → GREEN → YELLOW → RED'
      },
      {
        path: 'Emergency Override',
        condition: 'mode === EMERGENCY',
        active: lightStatus.mode === 'EMERGENCY',
        description: 'Any state → RED (immediate)'
      },
      {
        path: 'Maintenance Flash',
        condition: 'mode === MAINTENANCE',
        active: lightStatus.mode === 'MAINTENANCE',
        description: 'YELLOW flashing pattern'
      },
      {
        path: 'Pedestrian Request',
        condition: 'pedestrianRequested === true',
        active: lightStatus.pedestrianRequested,
        description: 'Extends RED time or shortens GREEN time'
      }
    ];

    return paths;
  };

  const getStateTransitionCoverage = () => {
    if (!history || history.length === 0) return [];

    const transitions = {};
    history.forEach(trans => {
      const key = `${trans.from} → ${trans.to}`;
      transitions[key] = (transitions[key] || 0) + 1;
    });

    const allPossibleTransitions = [
      'RED → GREEN',
      'GREEN → YELLOW',
      'YELLOW → RED',
      'RED → RED',
      'GREEN → RED',
      'YELLOW → YELLOW'
    ];

    return allPossibleTransitions.map(trans => ({
      transition: trans,
      count: transitions[trans] || 0,
      covered: (transitions[trans] || 0) > 0
    }));
  };

  return (
    <div className="testing-dashboard">
      <div className="tab-buttons">
        <button
          className={`tab-btn ${activeTab === 'state' ? 'active' : ''}`}
          onClick={() => setActiveTab('state')}
        >
          State Transitions
        </button>
        <button
          className={`tab-btn ${activeTab === 'control' ? 'active' : ''}`}
          onClick={() => setActiveTab('control')}
        >
          Control Flow
        </button>
        <button
          className={`tab-btn ${activeTab === 'data' ? 'active' : ''}`}
          onClick={() => setActiveTab('data')}
        >
          Data Flow
        </button>
      </div>

      <div className="tab-content">
        {activeTab === 'state' && (
          <div className="state-testing">
            <h4>State Transition Coverage</h4>
            <p className="description">
              Tracks which state transitions have been executed during testing.
            </p>
            <div className="coverage-list">
              {getStateTransitionCoverage().map((item, idx) => (
                <div key={idx} className={`coverage-item ${item.covered ? 'covered' : 'not-covered'}`}>
                  <span className="coverage-icon">
                    {item.covered ? '✅' : '⬜'}
                  </span>
                  <span className="coverage-transition">{item.transition}</span>
                  <span className="coverage-count">({item.count}x)</span>
                </div>
              ))}
            </div>
            <div className="history-section">
              <h4>Recent Transitions</h4>
              <div className="history-list">
                {history && history.length > 0 ? (
                  history.slice(-5).reverse().map((trans, idx) => (
                    <div key={idx} className="history-item">
                      <span className="history-number">#{trans.transitionNumber}</span>
                      <span className="history-transition">
                        {trans.from} → {trans.to}
                      </span>
                      <span className="history-mode">{trans.mode}</span>
                    </div>
                  ))
                ) : (
                  <p className="no-data">No transitions yet. Start the simulation!</p>
                )}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'control' && (
          <div className="control-testing">
            <h4>Control Flow Paths</h4>
            <p className="description">
              Shows different execution paths based on conditions and modes.
            </p>
            <div className="path-list">
              {getControlFlowPaths().map((path, idx) => (
                <div key={idx} className={`path-item ${path.active ? 'active-path' : ''}`}>
                  <div className="path-header">
                    <span className="path-icon">
                      {path.active ? '🟢' : '⚪'}
                    </span>
                    <strong>{path.path}</strong>
                  </div>
                  <div className="path-condition">
                    <code>{path.condition}</code>
                  </div>
                  <div className="path-description">
                    {path.description}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'data' && (
          <div className="data-testing">
            <h4>Data Flow Analysis</h4>
            <p className="description">
              Tracks variable lifecycle: DEFINE → USE → KILL pattern.
            </p>
            <div className="data-flow-table">
              <table>
                <thead>
                  <tr>
                    <th>Variable</th>
                    <th>Current Value</th>
                    <th>Lifecycle</th>
                    <th>Description</th>
                  </tr>
                </thead>
                <tbody>
                  {getDataFlowInfo().map((item, idx) => (
                    <tr key={idx}>
                      <td><code>{item.variable}</code></td>
                      <td><strong>{item.value}</strong></td>
                      <td><span className="lifecycle-badge">{item.lifecycle}</span></td>
                      <td>{item.description}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default TestingDashboard;
