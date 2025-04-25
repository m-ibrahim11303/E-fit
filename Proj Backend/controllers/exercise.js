import { Exercise } from "../models/exercise.js";

// Populate DB
export const addExercise = async (req, res) => {
  try {
    const { name, description, usesMachine, type } = req.body;
    if (!name || !description || usesMachine === undefined || !type) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const check = await Exercise.findOne({ name: name });
    if (check) {
      return res.status(400).json({ error: "Exercise already exists" });
    }

    const exercise = await Exercise.create({ name, description, usesMachine, type });
    return res.status(201).json({ message: "Exercise created", exercise });

  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};


export const getAllExercises = async ( _, res) => {
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


