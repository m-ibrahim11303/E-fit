import express from "express";
import { getGeminiPlan } from "../controllers/ai.js";

export const aiRouter = express.Router();

aiRouter.post("/generate", getGeminiPlan);
