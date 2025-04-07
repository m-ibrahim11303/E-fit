import mongoose from "mongoose";

const foodDishSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: { type: String, required: true },
    eatery: { type: String, required: true }, 
    calories: { type: Number, required: true },
    proteins: { type: Number, required: true }
});

// module.exports = mongoose.model("FoodDish", foodDishSchema);
export const FoodDish = mongoose.model("FoodDish", foodDishSchema);