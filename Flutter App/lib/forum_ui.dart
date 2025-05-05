part of 'forum_screen.dart';

extension ForumUi on _ForumScreenState {
  Widget _buildBody() {
    if (_isLoadingEmail ||
        (_isLoadingPosts && _posts.isEmpty && _postsError == null)) {
      return Center(child: CircularProgressIndicator(color: darkMaroon));
    }

    if (_postsError != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_postsError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: errorRed)),
      ));
    }
    if (!_isLoadingEmail && _currentUserEmail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              "Could not retrieve user information. Please try logging in again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: errorRed)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPosts(showLoading: false),
      child: _buildPostList(context),
    );
  }

  Widget _buildPostList(BuildContext context) {
    bool canPost = _currentUserEmail != null;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create New Post',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextField(
                    controller: _postContentController,
                    enabled: canPost,
                    decoration: InputDecoration(
                      hintText: canPost
                          ? 'Share your thoughts...'
                          : 'Loading user info...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: canPost
                          ? Colors.grey[100]
                          : Colors.grey[200],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: canPost ? () => _createPost(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkMaroon,
                        foregroundColor: brightWhite,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Post'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final postIndex = index - 1;
        if (postIndex < 0 || postIndex >= _posts.length)
          return SizedBox.shrink();

        final post = _posts[postIndex];
        final String userFirstName = post['userFirstName'] as String? ?? 'User';
        final String content = post['content'] as String? ?? 'No content';
        final String timestamp =
            post['timestamp'] as String? ?? DateTime.now().toIso8601String();
        final int likes = post['likes'] as int? ?? 0;
        final int dislikes = post['dislikes'] as int? ?? 0;
        final List<dynamic> commentMeta =
            (post['comments'] is List) ? post['comments'] : [];
        final String postId = post['_id'] as String? ?? '';

        if (postId.isEmpty) return SizedBox.shrink();

        final bool isExpanded = _expandedPostId == postId;
        final bool isLoadingComments = _loadingComments[postId] == true;
        final List<dynamic>? currentComments = _fetchedComments[postId];

        return Card(
          key: ValueKey(postId),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: darkMaroon,
                        child: Text(
                            userFirstName.isNotEmpty
                                ? userFirstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: brightWhite,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userFirstName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text(formatTime(timestamp),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ]),
                  ],
                ),
                SizedBox(height: 12),
                Text(content, style: TextStyle(fontSize: 15, height: 1.4)),
                SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInteractionButton(
                          icon: Icons.thumb_up_outlined,
                          count: likes,
                          onTap: () => _handlePostLike(postId)),
                      _buildInteractionButton(
                          icon: Icons.thumb_down_outlined,
                          count: dislikes,
                          onTap: () => _handlePostDislike(postId)),
                      _buildInteractionButton(
                          icon: isExpanded
                              ? Icons.mode_comment
                              : Icons.mode_comment_outlined,
                          count: currentComments?.length ?? commentMeta.length,
                          onTap: () => _toggleComments(postId),
                          isLoading: isLoadingComments &&
                              currentComments ==
                                  null
                          ),
                    ]),
                if (isExpanded)
                  _buildCommentsSection(
                      postId, currentComments, isLoadingComments),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection(
      String postId, List<dynamic>? comments, bool isLoading) {
    bool canComment = _currentUserEmail != null;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        SizedBox(height: 12),
        Text("Comments",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade700)),
        SizedBox(height: 8),

        if (isLoading && comments == null)
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )),

        if (!isLoading &&
            comments == null &&
            _fetchedComments.containsKey(postId))
          Center(
              child: Text("Could not load comments.",
                  style: TextStyle(color: errorRed))),

        if (comments != null && comments.isEmpty)
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("No comments yet.",
                style: TextStyle(color: Colors.grey.shade600)),
          )),

        if (comments != null && comments.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) =>
                _buildCommentItem(comments[index], postId),
            separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 42,
                endIndent: 10,
                color: Colors.grey.shade200),
          ),

        SizedBox(height: 12),
        _buildCommentInputField(postId, canComment),
      ]),
    );
  }

  Widget _buildCommentItem(dynamic comment, String postId) {
    final String userFirstName = comment['commenterFirstName'] as String? ?? 'User';
    final String content = comment['content'] as String? ?? '...';
    final String timestamp =
        comment['timestamp'] as String? ?? DateTime.now().toIso8601String();
    final String commentId = comment['_id'] as String? ?? '';
    final int likes = comment['likes'] as int? ?? 0;
    final int dislikes = comment['dislikes'] as int? ?? 0;

    if (commentId.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                radius: 16,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                    userFirstName.isNotEmpty
                        ? userFirstName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: darkMaroon,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        children: [
                      Text(userFirstName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 8),
                      Text(formatTime(timestamp),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11)),
                    ]),
                    SizedBox(height: 4),
                    Text(content,
                        style: TextStyle(fontSize: 14, color: darkMaroon)),
                  ]),
            ),
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 42.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            _buildInteractionButton(
                icon: Icons.thumb_up_outlined,
                count: likes,
                onTap: () => _handleCommentLike(commentId, postId),
                iconSize: 16,
                countSize: 12),
            SizedBox(width: 16),
            _buildInteractionButton(
                icon: Icons.thumb_down_outlined,
                count: dislikes,
                onTap: () => _handleCommentDislike(commentId, postId),
                iconSize: 16,
                countSize: 12),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCommentInputField(String postId, bool canComment) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentContentController,
            enabled: canComment,
            decoration: InputDecoration(
              hintText: canComment
                  ? "Add a comment..."
                  : "Loading user info...",
              isDense: true,
              filled: true,
              fillColor: canComment
                  ? Colors.grey.shade100
                  : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (!canComment || _isPostingComment)
                ? null
                : (_) => _postComment(postId),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: _isPostingComment
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2))
              : Icon(Icons.send, color: darkMaroon),
          onPressed: (!canComment || _isPostingComment)
              ? null
              : () => _postComment(postId),
          tooltip: 'Post Comment',
        ),
      ],
    );
  }

  Widget _buildInteractionButton(
      {required IconData icon,
      required int count,
      required VoidCallback onTap,
      bool isLoading = false,
      double iconSize = 20,
      double countSize = 14}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(icon, size: iconSize, color: Colors.grey.shade700),
              SizedBox(width: 4),
              Text(count.toString(),
                  style: TextStyle(
                      fontSize: countSize,
                      color: isLoading
                          ? Colors.grey.shade400
                          : Colors.grey.shade800
                      )),
            ],
          ),
        ),
      ),
    );
  }
}