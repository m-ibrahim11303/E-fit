import express from "express";

import { saveMeals , getDietHistory, logWater, saveExercises, getWorkoutHistory, getStreaks} from "../controllers/user.js";
import { createUser, loginUser, changePassword, deleteUser } from "../controllers/auth.js";



export const userRouter = express.Router();

userRouter.post("/create", createUser);
userRouter.post("/change-password", changePassword);
userRouter.post("/delete", deleteUser);
userRouter.get("/login", loginUser);

userRouter.post("/savemeals", saveMeals)
userRouter.post("/logwater", logWater)

userRouter.get("/diethistory", getDietHistory)
userRouter.get("/workouthistory", getWorkoutHistory)
userRouter.get("/streaks", getStreaks)

userRouter.post("/saveexercises", saveExercises)