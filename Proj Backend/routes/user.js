import express from "express";
import { createUser, loginUser } from "../controllers/user.js";

export const userRouter = express.Router();

userRouter.post("/create", createUser);
userRouter.post("/login", loginUser);

// localhost:8000/user/get
