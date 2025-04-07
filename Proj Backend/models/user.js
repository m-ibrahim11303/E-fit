import mongoose from "mongoose";

// const userSchema = new mongoose.Schema({
//   name: {
//     type: String,
//     required: true,
//   },
//   username: {
//     type: String,
//     required: true,
//   },
//   age: {
//     type: Number,
//     required: true,
//   },
// });

// export const User = mongoose.model("User", userSchema);


const userSchema = new mongoose.Schema({
  name: {
    type: String, required: true
  },
  email: {
    type: String, required: true, unique: true
  },
  password: {
    type: String, required: true
  },
  gender: {
    type: String, required: true
  },
  age: {
    type: Number,
    required: true,
  },
  height: {   // in cm
    type: Number,
    required: true,
  },
  weight: {   // in kg
    type: Number,
    required: true,
  },
  stepsLog: [{
    type: mongoose.Schema.Types.ObjectId, ref: "Steps"
  }],
  exerciseLog: [{
    type: mongoose.Schema.Types.ObjectId, ref: "UserExercise"
  }],
  meals: [{
    type: mongoose.Schema.Types.ObjectId, ref: "UserMeals"
  }]
});

export const User = mongoose.model("User", userSchema);
