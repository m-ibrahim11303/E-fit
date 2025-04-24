import fs from "fs";
import csv from "csv-parser";
import axios from "axios";

const API_URL = "http://localhost:8000/dish/add";

const results = [];

fs.createReadStream("dishes.csv") 
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
                });

                console.log(`Added: ${dish.name} - ${response.status}`);
            } catch (error) {
                console.error(`Error adding ${dish.name}:`, error.response?.data || error.message);
            }
        }
    });
