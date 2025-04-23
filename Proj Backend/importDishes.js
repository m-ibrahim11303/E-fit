import fs from "fs";
import csv from "csv-parser";
import axios from "axios";

const API_URL = "http://localhost:8000/dish/add";

const results = [];

fs.createReadStream("F:/CS 360 - Software Engineering/E-fit/Proj Backend/Eateries Info/green_olive_dishes_days.csv") // or green_olive_dishes.csv
  .pipe(csv())
  .on("data", (row) => {
    results.push(row);
  })
  .on("end", async () => {
    for (const dish of results) {
      try {
        const response = await axios.post(API_URL, {
          name: dish.name,
          description: dish.description,
          eatery: dish.eatery,
          calories: parseInt(dish.calories, 10),
          proteins: parseInt(dish.proteins, 10),
          day_of_week: dish.day_of_week?.toLowerCase() || ""  // Add the new field safely
        });

        console.log(`Added: ${dish.name} - ${response.status}`);
      } catch (error) {
        console.error(`! Error adding ${dish.name}:`, error.response?.data || error.message);
      }
    }
  });
