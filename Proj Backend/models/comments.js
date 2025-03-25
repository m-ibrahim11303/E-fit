import mongoose from "mongoose";

const commentsSchema = new mongoose.Schema({
    commenter: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    content: { type: String, required: true },
    upvotes: { type: Number, default: 0 },
    downvotes: { type: Number, default: 0 }
});

module.exports = mongoose.model("Comments", commentsSchema);
