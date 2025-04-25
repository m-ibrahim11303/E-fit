import mongoose from "mongoose";

const eateriesSchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true },
    numOfDishes: { type: Number, required: true },
    dishes: [{ type: mongoose.Schema.Types.ObjectId, ref: "FoodDish" }]
});

module.exports = mongoose.model("Eateries", eateriesSchema);
