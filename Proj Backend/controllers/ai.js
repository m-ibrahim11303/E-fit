import { GoogleGenerativeAI } from "@google/generative-ai";
import { FoodDish } from "../models/foodDish.js";
import { Exercise } from "../models/exercise.js";
import { UserPlan  } from "../models/ai.js";
import { UserBMR } from "../models/bmr_tdee.js";
import { startOfDay, endOfDay } from 'date-fns';

// import dotenv from 'dotenv';
// dotenv.config();


// const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const genAI = new GoogleGenerativeAI("AIzaSyCkFUbEpYFl7pfkHbLs9JhTQNEW0n-Olgk");

export const getExercisesForAI = async () => {
  const exercises = await Exercise.find().select('name -_id');
  return exercises.map(e => e.name);
};

export const getPdcDishesForAI = async () => {
  const today = new Date().toLocaleDateString("en-US", { weekday: "long" }).toLowerCase();
  const dishes = await FoodDish.find({
    eatery: 'PDC',
    $or: [
      { day_of_week: { $regex: new RegExp(`\\b${today}\\b`, "i") } },
      { day_of_week: { $regex: /everyday/i } },
      { day_of_week: { $exists: false } }
    ]
  }).select('name calories proteins -_id'); 
  return { dishes };
};

export const getGeminiResponse = async (messages) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" }); 
    const result = await model.generateContent(messages);
    const response = await result.response;
    return response.text();
  } catch (err) {
    console.error("Error getting Gemini response:", err);
    return "Something went wrong with Gemini.";
  }
};

export const getGeminiPlan = async (req, res) => {
    try {
     

        const { email, BMR, TDEE, caloriesToEat, caloriesToBurn } = req.body;

        await UserBMR.deleteOne({ userEmail: email });

        await UserBMR.create({
            userEmail: email,
            bmr: BMR,
            tdee: TDEE
        });

        const existingPlan = await UserPlan.findOne({
          userEmail: email,
          timestamp: {
            $gte: startOfDay(new Date()),
            $lte: endOfDay(new Date())
          }
        });
        
        if (existingPlan) {
          const sanitizedPlan = {
            diet: existingPlan.plan.diet.map(({ name, calories, proteins }) => ({
              name,
              calories,
              proteins
            })),
            exercises: existingPlan.plan.exercises.map(({ name, time, reps, sets, weight, calories_burned }) => ({
              name,
              ...(time !== undefined && { time }),
              ...(reps !== undefined && { reps }),
              ...(sets !== undefined && { sets }),
              ...(weight !== undefined && { weight }),
              calories_burned
            }))
          };
        
          return res.json({ plan: sanitizedPlan });
        }
        
        const { dishes } = await getPdcDishesForAI();
    
        const dishDescriptions = dishes.map(d =>
            `Dish: ${d.name}, Calories: ${d.calories}, Protein: ${d.proteins}g`
        ).join("\n");
        
        const exercises = await getExercisesForAI();
        const exercisesList = exercises.join(", ");

        const geminiPrompt = `
            You are given a target calorie count to consume: ${caloriesToEat}.  
            Below is a list of available dishes, each with its calorie and protein content:  
            ${dishDescriptions}

            Your task is to select a combination of dishes that this person should eat, ensuring the total calories are as close as possible to the target.

            Diet Rules:
            - Roti must be included in the meal (add a max of 2 Rotis). If roti is excluded, then at least one rice dish must be included.
            - Avoid strange or incompatible food combinations.

            You are also given a target calorie count to burn: ${caloriesToBurn}.  
            You have a list of available exercises: ${exercisesList}.  
            Use them to create an exercise plan that helps burn calories as close to the target as possible.

            Exercise Rules:
            - For exercises that only require time (in seconds), return:  
            { "name": ..., "time": ..., "calories_burned": ... }
            - For exercises requiring only reps and sets, return:  
            { "name": ..., "reps": ..., "sets": ..., "calories_burned": ... }

            Return only a JSON object in the following format:

            {
            "diet": [
                { "name": ..., "calories": ..., "proteins": ... },
                ...
            ],
            "exercises": [
                { "name": ..., ... },
                ...
            ]
            }
            Do not include any explanation or additional text—only return the JSON response. Make sure this is a good recommendation!
            `;
    
        const summary = await getGeminiResponse(geminiPrompt);
        const cleanJSON = summary.replace(/```json\s*|\s*```/g, '');
        const plan = JSON.parse(cleanJSON);
        await UserPlan.create({
        userEmail: email,
        plan
        });
    
        res.json({ plan });
  
    } catch (error) {
      console.error("Error in getGeminiPlan:", error);
      res.status(500).json({ error: "Failed to generate  plan" });
    }
};
