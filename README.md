# Woven Monopoly Backend

This repository contains a Rails API for a deterministic Monopoly simulation. The game logic is intentionally server-driven, while a separate Vue frontend handles user interaction and presentation.

## Server URL

Set your hosted API URL here when ready:

- Backend base URL: `https://woven-monopoly-backend-332081046644.asia-southeast3.run.app`

- API base path: `https://woven-monopoly-backend-332081046644.asia-southeast3.run.app/api`

- Frontend game URL: `https://woven-monopoly-frontend-332081046644.asia-southeast3.run.app`

Deployment note:

- The backend is hosted on Google Cloud Platform (GCP) using Cloud Run.
- The service is configured for automatic deployment on `git push`.

## What the API does

- Creates a game session with player names and optional config overrides.
- Loads deterministic dice rolls from a selected rolls file.
- Advances the game one move at a time through a roll endpoint.
- Returns a complete updated snapshot after each move so clients stay stateless.

## Design decisions

### 1) Deterministic gameplay from file-based rolls

Dice input is selected by file name rather than raw sequence arrays. This keeps gameplay reproducible, avoids oversized request payloads, and allows frontend clients to present a controlled list of valid scenarios.

### 2) Clear API boundaries

The backend exposes a small command-style API:

- `GET /api/roll_files` to list valid roll files.
- `POST /api/games` to create a session.
- `POST /api/games/:id/moves/roll` to progress one turn.

This keeps controller code focused and pushes core logic into service objects.

There is intentionally no dedicated `GET /api/games/:id` endpoint for reading game state. Instead, state is created once and then advanced by roll commands, with each roll response returning the latest full snapshot.

This design is session-oriented: if the client refreshes or reloads and loses the in-memory session context, a new game is started. That tradeoff is intentional to reduce overall API surface area and avoid redundant polling/read calls.

Because this project is single-session and not multiplayer, reset-on-refresh does not create cross-player consistency issues.

### 3) Service-oriented game logic

Core gameplay concerns are separated into services (turn progression, tile handling, rent, bankruptcy) to make rule changes easier to reason about and test independently.

### 4) Full-state responses after each move

Each move response includes the updated game object. This simplifies frontend state management, especially in browser refresh and error-retry scenarios.

### 5) Validation-first configuration

Configuration values and roll file names are validated before game creation. Invalid options return 422 responses with clear error messages.

### 6) Dynamic board size and tile growth

Board size is not hardcoded in movement logic. The game computes position using the current board length at runtime, so movement automatically adapts to larger or smaller boards.

At load time, the board is built from `board.json`. The loader normalizes tile data and assembles a full perimeter board shape, which means new tiles can be added to the source file without rewriting core turn logic.

Corner slots are intentionally constrained to `GO` or `Free Parking` in the current shape builder. This keeps corner behavior predictable today and provides a clean extension point for introducing additional corner types later, such as `Jail`.

In practical terms, adding more tiles increases `board.length`, and all move calculations continue to work because turn progression is based on modulo arithmetic against that dynamic size.

### 7) Extensible tile behavior model

Tile actions are centralized in a single handler (`TileHandler`) that dispatches behavior by tile type. This keeps tile rules isolated and makes extensions straightforward.

To introduce new tile types such as railroads, utilities, or jail:

1. Add the type to board validation in `BoardLoader`.
2. Add a branch for the new type in `TileHandler.apply`.
3. Implement dedicated rule logic in a focused helper/service (for example rent variants, movement penalties, or skip-turn mechanics).
4. Add tests for loader validation and gameplay outcomes for the new tile type.

This approach avoids spreading tile-specific rules through controller or turn-engine code and keeps future rule additions maintainable.

## Backend setup and local run

Use the following flow on a fresh machine.

```bash
# 1) Install Ruby 3.4.x (skip if already installed)
# Check Ruby version
ruby -v

# 2) Install Bundler
gem install bundler

# Verify Bundler
bundle -v

# 3) Move into the backend project
cd your-repo-path

# 4) Install project gems
bundle install

# 5) Start the Rails server
bundle exec rails s
```

This project does not use a relational database for gameplay state. Game sessions are stored in memory by the service layer.

The API will be available at:

- `http://localhost:3000`

### Run tests

```bash
bundle exec rails test
```

## Basic usage flow

1. Frontend calls `GET /api/roll_files` and lets the user choose one entry.
2. Frontend creates game with `POST /api/games` and `config.roll_file`.
3. Frontend triggers turns with `POST /api/games/:id/moves/roll` until completion.

