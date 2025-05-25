-- Autor: Adam Øeøicha

-- tabulka uživatelù
create table users (
    id numeric(32)
        constraint users_pk primary key,
    username varchar2(64 char) not null,
    created_at timestamp default systimestamp
);

-- tabulka komunit
create table communities (
    id numeric(32)
        constraint communities_pk primary key,
    name varchar2(64 char) not null,
    created_at timestamp default systimestamp
);

-- tabulka pøíspìvkù
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

-- tabulka komentáøù
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

-- tabulka ocenìní
create table awards (
    id numeric(16)
        constraint award_pk primary key,
    name varchar2(64 char) not null,
    icon_path varchar2(255 char) not null
);

-- hlasy u pøíspìvkù
create table post_vote (
    post_id numeric(32) 
        constraint post_vote_fk_post
            references posts(id)
            on delete cascade,
    user_id numeric(32)
        constraint post_vote_fk_user
            references users(id)
            on delete set null,
    vote_value numeric(1)
        constraint check_post_vote_value check (vote_value in (1, -1)),
    created_at timestamp default systimestamp,
    constraint post_vote_pk
        primary key(post_id, user_id)
);

-- hlasy u komentáøù
create table comment_vote (
    comment_id numeric(32)
        constraint comment_votes_fk_comment
            references comments(id)
            on delete cascade,
    user_id numeric(32)
        constraint comment_votes_fk_user
            references users(id)
            on delete set null,
    vote_value numeric(1)
        constraint check_comment_vote_value check (vote_value in (1, -1)),
    created_at timestamp default systimestamp,
    constraint comment_votes_pk
        primary key(comment_id, user_id)
);

-- ocenìní u pøíspìvkù
create table post_award (
    post_id numeric(32)
        constraint post_award_fk_post
            references posts(id)
            on delete cascade,
    award_id numeric(16)
        constraint post_award_fk_award
            references awards(id)
            on delete cascade,
    created_at timestamp default systimestamp,
    constraint post_awards_pk
        primary key(post_id, award_id)
);

-- ocenìní u komentáøù
create table comment_award (
    comment_id numeric(32)
        constraint comment_award_fk_comment
            references comments(id)
            on delete cascade,
    award_id numeric(16)
        constraint comment_award_fk_award
            references awards(id)
            on delete cascade,
    created_at timestamp default systimestamp,
    constraint comment_award_pk
        primary key(comment_id, award_id)
);

-- èlenové komunit
create table user_community (
    user_id numeric(32)
        constraint user_community_fk_user
            references users(id)
            on delete cascade,
    community_id numeric(32)
        constraint user_community_fk_community
            references communities(id)
            on delete cascade,
    created_at timestamp default systimestamp
);
