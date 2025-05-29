-- Author: Adam �e�icha


-- POSTS
create index idx_posts_author_id on posts(author_id);
create index idx_posts_community_id on posts(community_id);
create index idx_posts_created_at on posts(created_at);

-- COMMENTS
create index idx_comments_post_id on comments(post_id);
create index idx_comments_author_id on comments(author_id);
create index idx_comments_created_at on comments(created_at);

-- COMMUNITY MEMBERS
create index idx_community_members_community_id on community_members(community_id);
create index idx_community_members_user_id on community_members(user_id);

