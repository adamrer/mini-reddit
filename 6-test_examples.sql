-- Author: Adam Řeřicha



--  P O S T S

-- View posts
select * from view_posts;

-- Add a post
exec posts_package.add_post('alice', 'programming', 'When do you need to implement queues yourself?', 'I think that you are always able to use preimplemented one.', null);
exec posts_package.add_post('bob', 'programming', 'Should I use Linux?', 'I heard that it is better for programmers.', null)
select * from view_posts;

-- Update a post
exec posts_package.update_post(4, 'When do you need to implement queues yourself???', 'I think that you are always able to use preimplemented one.', 'https://media.geeksforgeeks.org/wp-content/cdn-uploads/20230726165642/Queue-Data-structure1.png');
select * from view_posts where post_id = 4;


-- Remove post without comments
exec posts_package.delete_post(4);
select * from view_posts;

-- Remove post with comments
exec posts_package.delete_post(2);
select * from view_posts;

-- Show communities where a user is a member
select * from view_community_members where username = 'alice';

-- Show posts that are from communities that the user (viewer) is part of
select * from view_relevant_posts where viewer = 'alice';


-- Like the post, add +1 to votes
exec post_votes_package.like_post(3, 'alice');
select * from view_posts where post_id = 3;

-- Dislike the post, change like to dislike -> votes decreased by 2
exec post_votes_package.dislike_post(3, 'alice');
select * from view_posts where post_id = 3;

-- Remove the vote, change dislike to nothing -> votes increased by 1
exec post_votes_package.delete_vote(3, 'alice');
select * from view_posts where post_id = 3;

-- Try to like non-existing post
-- Ends with error 'Post with id "12" does not exist.'
exec post_votes_package.like_post(12, 'alice');

-- Try to like as non-existing user
-- Ends with error 'User with username "adam" does not exist.'
exec post_votes_package.like_post(3, 'adam');

-- Award a post
exec post_awards_package.award_post(1, 2, 'alice');
select * from view_posts where post_id = 1;

-- View awards given to all posts
select * from view_post_awards;

commit;



--  C O M M E N T S


-- Comment on the post from linux community
exec comments_package.add_comment('alice', null, 3, 'Am not sure, never tried it.');
exec comments_package.add_comment('bob', null, 3, 'It takes a lot of your time.')
select * from view_threaded_comments where post_id = 3;

-- Dislike a comment
exec comment_votes_package.dislike_comment(4, 'john');
select * from view_threaded_comments where post_id = 3;

-- Like a comment
exec comment_votes_package.like_comment(4, 'john');
select * from view_threaded_comments where post_id = 3;

-- Remove a vote
exec comment_votes_package.delete_vote(4, 'john');
select * from view_threaded_comments where post_id = 3;

-- Reply to the comment 
exec comments_package.add_comment('john', 4, 3, 'Thats a shame.');
select * from view_threaded_comments where post_id = 3;

-- Edit a comment
exec comments_package.update_comment(4, 'Am not sure, never tried it. I use different distro.');
select * from view_threaded_comments where post_id = 3;

-- Award a comment
exec comment_awards_package.award_comment(5, 2, 'alice');
select * from view_threaded_comments where post_id = 3;

-- Add different award to the same comment as the same user
exec comment_awards_package.award_comment(5, 1, 'alice');
select * from view_threaded_comments where post_id = 3;

-- View the awards given to the comment
select * from view_comment_awards where id = 5;

-- View all given awards
select * from view_comment_awards;


commit;


--  U S E R S

-- Show all users
select * from users;

-- Try to add existing user
-- Ends with 'User "alice" already exists.'
exec users_package.add_user('alice', 'alice@example.com');

-- Create a user
exec users_package.add_user('adam', 'adam@example.com');
select * from users;

-- Delete a user without posts and comments
exec users_package.delete_user('adam');
select * from users;

-- Delete non-existing user
-- Ends with error 'User with username "adam" does not exist.'
exec users_package.delete_user('adam');

-- Show users with ordered by the count of earned awards
select * from view_most_awarded_users;

-- List users ordered by the total vote value of their posts
select * from view_most_likeable_users;


commit;

--  C O M M U N I T I E S

-- Show all communities
select * from view_communities;

-- Try to create already existing community
-- Ends with error 'Community "linux" already exists'
exec communities_package.add_community('linux', 'something something');

-- Add Alice to non-existing community
-- Ends with error 'Community with name "gaming" does not exist.'
exec community_members_package.add_member('alice', 'gaming');

-- Create a new community
exec communities_package.add_community('gaming', 'Place for video game enthusiasts.');

-- Show all communities with number of their members
select * from view_communities;

-- Add Alice to the new community
exec community_members_package.add_member('alice', 'gaming');

-- List all linux community members
select * from view_community_members where community = 'linux';

-- Remove John from the linux community
exec community_members_package.remove_member('john', 'linux');
select * from view_community_members where community = 'linux';


commit;


--  A W A R D S 

-- Show awards
select * from awards;

-- Create new award
exec awards_package.add_award('Bronze Star', 'https://cdn-icons-png.flaticon.com/512/11166/11166467.png');
select * from awards;

-- Delete award that wasn't given to anything
exec awards_package.delete_award(3);
select * from awards;

-- Delete award that was given to something
exec awards_package.delete_award(1);
select * from awards;


commit;