import express from "express";
import { createUser, loginUser, saveMeals } from "../controllers/user.js";

export const userRouter = express.Router();

userRouter.post("/create", createUser);
userRouter.post("/login", loginUser);
userRouter.post("/savemeals", saveMeals)
// localhost:8000/user/get