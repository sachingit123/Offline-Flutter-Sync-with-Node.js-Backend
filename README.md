# Offline Storage and Background Sync App

This project demonstrates a complete offline-first solution using Flutter for the frontend and Node.js for the backend. It includes offline storage, background synchronization, and real-time syncing when the internet is available.

---

## Features

1. **Offline Storage**:
   - The app uses `sqflite` to store data locally when the internet is unavailable.
   - Users can add, update, or delete records offline, which are synced to the server when the internet is available.

2. **Background Synchronization**:
   - The app performs background synchronization using the `flutter_background_service` package.
   - Syncing occurs automatically when the internet is connected.

3. **Frontend**:
   - Built using Flutter, supporting offline functionality uisng `flutter_background_service` and providing a clean user interface.

4. **Backend**:
   - A lightweight REST API built with Node.js and Express.
   - Stores synced data in a MySQL database.

---

## Installation

### Prerequisites
- Flutter installed (for frontend development).
- Node.js and npm installed (for backend development).
- MySQL database.

---

### Frontend Setup

1. Navigate to the `offline_storage` directory:
   ```bash
   cd offline_storage
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

### Backend Setup

1. Navigate to the `offline-backend` directory:
   ```bash
   cd offline-backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure the database:
   - Update the `server.js` file with your MySQL credentials.

4. Start the backend server:
   ```bash
   node server.js
   ```

---

## Key Packages

### Frontend (Flutter)
| Package                     | Description                                       |
|-----------------------------|---------------------------------------------------|
| `sqflite`                   | For local database storage.                       |
| `http`                      | For making REST                        |
| `connectivity_plus`         | For detecting internet connectivity.              |
| `flutter_background_service`| For running background tasks.                     |

### Backend (Node.js)
| Package        | Description                              |
|----------------|------------------------------------------|
| `express`      | For building REST APIs.                  |
| `body-parser`  | For parsing incoming JSON requests.      |
| `mysql2`       | For connecting to the MySQL database.    |

---

## How It Works

### Offline Storage
- The app stores user data locally in the SQLite database using `sqflite`.
- When the internet is available, unsynced data is automatically pushed to the backend.

### Background Sync
- Uses `flutter_background_service` to keep the app running in the background.
- Listens for internet connectivity using `connectivity_plus` and triggers sync only when connected.

### Backend API
- The Node.js backend provides endpoints for managing user data:
  - `GET /users`: Fetch all users.
  - `POST /users`: Add a new user.
  - `PUT /users/:id`: Update a user.
  - `DELETE /users/:id`: Delete a user.

---

## Directory Structure

### Frontend (`offline_storage`)
```
offline_storage/
├── lib/
│   ├── main.dart        # Entry point of the app
│   ├── home_screen.dart # Home screen UI and logic
│   ├── add_user_screen.dart # Add user functionality
│   └── db_helper.dart   # Local database operations
├── pubspec.yaml         # Flutter dependencies
```

### Backend (`offline-backend`)
```
offline-backend/
├── server.js            # Main backend server file
├── job.js               # Handles background tasks
├── package.json         # Node.js dependencies
```

---

## Contributions

Feel free to fork this repository and submit pull requests for any enhancements or bug fixes.

---

## Contact

For any issues or questions, feel free to reach out:
- GitHub: [[Sachin Kumar Bharti GitHub Profile]](https://github.com/sachingit123)
