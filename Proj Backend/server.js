import { app } from "./app.js";
import { config } from "dotenv";
import { connect } from "./utils/db.js";

config({
  path: "./config.env",
});

app.listen(8000, () => {
  console.log("Server is running on port 8000");
});

connect();
// Task app
