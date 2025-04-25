import mongoose from "mongoose";

const userExercises = new mongoose.Schema({
    userEmail: { 
        type: String,
        required: true,
        index: true
    },
    name: {
        type: String,
        required: true
    },
    timer: {
        type: Boolean,
        required: true
    },
    typeOfExercise: {
        type: String,
        required: true
    },
    sets: [{
        setNumber: {
            type: Number,
            required: true
        },
        value: {
            type: Number,
            required: true
        },
        type: {
            type: String,
            required: true
        },
        weight: {
            type: Number
        }
    }],
    timestamp: { 
        type: Date, 
        default: Date.now,
        required: true 
    }
});

export const UserExercise = mongoose.model("UserExercises", userExercises);