import express from "express";
import { addDish, getAllDishes } from "../controllers/dish.js";

export const dishRouter = express.Router();

dishRouter.post("/add", addDish);
dishRouter.get("/all", getAllDishes);

// localhost:8000/user/get
