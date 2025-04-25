import mongoose from "mongoose";

const userMeals = new mongoose.Schema({
    userEmail: { 
        type: String,
        required: true,
        index: true
    },
    name: {
        type: String,
        required: true
    },
    calories: {
        type: Number,
        required: true
    },
    protein: {
        type: Number,
        required: true
    },
    timestamp: { 
        type: Date, 
        default: Date.now,
        required: true 
    }
});

export const UserMeals = mongoose.model("UserMeals", userMeals);