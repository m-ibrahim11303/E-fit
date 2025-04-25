import mongoose from "mongoose";

const steps = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    startTime: { type: Date, required: true },
    endTime: { type: Date, required: true },
    distance: { type: Number, required: true } 
});

module.exports = mongoose.model("Steps", steps);
