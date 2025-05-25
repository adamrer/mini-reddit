-- Author: Adam Øeøicha

/* 

Mini Reddit databáze
--------------------

Jako téma na zápoètovou databázovou aplikaci mì napadlo vytvoøit zjednodušenou 
databázi sociální sítì Reddit. V ní uivatelé mohou bıt souèástí komunit, do 
kterıch mohou zveøejnit pøíspìvky, k pøíspìvkùm pøidat komentáø, oznaèit 
pøíspìvek/komentáø, e se jim líbí/nelíbí, nebo jim pøidat cenu, pokud se jim 
obzvláš líbí.




*/



-- table of users
create table users (
    id numeric(32)
        constraint users_pk primary key,
    username varchar2(64 char) not null
        constraint users_username_uq
            unique,
    email varchar2(128 char) not null
        constraint users_email_uq
            unique,
    created_at timestamp default systimestamp
);

-- table of communities
create table communities (
    id numeric(32)
        constraint communities_pk primary key,
    name varchar2(64 char) not null
        constraint communities_name_uq
            unique,
    description varchar2(1024 char),
    created_at timestamp default systimestamp
);

-- table of posts
create table posts (
    id numeric(32)
        constraint posts_pk primary key,
    author_id numeric(32)
        constraint posts_fk_author
            references users(id)
            on delete set null,
    community_id numeric(16) not null
        constraint posts_fk_community
            references communities(id)
            on delete cascade,
    title varchar2(255 char) not null,
    text clob,
    image_path varchar2(255 char),
    created_at timestamp default systimestamp
);

-- table of comments
create table comments (
    id numeric(32)
        constraint comments_pk primary key,
    author_id numeric(32)
        constraint comments_fk_author
            references users(id)
            on delete set null,
    parent_comment_id numeric(32)
        constraint comments_fk_parent
            references comments(id)
            on delete set null,
    post_id numeric(32) not null
        constraint comments_fk_post
            references posts(id)
            on delete cascade,
    text clob not null
);

-- table of awards that can be given to comments or posts
create table awards (
    id numeric(16)
        constraint award_pk primary key,
    name varchar2(64 char) not null,
    icon_path varchar2(255 char) not null
);

-- table of votes to posts
create table post_votes (
    post_id numeric(32) 
        constraint post_votes_fk_post
            references posts(id)
            on delete cascade,
    user_id numeric(32)
        constraint post_votes_fk_user
            references users(id)
            on delete set null,
    vote_value numeric(1)
        constraint check_post_votes_value check (vote_value in (1, -1)),
    created_at timestamp default systimestamp,
    constraint post_votes_pk
        primary key(post_id, user_id)
);

-- table of votes to comments
create table comment_votes (
    comment_id numeric(32)
        constraint comment_votes_fk_comment
            references comments(id)
            on delete cascade,
    user_id numeric(32)
        constraint comment_votes_fk_user
            references users(id)
            on delete set null,
    vote_value numeric(1)
        constraint check_comment_votes_value check (vote_value in (1, -1)),
    created_at timestamp default systimestamp,
    constraint comment_votes_pk
        primary key(comment_id, user_id)
);

-- table of awards given to posts by users
create table post_awards (
    post_id numeric(32) not null
        constraint post_awards_fk_post
            references posts(id)
            on delete cascade,
    award_id numeric(16) not null
        constraint post_awards_fk_award
            references awards(id)
            on delete cascade,
    user_id numeric(32)
        constraint post_awards_fk_user
            references users(id)
            on delete set null,
    created_at timestamp default systimestamp,
    constraint post_awards_pk
        primary key(post_id, award_id)
);

-- table of awards given to comments by users
create table comment_awards (
    comment_id numeric(32)
        constraint comment_awards_fk_comment
            references comments(id)
            on delete cascade,
    award_id numeric(16)
        constraint comment_awards_fk_award
            references awards(id)
            on delete cascade,
    user_id numeric(32)
        constraint comment_awards_fk_user
            references users(id)
            on delete set null,
    created_at timestamp default systimestamp,
    constraint comment_awards_pk
        primary key(comment_id, award_id)
);

-- table of community members
create table community_members (
    user_id numeric(32)
        constraint community_members_fk_user
            references users(id)
            on delete cascade,
    community_id numeric(32)
        constraint community_members_fk_community
            references communities(id)
            on delete cascade,
    created_at timestamp default systimestamp
);
