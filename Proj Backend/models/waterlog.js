import mongoose from "mongoose";

const waterLogSchema = new mongoose.Schema(
    {
        amount: {
            type: Number,
            required: true,
        },
        email: {
            type: String,
            required: true,
        },
        timestamp: {
            type: Date,
            default: Date.now,
        },
    }
);

export const waterLog = mongoose.model("WaterLog", waterLogSchema);
