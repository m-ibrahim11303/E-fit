import { User } from "../models/user.js";

export const createUser = async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      email,
      password,
      gender,
      dateOfBirth,
      height,
      weight
    } = req.body;

    if (!firstName || !email || !password || !gender || !dateOfBirth || !height || !weight) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log("Email already in use:", email);
      return res.status(400).json({ error: "Email already in use" });
    }

    const newUser = await User.create({
      firstName,
      lastName: lastName || "",
      email,
      password,
      gender,
      dateOfBirth,
      height: Number(height),
      weight: Number(weight)
    });

    console.log("User created:", newUser);
    return res.status(201).json({ message: "User created", email: newUser.email });

  } catch (err) {
    console.error("Error creating user:", err.message);
    return res.status(500).json({ error: err.message });
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

// Save Meal

