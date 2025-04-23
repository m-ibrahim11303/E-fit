import mongoose from "mongoose";

const foodDish = new mongoose.Schema({
    name: { type: String, required: true },
    description: { type: String, required: true },
    eatery: { type: String, required: true },
    calories: { type: Number, required: true },
    proteins: { type: Number, required: true },
    day_of_week: { type: String, required: false }  
});

export const FoodDish = mongoose.model("FoodDish", foodDish);
