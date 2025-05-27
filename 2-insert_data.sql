-- Author: Adam Øeøicha


begin
    -- USERS
    users_package.add_user('alice', 'alice@example.com');
    users_package.add_user('bob', 'bob@example.com');
    users_package.add_user('charlie', 'charlie@example.com');

    -- COMMUNITIES
    communities_package.add_community('programming', 'A place to discuss PL/SQL and code.');
    communities_package.add_community('sports', 'All about sports and fitness.');

    -- MEMBERSHIPS
    community_members_package.add_member('alice', 'programming');
    community_members_package.add_member('bob', 'programming');
    community_members_package.add_member('charlie', 'sports');
    community_members_package.add_member('alice', 'sports');

    -- AWARDS
    awards_package.add_award('Gold Star', '/icons/gold.png');
    awards_package.add_award('Silver Star', '/icons/silver.png');

    -- POSTS
    posts_package.add_post('alice', 'programming', 'How to start with PL/SQL?', 'Any tips for beginners?', null);
    posts_package.add_post('bob', 'sports', 'Who will win the Champions League?', 'Let’s hear your predictions!', null);

    -- COMMENTS
    comments_package.add_comment('bob', null, 1, 'Start with the Oracle documentation.');
    comments_package.add_comment('charlie', null, 2, 'Real Madrid, no doubt.');
    comments_package.add_comment('alice', 1, 1, 'Thanks! I will check it out.');

    -- POST VOTES
    post_votes_package.like_post(1, 'bob');
    post_votes_package.dislike_post(2, 'alice');

    -- COMMENT VOTES
    comment_votes_package.like_comment(1, 'alice');
    comment_votes_package.dislike_comment(2, 'bob');

    -- POST AWARDS
    post_awards_package.award_post(1, 1, 'charlie'); -- Gold Star to post 1 by charlie
    post_awards_package.award_post(2, 2, 'alice');   -- Silver Star to post 2 by alice

    -- COMMENT AWARDS
    comment_awards_package.award_comment(1, 2, 'charlie'); -- Silver Star to comment 1

end;
/


commit;