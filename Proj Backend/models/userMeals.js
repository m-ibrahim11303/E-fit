// import mongoose from "mongoose";

// const userMealsSchema = new mongoose.Schema({
//     userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
//     dishId: { type: mongoose.Schema.Types.ObjectId, ref: "FoodDish", required: true },
//     timestamp: { type: Date, required: true }
// });

// module.exports = mongoose.model("UserMeals", userMealsSchema);
import mongoose from "mongoose";

const mealEntrySchema = new mongoose.Schema({
    name: { type: String, required: true },
    calories: { type: Number, required: true },
    protein: { type: Number, required: true }
  });
  
  const userMealsSchema = new mongoose.Schema({
    userEmail: { type: String, required: true, index: true },
    meals: [{
      data: mealEntrySchema,
      addedAt: { type: Date, default: Date.now }
    }]
  }, { timestamps: true });

export default mongoose.model("UserMeals", userMealsSchema);