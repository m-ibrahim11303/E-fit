import express from "express";
import { createUser, loginUser, saveMeals , getDietHistory, logWater, saveExercises} from "../controllers/user.js";

export const userRouter = express.Router();

userRouter.post("/create", createUser);
userRouter.get("/login", loginUser);
userRouter.post("/savemeals", saveMeals)
userRouter.post("/logwater", logWater)
userRouter.get("/diethistory", getDietHistory)
userRouter.post("/saveexercises", saveExercises)
// localhost:8000/user/get