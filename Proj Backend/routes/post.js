import express from 'express';

import {
    createPost,
    getAllPosts,
    likePost,
    dislikePost
} from '../controllers/post.js';

export const postRouter = express.Router();

// Post routes
postRouter.post('/', createPost);
postRouter.get('/', getAllPosts);
postRouter.post('/:postId/like', likePost);
postRouter.post('/:postId/dislike', dislikePost);
