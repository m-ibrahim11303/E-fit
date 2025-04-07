import express from "express";
import { addDish } from "../controllers/dish.js";

export const dishRouter = express.Router();

dishRouter.post("/add", addDish);


// localhost:8000/user/get
