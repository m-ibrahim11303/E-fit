import mongoose from "mongoose";

const stepSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    startTime: { type: Date, required: true },
    endTime: { type: Date, required: true },
    distance: { type: Number, required: true } 
});

module.exports = mongoose.model("Steps", stepSchema);
