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


