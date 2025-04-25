import express from "express";
import cors from "cors";
import { userRouter } from "./routes/user.js";
import { dishRouter } from "./routes/dish.js";
import { exerciseRouter } from "./routes/exercise.js";
import { aiRouter } from "./routes/ai.js";
import { commentRouter } from "./routes/comment.js"
import { postRouter } from "./routes/post.js"
import { analyticsRouter } from "./routes/analytics.js"
import { forgetPasswordRouter } from "./routes/forgetPassword.js"

export const app = express();

app.use(cors());
app.use(express.json());

app.use("/user", userRouter);
app.use("/forget-password", forgetPasswordRouter)
app.use("/dish", dishRouter);
app.use("/exercise", exerciseRouter);
app.use("/ai", aiRouter);
 
app.use("/post", postRouter);
app.use("/comment", commentRouter);
app.use("/analytics", analyticsRouter);
