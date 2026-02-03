import { useState, useEffect } from 'react';
import './App.css';

const API_URL = "https://three-tier-demo-backend.rishimajmudar.me";

function App() {
  const [users, setUsers] = useState([]);
  const [nameInput, setNameInput] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [editingName, setEditingName] = useState('');

  // Auto-load users on component mount
  useEffect(() => {
    loadUsers();
  }, []);

  async function loadUsers() {
    try {
      const response = await fetch(`${API_URL}/users`);
      if (!response.ok) {
        throw new Error('Failed to fetch users');
      }
      const data = await response.json();
      setUsers(data);
    } catch (error) {
      console.error('Error:', error);
      alert('Error loading users. Check console for details.');
    }
  }

  async function addUser() {
    const name = nameInput.trim();
    if (!name) {
      alert('Please enter a name');
      return;
    }

    try {
      const response = await fetch(`${API_URL}/add`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name })
      });

      if (!response.ok) {
        throw new Error('Failed to add user');
      }

      const newUser = await response.json();
      setUsers([...users, newUser]);
      setNameInput('');
    } catch (error) {
      console.error('Error:', error);
      alert('Error adding user. Check console for details.');
    }
  }

  async function updateUser(id) {
    const newName = editingName.trim();
    if (!newName) {
      alert('Name cannot be empty');
      return;
    }

    try {
      const response = await fetch(`${API_URL}/update/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: newName })
      });

      if (!response.ok) throw new Error('Failed to update user');

      setUsers(users.map(user =>
        user.id === id ? { ...user, name: newName } : user
      ));
      setEditingId(null);
      setEditingName('');
    } catch (error) {
      console.error('Error:', error);
      alert('Error updating user');
    }
  }

  async function deleteUser(id) {

    try {
      const response = await fetch(`${API_URL}/delete/${id}`, {
        method: 'DELETE'
      });

      if (!response.ok) throw new Error('Failed to delete user');

      setUsers(users.filter(user => user.id !== id));
    } catch (error) {
      console.error('Error:', error);
      alert('Error deleting user');
    }
  }

  function startEdit(user) {
    setEditingId(user.id);
    setEditingName(user.name);
  }

  function cancelEdit() {
    setEditingId(null);
    setEditingName('');
  }

  return (
    <div className="container">
      <h1>User Management</h1>

      <div className="input-group">
        <input
          type="text"
          value={nameInput}
          onChange={(e) => setNameInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addUser()}
          placeholder="Enter user name"
        />
        <button onClick={addUser}>Add User</button>
      </div>

      <div className="user-list">
        {users.length === 0 ? (
          <p style={{ textAlign: 'center', color: '#666', padding: '20px' }}>
            No users found. Add a user to get started!
          </p>
        ) : (
          users.map((user, index) => (
            <div key={user.id} className="user-item">
              {editingId === user.id ? (
                <>
                  <input
                    type="text"
                    value={editingName}
                    onChange={(e) => setEditingName(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && updateUser(user.id)}
                    style={{ flex: 1, padding: '8px', marginRight: '10px' }}
                    autoFocus
                  />
                  <div className="user-actions">
                    <button className="edit-btn" onClick={() => updateUser(user.id)}>
                      Save
                    </button>
                    <button className="delete-btn" onClick={cancelEdit}>
                      Cancel
                    </button>
                  </div>
                </>
              ) : (
                <>
                  <span>
                    <span className="user-id">#{index + 1}</span> {user.name}
                  </span>
                  <div className="user-actions">
                    <button className="edit-btn" onClick={() => startEdit(user)}>
                      Edit
                    </button>
                    <button className="delete-btn" onClick={() => deleteUser(user.id)}>
                      Delete
                    </button>
                  </div>
                </>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;
