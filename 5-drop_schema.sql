
-- drop views
drop view view_relevant_posts;
drop view view_threaded_comments;
drop view view_most_likeable_users;
drop view view_most_awarded_users;
drop view view_communities;


-- drop packages
drop package awards_package;
drop package comment_awards_package;
drop package comment_votes_package;
drop package comments_package;
drop package communities_package;
drop package community_members_package;
drop package post_awards_package;
drop package post_votes_package;
drop package posts_package;
drop package users_package;


-- drop sequences
drop sequence awards_id_seq;
drop sequence comments_id_seq;
drop sequence communities_id_seq;
drop sequence posts_id_seq;
drop sequence users_id_seq;

-- drop indeces
drop index idx_posts_author_id;
drop index idx_posts_community_id;
drop index idx_comments_post_id;
drop index idx_comments_author_id;
drop index idx_community_members_community_id;
drop index idx_community_members_user_id;

-- drop triggers
drop trigger trg_comment_cycle;
drop trigger trg_comment_empty;
drop trigger trg_comment_update_timestamp;
drop trigger trg_post_empty;
drop trigger trg_post_update_timestamp;

-- drop tables
drop table post_awards;
drop table comment_awards;
drop table post_votes;
drop table comment_votes;
drop table community_members;
drop table awards;
drop table comments;
drop table posts;
drop table communities;
drop table users;


