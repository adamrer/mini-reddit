-- Author: Adam Øeøicha

-- show posts that were created earlier than an hour ago
create or replace view view_hot_posts as
    select 
        p.title, 
        p.text,
        p.image_path,
        comments_package.comments_count(p.id) as comments,
        post_votes_package.get_post_vote_value(p.id) as votes,
        post_awards_package.awards_count(p.id) as awards,
        u.username as author,
        p.created_at
    from posts p
    join users u on p.author_id = u.id
    where p.created_at >= systimestamp - interval '1' day
    order by votes desc;
    

-- show comments hierarchically ordered and siblings ordered by vote value
create or replace view view_threaded_comments as
    select 
        c.post_id,
        level as reply_depth,
        c.id,
        c.parent_comment_id,
        c.text,
        comment_votes_package.get_comment_vote_value(c.id) as votes
    from comments c
    start with c.parent_comment_id is null
    connect by prior c.id = c.parent_comment_id
    order siblings by votes desc;


-- show users ordered by the vote value on their posts
create or replace view view_most_likeable_users as
    select
        u.username,
        sum(post_votes_package.get_post_vote_value(p.id)) as total_votes
    from users u    
    join posts p on p.author_id = u.id
    group by u.username
    order by total_votes desc;



-- show users ordered by the count of received awards on their posts
create or replace view view_most_awarded_users as
    select
        u.username,
        sum(post_awards_package.awards_count(p.id)) as total_awards
    from users u
    join posts p on u.id = p.author_id
    group by u.username
    order by total_awards desc;
    
    