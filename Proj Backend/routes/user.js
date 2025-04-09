import express from "express";
import { createUser, loginUser, saveMeals , getDietHistory} from "../controllers/user.js";

export const userRouter = express.Router();

userRouter.post("/create", createUser);
userRouter.post("/login", loginUser);
userRouter.post("/savemeals", saveMeals)
userRouter.get("/diethistory", getDietHistory)

// localhost:8000/user/get