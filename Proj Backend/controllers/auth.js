import { User } from "../models/user.js";

// SignUp user
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

    return res.status(201).json({ message: "User created", email: newUser.email });

  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};


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

    return res.status(200).json({
      message: "Login successful",
      sessionCookie: user.email
    });
  } catch (error) {
    return res.status(500).json({ error: error.message, sessionCookie: null });
  }
};

export const changePassword = async (req, res) => {
  try {
    const { email, currentPassword, newPassword } = req.body;

    if (!email || !currentPassword || !newPassword) {
      return res.status(400).json({ error: "Email, current password, and new password are required" });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (user.password !== currentPassword) {
      return res.status(401).json({ error: "Incorrect current password" });
    }

    user.password = newPassword;
    await user.save();

    return res.status(200).json({ message: "Password changed successfully" });
  } catch (error) {
    return res.status(500).json({ error: "Server error" });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (user.password !== password) {
      return res.status(401).json({ error: "Incorrect password" });
    }

    // Delete user and associated data
    await Promise.all([
      User.deleteOne({ email }),
      UserMeals.deleteMany({ userEmail: email }),
      waterLog.deleteMany({ email }),
      UserExercise.deleteMany({ userEmail: email }),
    ]);

    return res.status(200).json({ message: "User and all associated data deleted successfully" });

  } catch (error) {
    return res.status(500).json({ error: "Server error" });
  }
};

