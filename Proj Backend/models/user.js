import mongoose from "mongoose";

const user = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName:  { type: String, required: false },
  email:     { type: String, required: true, unique: true },
  password:  { type: String, required: true },
  gender:    { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  height:    { type: Number, required: true }, // cm
  weight:    { type: Number, required: true }  // kg
});

export const User = mongoose.model("User", user);
