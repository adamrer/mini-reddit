-- Author: Adam Øeøicha

-- show posts that were created earlier than a day ago ordered by vote values descending
create or replace view view_hot_posts as
    select 
        p.id as post_id,
        p.title, 
        p.text,
        p.image_path,
        comments_package.comments_count(p.id) as comments,
        post_votes_package.get_post_vote_value(p.id) as votes,
        post_awards_package.awards_count(p.id) as awards,
        u.username as author,
        c.name as community,
        p.created_at as posted_at
    from posts p
    join users u on p.author_id = u.id
    join communities c on p.community_id = c.id
    where p.created_at >= systimestamp - interval '1' day
    order by votes desc;
    

-- show posts that are from communities where the user is part of the community
create or replace view view_relevant_posts as
    select
        member_user.username as viewer,
        c.name as community_name,
        p.id as post_id,
        p.title,
        p.text,
        comments_package.comments_count(p.id) as comments,
        post_votes_package.get_post_vote_value(p.id) as votes,
        post_awards_package.awards_count(p.id) as awards,
        post_user.username as author,
        p.created_at as posted_at
        
    from users member_user
    join community_members cm on cm.user_id = member_user.id
    join communities c on cm.community_id = c.id
    join posts p on p.community_id = c.id
    join users post_user on p.author_id = post_user.id;

-- show comments hierarchically ordered and siblings ordered by vote value
create or replace view view_threaded_comments as
    select 
        c.post_id,
        level as reply_depth,
        c.id as comment_id,
        c.parent_comment_id,
        u.username as author,
        c.text,
        comment_votes_package.get_comment_vote_value(c.id) as votes,
        comment_awards_package.awards_count(c.id) as awards
    from comments c
    join users u on c.author_id = u.id
    start with c.parent_comment_id is null
    connect by prior c.id = c.parent_comment_id
    order siblings by votes desc;

-- show awards given to a comment
create or replace view view_comment_awards as
    select
        c.id,
        c.text,
        author_u.username as author,
        a.name as award,
        a.icon_path as award_image,
        awarder_u.username as awarded_by,
        ca.created_at as awarded_at
    from comments c
    join comment_awards ca on ca.comment_id = c.id
    join users awarder_u on ca.user_id = awarder_u.id
    join users  author_u on c.author_id = author_u.id
    join awards a on ca.award_id = a.id;
    


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
    

-- show list of communities and the number of members    
create or replace view view_communities as
    select
        c.name,
        c.description,
        community_members_package.members_count(c.name) as members
    from communities c;
    

-- show list of community members 
create or replace view view_community_members as
    select 
        c.name,
        u.username,
        cm.created_at as joined_at
    from community_members cm
    join users u on cm.user_id = u.id
    join communities c on cm.community_id = c.id
    order by c.name, joined_at desc;

 
    