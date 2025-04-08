import { Exercise } from "../models/exercise.js";
import { UserExercise } from "../models/userExercise.js";
import { User } from "../models/user.js";
// Add exercise to DB

export const addExercise = async (req, res) => {
  try {
    const { name, description, usesMachine, type } = req.body;
    console.log("Request body: ", req.body)
    if (!name || !description || usesMachine === undefined || !type) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const check = await Exercise.findOne({ name: name });
    if (check) {
      console.log("Exercise ", name, " already exists")
      return res.status(400).json({ error: "Exercise already exists" });
    }

    const exercise = await Exercise.create({ name, description, usesMachine, type });
    console.log("New exercise added: ", exercise)
    return res.status(201).json({ message: "Exercise created", exercise });

  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};


// Get all exercises stored in the DB
export const getAllExercises = async (req, res) => {
  try {
    const exercises = await Exercise.find();

    // Formatting for frontend
    const formattedExercises = exercises.map(ex => ({
      name: ex.name,
      machineUse: ex.usesMachine,
      timer: ex.type === "timer"
    }));

    const response = {
      numberOfExercises: formattedExercises.length,
      exercises: formattedExercises
    };

    return res.status(200).json(response);

  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};


// Add exercise to user records
export const addUserExercise = async (req, res) => {
  try {
    const { email, exerciseId, sets_reps } = req.body;
    console.log("Add user exercise: ", req.body)

    if (!email || !exerciseId || !sets_reps || !Array.isArray(sets_reps) || sets_reps.length === 0) {
      return res.status(400).json({ error: "All fields are required, and sets_reps must be a non-empty array" });
    }

    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if the exercise exists
    const exercise = await Exercise.findById(exerciseId);
    if (!exercise) {
      return res.status(404).json({ error: "Exercise not found" });
    }

    // Create a new UserExercise entry
    const userExercise = new UserExercise({
      userId: user._id,
      exerciseId,
      timeStamp: new Date(),
      sets_reps
    });

    // Save the exercise log entry
    const savedExercise = await userExercise.save();

    // Add the exercise log ID to the user's exerciseLog array
    user.exerciseLog.push(savedExercise._id);
    await user.save();

    return res.status(201).json({ message: "Exercise recorded successfully", userExercise: savedExercise });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// get all exercises for a user
export const getAllForUser = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Fetch all UserExercise entries for the user
    const userExercises = await UserExercise.find({ userId: user._id }).select("-userId -__v");

    const exercisesWithDetails = await Promise.all(
      userExercises.map(async (entry) => {
        const exercise = await Exercise.findById(entry.exerciseId).select("-_id name description usesMachine type");
        return { ...entry.toObject(), exerciseId: exercise };
      })
    );

    return res.status(200).json({ exercises: exercisesWithDetails });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

