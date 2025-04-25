import mongoose from "mongoose";

const userBmrTdee = new mongoose.Schema({
  userEmail: {
    type: String,
    required: true,
    index: true
  },
  bmr: {
    type: Number,
    required: true
  },
  tdee: {
    type: Number,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now,
    required: true
  }
});

export const UserBMR = mongoose.model("userBMR", userBmrTdee);
