import mongoose from 'mongoose';

const post = new mongoose.Schema({
  userEmail: { type: String, required: true, ref: 'User' },
  content: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  likes: { type: Number, default: 0 },
  dislikes: { type: Number, default: 0 },
  comments: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Comment' }]
});

export const Post = mongoose.model('Post', post);
