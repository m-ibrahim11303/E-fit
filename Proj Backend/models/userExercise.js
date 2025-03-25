import mongoose from "mongoose";

const userExerciseSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    exerciseId: { type: mongoose.Schema.Types.ObjectId, ref: "Exercises", required: true },
    timeStamp: { type: Date, required: true },
    sets_reps: [{ type: Number, required: true }] // [number of reps in each set OR number of seconds in each set]
});

// module.exports = mongoose.model("UserExercise", userExerciseSchema);
export const UserExercise = mongoose.model("UserExercise", userExerciseSchema);

// exercise id
// Sets [] 
// TimeStamp