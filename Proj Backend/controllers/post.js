import { Post } from '../models/posts.js';
import { User } from '../models/user.js';

export const createPost = async (req, res) => {
  try {
    const { email, content } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const post = new Post({ userEmail: email, content });
    await post.save();

    res.status(201).json({ msg: "Post created", post });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const getAllPosts = async (req, res) => {
  try {
    const posts = await Post.find({}).sort({ createdAt: -1 });
    // console.log(posts)
    const postsWithNames = await Promise.all(posts.map(async (post) => {
      const user = await User.findOne({ email: post.userEmail }); 
      // console.log(user)
      return {
        ...post.toObject(),
        userFirstName: user ? user.firstName : "Unknown"
      };
    }));

    res.status(200).json(postsWithNames);
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch posts", error });
  }
};


export const likePost = async (req, res) => {
  try {
    const { postId } = req.params;
    await Post.findByIdAndUpdate(postId, { $inc: { likes: 1 } });
    res.status(200).json({ message: 'Post liked' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const dislikePost = async (req, res) => {
  try {
    const { postId } = req.params;
    await Post.findByIdAndUpdate(postId, { $inc: { dislikes: 1 } });
    res.status(200).json({ message: 'Post disliked' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
