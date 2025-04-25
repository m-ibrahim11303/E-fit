import express from 'express';

import {
  createComment,
  getCommentsForPost,
  likeComment,
  dislikeComment
} from '../controllers/comments.js';

export const commentRouter = express.Router();

// Comment routes
commentRouter.post('/', createComment);
commentRouter.get('/:postId', getCommentsForPost);
commentRouter.post('/:commentId/like', likeComment);
commentRouter.post('/:commentId/dislike', dislikeComment);
