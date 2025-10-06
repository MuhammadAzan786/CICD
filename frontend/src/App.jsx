import { useState } from 'react'
import './App.css'

function App() {
  const [healthData, setHealthData] = useState(null)
  const [users, setUsers] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  // Use the same hostname as frontend, but port 5000 for backend
  // This makes it work from any device (localhost, LAN IP, etc.)
  const API_URL = import.meta.env.VITE_API_URL || `http://${window.location.hostname}:5000`

  const checkHealth = async () => {
    setLoading(true)
    setError(null)
    try {
      const response = await fetch(`${API_URL}/api/health`)
      const data = await response.json()
      setHealthData(data)
      setUsers(null)
    } catch (err) {
      setError('Failed to connect to backend')
    } finally {
      setLoading(false)
    }
  }

  const getUsers = async () => {
    setLoading(true)
    setError(null)
    try {
      const response = await fetch(`${API_URL}/api/users`)
      const data = await response.json()
      setUsers(data)
      setHealthData(null)
    } catch (err) {
      setError('Failed to fetch users')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app">
      <h1>Frontend Connected! </h1>
      <h2>Testing the pipeline !!!</h2>
      <div className="button-container">
        <button onClick={checkHealth} disabled={loading}>
          Check Backend Health
        </button>
        <button onClick={getUsers} disabled={loading}>
          Get Users
        </button>
      </div>

      {loading && <p className="loading">Loading...</p>}
      {error && <p className="error">{error}</p>}

      {healthData && (
        <div className="response">
          <h2>Backend Health:</h2>
          <pre>{JSON.stringify(healthData, null, 2)}</pre>
        </div>
      )}

      {users && (
        <div className="response">
          <h2>Users:</h2>
          <ul>
            {users.map(user => (
              <li key={user.id}>{user.name} (ID: {user.id})</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}

export default App
