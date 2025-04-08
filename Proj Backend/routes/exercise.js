import express from "express";
import { addExercise, addUserExercise, getAllForUser, getAllExercises } from "../controllers/exercise.js";

export const exerciseRouter = express.Router();

exerciseRouter.post("/addnew", addExercise);
exerciseRouter.get("/all", getAllExercises);
exerciseRouter.post("/addUserExercise", addUserExercise);
exerciseRouter.post("/getall", getAllForUser);

// localhost:8000/user/get
