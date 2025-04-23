import { FoodDish } from "../models/foodDish.js";

// Add new dish to DB
export const addDish = async (req, res) => {
  try {
    const { name, description, eatery, calories, proteins, day_of_week } = req.body;
    
    if (!name || !description || !eatery || calories == undefined || proteins == undefined || day_of_week == undefined) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const dish = await FoodDish.create({ name, description, eatery, calories, proteins, day_of_week });

    return res.status(201).json({ dish });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

export const getAllDishes = async (req, res) => {
  try {
    const today = new Date().toLocaleDateString("en-US", { weekday: "long" }).toLowerCase();
    console.log(`Getting Dishes for ${today}`)

    // Find dishes for today or everyday
    const dishes = await FoodDish.find({
      $or: [
        { day_of_week: { $regex: new RegExp(`\\b${today}\\b`, "i") } },
        { day_of_week: { $regex: /everyday/i } },
        { day_of_week: { $exists: false } }  // Optional: include legacy dishes without a day
      ]
    });

    if (!dishes.length) {
      return res.status(404).json({ error: "No dishes found" });
    }

    const eateriesMap = new Map();

    dishes.forEach(dish => {
      if (!eateriesMap.has(dish.eatery)) {
        eateriesMap.set(dish.eatery, []);
      }
      eateriesMap.get(dish.eatery).push({
        name: dish.name,
        calories: dish.calories,
        protein: dish.proteins,
        description: dish.description
      });
    });

    const eateries = Array.from(eateriesMap.entries()).map(([eateryName, dishes]) => ({
      name: eateryName,
      "number of dishes": dishes.length,
      dishes
    }));

    const responseData = {
      "number of eateries": eateries.length,
      eateries
    };

    return res.status(200).json(responseData);

  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};
