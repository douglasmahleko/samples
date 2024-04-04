import { useState, useEffect } from 'react';
import { useAuth } from "./AppContext";

function App() {
  const { backendActor, login, logout, isAuthenticated, identity } = useAuth();
  const [users, setUsers] = useState([]);
  const [saving , setSaving] = useState(false);
  // const [principal, setPrincipal] = useState("");

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [age, setAge] = useState(0);
  
  const submit = async (e) => {
    e.preventDefault();
    if (backendActor) {
      try {
        setSaving(true);
        let user = {
          name: name,
          email: email,
          age: BigInt(age),
          accessLevel: { USER: null },
        };
        
        await backendActor.createUser(user);
        setName("");
        setEmail("");
        setAge(0);
        setSaving(false);
        getUsers();
      } catch (error) {
        console.log("Error adding user:", error);
        setSaving(false);
      }
    }
  };

  useEffect(() => {
    if (backendActor && isAuthenticated) {
      
      getUsers();
    }
  }, [isAuthenticated, backendActor]);

  const getUsers = async () => {
    try {

      const res = await backendActor?.getAllUsers();
      const principal = await backendActor?.whoami();
      if (res) {
        setUsers(res);
        console.log('users data ',res)
        console.log('users data ',users)
        console.log(principal)
      }
    } catch (error) {
      console.log("Error getting users:", error);
    }
  };
  

  return (
    <main >
      {isAuthenticated ? (
        <div >
          <img src="/logo2.svg" alt="DFINITY logo"  />
          <button
            
            onClick={logout}
          >
            Logout
          </button>
          <section id="greeting" >
            <h1 >Hi there!</h1>
            <p >Welcome to the users app</p>
          </section>

          <div >
            <form >
              <div>
                <label
                  htmlFor="name"
                  
                >
                  Name
                </label>
                <input
                  type="text"
                  name="name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  id="name"
                  
                  placeholder="Name"
                />
              </div>

              <div>
                <label
                  htmlFor="email"
                  
                >
                  Email
                </label>
                <input
                  type="email"
                  name="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  id="email"
                  
                  placeholder="you@example.com"
                />
              </div>

              <div>
                <label
                  htmlFor="age"
                  
                >
                  Age
                </label>
                <input
                  type="number"
                  name="age"
                  value={age}
                  onChange={(e) => setAge(parseInt(e.target.value))}
                  id="age"
                  
                  placeholder="30"
                />
              </div>

              <div >
                <button
                  type="submit"
                  onClick={submit}
                  disabled={saving}
                  
                >
                  {saving ? "Saving..." : "Save"}
                </button>
              </div>
            </form>
          </div>

          {users.length > 0 &&
            users.map((user, index) => (
              <div
                key={index}
                
              >
                <div >
                  <p >{user.email}</p>
                  <p >{user.age.toString()}</p>
                  <p >{user.name}</p>
                  <p >{new Date(parseInt(user.timestamp)).toUTCString()}</p>
                  
                </div>
              </div>
            ))}
        </div>
      ) : (
        <div >
          <button  onClick={login}>
            Login
          </button>
        </div>
      )}
    </main>
  );
}

export default App;
