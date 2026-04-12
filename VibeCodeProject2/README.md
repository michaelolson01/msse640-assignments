# TestCraft Academy

An educational game for learning decision tables and pairwise testing techniques.

## Project Structure

```
testcraft-academy/
├── backend/              # Common Lisp backend
│   ├── src/
│   │   ├── main.lisp
│   │   ├── database.lisp
│   │   ├── auth.lisp
│   │   ├── routes.lisp
│   │   ├── utils.lisp
│   │   ├── models/
│   │   └── validators/
│   ├── data/            # SQLite database
│   └── testcraft.asd    # ASDF system definition
│
└── frontend/            # Vue.js frontend
    ├── src/
    │   ├── components/
    │   ├── views/
    │   ├── services/
    │   ├── router/
    │   └── store/
    └── package.json
```

## Prerequisites

### Backend
- SBCL (Steel Bank Common Lisp)
- Quicklisp
- SQLite3

### Frontend
- Node.js (v14 or higher)
- npm or yarn

## Installation

### Backend Setup

1. Install SBCL:
```bash
# On Debian/Ubuntu
sudo apt-get install sbcl

# On macOS
brew install sbcl
```

2. Install Quicklisp:
```bash
curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --load quicklisp.lisp
```

In the SBCL REPL:
```lisp
(quicklisp-quickstart:install)
(ql:add-to-init-file)
```

3. Install required libraries:
```lisp
(ql:quickload '(:hunchentoot :cl-json :sqlite :ironclad :cl-ppcre :alexandria))
```

4. Start the backend:
```bash
cd backend
sbcl --load testcraft.asd
```

In the SBCL REPL:
```lisp
(ql:quickload :testcraft)
(testcraft:start-server :port 8080)
```

### Frontend Setup

1. Install dependencies:
```bash
cd frontend
npm install
```

2. Start the development server:
```bash
npm run serve
```

The frontend will be available at http://localhost:8081

## Usage

1. Start the backend server (port 8080)
2. Start the frontend development server (port 8081)
3. Open your browser to http://localhost:8081
4. Register a new account or login
5. Select a level and start learning!

## Features

- **Chapter 1: Decision Tables**
  - Learn to create comprehensive decision tables
  - Handle complex business rules
  - Practice with real-world scenarios

- **Chapter 2: Pairwise Testing**
  - Master efficient test design
  - Understand combinatorial testing
  - Minimize test cases while maximizing coverage

- **Scoring System**
  - Completeness: 0-100 points
  - Efficiency: 0-50 points
  - Accuracy: 0-20 points
  - Total: 0-170 points

- **Leaderboard**
  - Compete with other players
  - Track your progress
  - Achieve high scores

## Development

### Adding New Levels

Edit `backend/src/database.lisp` and add new levels to the `insert-sample-levels` function.

### Modifying Validators

Edit the validator files in `backend/src/validators/` to change scoring logic.

### Customizing UI

Edit the Vue components in `frontend/src/components/` and `frontend/src/views/`.

## License

MIT License - Educational use

## Credits

Created for educational purposes as a school project.
