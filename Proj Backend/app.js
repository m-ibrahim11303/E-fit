import express from "express";
import cors from "cors";
import { userRouter } from "./routes/user.js";
import { dishRouter } from "./routes/dish.js";
import { exerciseRouter } from "./routes/exercise.js";
import {commentRouter} from "./routes/comment.js"
import {postRouter} from "./routes/post.js"


export const app = express();

app.use(cors());
app.use(express.json());

app.use("/user", userRouter);
app.use("/dish", dishRouter);
app.use("/exercise", exerciseRouter);
app.use("/post", postRouter);
app.use("/comment", commentRouter);

