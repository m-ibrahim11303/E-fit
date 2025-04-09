import express from "express";
import { addExercise, getAllExercises } from "../controllers/exercise.js";

export const exerciseRouter = express.Router();

exerciseRouter.post("/addnew", addExercise);
exerciseRouter.get("/all", getAllExercises);
