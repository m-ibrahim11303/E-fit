import express from "express";
import { getDietAnalytics } from "../controllers/analytics.js";

export const analyticsRouter = express.Router();

analyticsRouter.get("/charts", getDietAnalytics);
