import { FoodDish } from "../models/foodDish.js";

export const addDish = async (req, res) => {
  try {
    const { name, description, eatery, calories, proteins } = req.body;

    if (!name || !description || !eatery || !calories || !proteins) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const dish = await FoodDish.create({ name, description, eatery, calories, proteins });
    console.log(`Added dish: ${name}`)
    return res.status(201).json({ dish });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};
