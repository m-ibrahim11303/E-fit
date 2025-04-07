import express from "express";
import { addExercise, addUserExercise, getAllForUser } from "../controllers/exercise.js";

export const exerciseRouter = express.Router();

exerciseRouter.post("/addnew", addExercise);
exerciseRouter.post("/addUserExercise", addUserExercise);
exerciseRouter.post("/getall", getAllForUser);

// localhost:8000/user/get
