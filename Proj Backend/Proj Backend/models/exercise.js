import mongoose from "mongoose";

const exerciseSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: { type: String, required: true },
    usesMachine: { type: Boolean, required: true },
    type: { type: String, required: true } // reps/timer
});

// module.exports = mongoose.model("Exercises", exerciseSchema);

export const Exercise = mongoose.model("Exercise", exerciseSchema);
