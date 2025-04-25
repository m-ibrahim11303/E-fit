import mongoose from 'mongoose';

const comment = new mongoose.Schema({
  postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post', required: true },
  commenterEmail: { type: String, required: true, ref: 'User' },
  content: { type: String, required: true },
  likes: { type: Number, default: 0 },
  dislikes: { type: Number, default: 0 },
  timestamp: { type: Date, default: Date.now }
});

export const Comment = mongoose.model('Comment', comment);
