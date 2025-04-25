import express from "express";

import { sendForgotPasswordOTP, verifyForgotPasswordOTP, resetForgotPassword} from "../controllers/forgetPassword.js";

export const forgetPasswordRouter = express.Router();

forgetPasswordRouter.post("/send-code", sendForgotPasswordOTP);
forgetPasswordRouter.post("/verify-code", verifyForgotPasswordOTP);
forgetPasswordRouter.post("/reset", resetForgotPassword);