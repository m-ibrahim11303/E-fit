import mongoose from "mongoose";

const userMealsSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    dishId: { type: mongoose.Schema.Types.ObjectId, ref: "FoodDish", required: true },
    timestamp: { type: Date, required: true }
});

module.exports = mongoose.model("UserMeals", userMealsSchema);
