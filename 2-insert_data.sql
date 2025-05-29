-- Author: Adam Řeřicha


begin
    -- USERS
    users_package.add_user('alice', 'alice@example.com');
    users_package.add_user('bob', 'bob@example.com');
    users_package.add_user('charlie', 'charlie@example.com');
    users_package.add_user('john', 'john@example.com');

    -- COMMUNITIES
    communities_package.add_community('programming', 'A place to discuss PL/SQL and code.');
    communities_package.add_community('sports', 'All about sports and fitness.');
    communities_package.add_community('linux', 'For everyone interested in Linux');

    -- MEMBERSHIPS
    community_members_package.add_member('alice', 'programming');
    community_members_package.add_member('alice', 'linux');
    community_members_package.add_member('bob', 'programming');
    community_members_package.add_member('charlie', 'sports');
    community_members_package.add_member('alice', 'sports');
    community_members_package.add_member('john', 'linux');

    -- AWARDS
    awards_package.add_award('Gold Star', 'https://cdn-icons-png.flaticon.com/512/5406/5406792.png');
    awards_package.add_award('Silver Star', 'https://cdn-icons-png.flaticon.com/512/17155/17155284.png');

    -- POSTS
    posts_package.add_post('alice', 'programming', 'How to start with PL/SQL?', 'Any tips for beginners?', null);
    posts_package.add_post('bob', 'sports', 'Who will win the Champions League?', 'Let�s hear your predictions!', 'https://cdn.pixabay.com/photo/2018/06/12/13/55/trophy-3470654_1280.jpg');
    posts_package.add_post('john', 'linux', 'Is Arch Linux the best distro?', 'I am using Arch btw', null);

    -- COMMENTS
    comments_package.add_comment('bob', null, 1, 'Start with the Oracle documentation.');
    comments_package.add_comment('charlie', null, 2, 'Real Madrid, no doubt.');
    comments_package.add_comment('alice', 1, 1, 'Thanks! I will check it out.');

    -- POST VOTES
    post_votes_package.like_post(1, 'bob');
    post_votes_package.dislike_post(2, 'alice');
    post_votes_package.like_post(3, 'john');
    post_votes_package.like_post(1, 'john');

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
