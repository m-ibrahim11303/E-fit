import { User } from "../models/user.js";
import { UserMeals } from "../models/userMeals.js";
export const createUser = async (req, res) => {
  try {
    console.log(req.body)
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

    console.log("User created:", newUser.firstName);
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
    console.log(req.query)
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
    console.log("User logged in: ", email)
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
export const saveMeals = async (req, res) => {
  try {
      const { email, items } = req.body;

      // Basic validation
      if (!email || !items || !Array.isArray(items) || items.length === 0) {
          return res.status(400).json({
              success: false,
              message: 'Email and items array are required'
          });
      }
      const users = await User.find({ email: email });

      if (users.length === 0) {
        return res.status(404).json({ error: "User not found" });
      }

      // Prepare meals data for bulk insert
      const mealsToSave = items.map(item => ({
          userEmail: email,
          name: item.name,
          calories: item.calories,
          protein: item.protein,
          // timestamp will be automatically added
      }));

      // Insert all meals in one operation
      const savedMeals = await UserMeals.insertMany(mealsToSave);

      // Calculate totals
      const totals = {
          calories: items.reduce((sum, item) => sum + item.calories, 0),
          protein: items.reduce((sum, item) => sum + item.protein, 0)
      };

      return res.status(201).json({
          success: true,
          message: 'Meals saved successfully',
          data: {
              count: savedMeals.length,
              totals,
              meals: savedMeals.map(meal => ({
                  id: meal._id,
                  name: meal.name,
                  calories: meal.calories,
                  protein: meal.protein,
                  timestamp: meal.timestamp
              }))
          }
      });

  } catch (error) {
      console.error('Error saving meals:', error);
      return res.status(500).json({
          success: false,
          message: 'Failed to save meals',
          error: error.message
      });
  }
};