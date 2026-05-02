# Stoplight Simulation

A simulation to demonstrate State Transitions, Control Flow Testing and Data Flow Testing.

## Project Structure

```
VibeCodeProject3/
├── server/
│   ├── controllers/
│   │   └── trafficController.js
│   ├── models/
│   │   └── TrafficLight.js
│   └── services/
│       └── simulationService.js
│
└── client/
    ├── src/
    │   ├── components/
    │   │   ├── ControlPanel.css
    │   │   ├── ControlPanel.jsx
    │   │   ├── StateTransitionDiagram.css
    │   │   ├── StateTransitionDiagram.jsx
    │   │   ├── TestingDashboard.css
    │   │   ├── TestingDashboard.jsx
    │   │   ├── TrafficLight.css
    │   │   └── TrafficLight.jsx
    │   ├── hooks/
    │   ├── utils/
    │   ├── App.css
    │   ├── App.js
    │   ├── index.css
    │   └── index.js
    └── public/
        └── index.html
```

## Prerequisites

### Backend
- node.js

### Frontend
- React

## Installation

``` shell
npm install
```

## Execution
``` shell
npm run dev:all
```

The frontend will be available at http://localhost:3000

## Features

This is a stoplight simulator.

### Controls:
- Start
- Stop
- Manual Tick
- Reset

- Action for Pedestrian Crossing

### Available Modes
- Normal
- Emergency (AKA Ambulance/Fire Department)
- Maintenance

## License

MIT License - Educational use

## Credits

Created for educational purposes as a school project.
