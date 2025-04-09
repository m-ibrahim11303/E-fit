import { User } from "../models/user.js";

export const createUser = async (req, res) => {
  try {
    const { name, email, password, gender, age, height, weight } = req.body;

    if (!name || !email || !password || !gender || !age || !height || !weight) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const check = await User.findOne({ email: email });
    if (check) {
        console.log("Email ", email, " already in use")
        return res.status(400).json({ error: "Email already in use" });
    }

    const user = await User.create({ name, email, password, gender, age, height, weight, stepsLog:[], exerciseLog:[], meals:[] });
    console.log("User created: ", user)
    return res.status(201).json({ message: "User created", user });

  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// Login
// email password
export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.query; 

    if (!email || !password) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const users = await User.find({ email: email });

    if (users.length === 0) {
      return res.status(404).json({ error: "User not found", sessionCookie: null });
    }

    const user = users[0]; // email is unique

    if (user.password !== password) {
      return res.status(401).json({ error: "Incorrect password", sessionCookie: null });
    }

    // For simplicity, we are returning email as sessionCookie
    return res.status(200).json({ 
      message: "Login successful", 
      sessionCookie: user.email 
    });
  } catch (error) {
    return res.status(500).json({ error: error.message, sessionCookie: null });
  }
};

// email verification (later)


