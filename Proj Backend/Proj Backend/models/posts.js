import mongoose from "mongoose";
const postsSchema = new mongoose.Schema({
    timestamp: { type: Date, default: Date.now },
    poster: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    title: { type: String, required: true },
    content: { type: String, required: true },
    upvotes: { type: Number, default: 0 },
    downvotes: { type: Number, default: 0 },
    comments: [{ type: mongoose.Schema.Types.ObjectId, ref: "Comments" }]
});

module.exports = mongoose.model("Posts", postsSchema);
