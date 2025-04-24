import { Comment } from '../models/comments.js';
import { Post } from '../models/posts.js';
import { User } from '../models/user.js';

export const createComment = async (req, res) => {
  try {
    const { email, content, postId } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const comment = new Comment({ postId, commenterEmail: email, content });
    await comment.save();

    await Post.findByIdAndUpdate(postId, { $push: { comments: comment._id } });

    res.status(201).json(comment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


export const getCommentsForPost = async (req, res) => {
  try {
    const { postId } = req.params;
    const comments = await Comment.find({ postId: postId }).sort({ createdAt: -1 });

    const commentsWithUsernames = await Promise.all(
      comments.map(async (comment) => {
        const user = await User.findOne({ email: comment.commenterEmail });
        return {
          ...comment.toObject(),
          commenterFirstName: user ? user.firstName : "Unknown"
        };
      })
    );

    res.status(200).json(commentsWithUsernames);
  } catch (error) {
    console.error("Error fetching comments:", error);
    res.status(500).json({ message: "Error fetching comments", error });
  }
};


export const likeComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    await Comment.findByIdAndUpdate(commentId, { $inc: { likes: 1 } });
    res.status(200).json({ message: 'Comment liked' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const dislikeComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    await Comment.findByIdAndUpdate(commentId, { $inc: { dislikes: 1 } });
    res.status(200).json({ message: 'Comment disliked' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
