import mongoose from "mongoose";

const userAIPlan = new mongoose.Schema({
  userEmail: {
    type: String,
    required: true,
    index: true
  },
  plan: {
    diet: [
      {
        name: { type: String, required: true },
        calories: { type: Number, required: true },
        proteins: { type: Number, required: true }
      }
    ],
    exercises: [
      {
        name: { type: String, required: true },
        time: Number,
        reps: Number,
        sets: Number,
        weight: Number,
        calories_burned: { type: Number, required: true }
      }
    ]
  },
  timestamp: {
    type: Date,
    default: Date.now,
    required: true
  }
});

export const UserPlan = mongoose.model("userAIPlan", userAIPlan);
