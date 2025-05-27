-- Show Alice's relevant posts
select * from view_relevant_posts where viewer = 'alice';

-- It is different for Charlie, because he is only a member of the sports community
select * from view_relevant_posts where viewer = 'charlie';

-- Comment on the post from linux community as Alice
exec comments_package.add_comment('alice', null, 3, 'Am not sure, never tried it.');

-- Like the post
exec post_votes_package.like_post(3, 'alice');

-- Show comments of the post from linux community 
-- We can see the new comment from alice
select * from view_threaded_comments where post_id = 3;

-- Dislike the comment as John
exec comment_votes_package.dislike_comment(4, 'john');

-- Reply to the comment as John
exec comments_package.add_comment('john', 4, 3, 'Thats a shame.');

-- Create new award
exec awards_package.add_award('Bronze Star', 'https://cdn-icons-png.flaticon.com/512/11166/11166467.png');

-- Award the new comment with Gold Star and Bronze Star
exec comment_awards_package.award_comment(5, 3, 'alice');
exec comment_awards_package.award_comment(5, 1, 'charlie')

-- View the awards given to the comment
select * from view_comment_awards where id = 5;

-- Edit a comment
exec comments_package.update_comment(4, 'Am not sure, never tried it. I use different distro.');

-- See the reply and edited comment
select * from view_threaded_comments where post_id = 3;

-- Disliking the comment again doesn't change anything (intended behaviour)
exec comment_votes_package.dislike_comment(4, 'john');
select * from view_threaded_comments where post_id = 3;

-- Liking the comment changes the vote
exec comment_votes_package.like_comment(4, 'john');
select * from view_threaded_comments where post_id = 3;


-- Add Alice to non-existing community
-- Ends with error 'Community with name "gaming" does not exits.'
exec community_members_package.add_member('alice', 'gaming');

-- Create a new community
exec communities_package.add_community('gaming', 'Place for video game enthusiasts.');

-- Show all communities with number of their members
select * from view_communities;

-- Add Alice to the new community
exec community_members_package.add_member('alice', 'gaming');

-- List all linux community members
select * from view_community_members where name = 'linux';

-- Remove John from the linux community
exec community_members_package.remove_member('john', 'linux');

-- List users ordered by the total vote value of their posts
select * from view_most_likeable_users;


select * from view_communities;





