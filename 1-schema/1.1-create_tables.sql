-- Author: Adam Řeřicha

/* 

Mini Reddit databáze
--------------------

Jako téma na zápočtovou databázovou aplikaci mě napadlo vytvořit zjednodušenou databázi sociální sítě Reddit.
V níž uživatelé mohou být součástí komunit, do kterých mohou zveřejnit příspěvky, k příspěvkům přidat komentář,
označit příspěvek/komentář, že se jim líbí/nelíbí, nebo jim přidat cenu, pokud se jim obzvlášť líbí.

Tabulky:
•	users: tabulka uživatelů
•	communities: tabulka komunit
•	community_members: tabulka přiřazující uživatele komunitám, do kterých se přidali
•	posts: tabulka příspěvků s odkazem na autora (uživatele)
•	comments: tabulka komentářů s odkazem na autora (uživatele)
•	awards: tabulka dostupných cen, které mohou být přiděleny příspěvkům nebo komentářům
•	post_awards: tabulka s odkazy na uživatele, cenu a příspěvek. Říká jakou cenu jaký uživatel dal jakému příspěvku.
•	comment_awards: tabulka s odkazy na uživatele, cenu a příspěvek. Říká jakou cenu jaký uživatel dal jakému komentáři.
•	post_votes: tabulka pro zaznamenání toho, kdo označil příspěvek, že se mu (ne)líbí
•	comment_votes: tabulka pro zaznamenání toho, kdo označil komentář, že se mu (ne)líbí

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
    created_at timestamp default systimestamp,
    updated_at timestamp
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
    text clob not null,
    created_at timestamp default systimestamp,
    updated_at timestamp
);

-- table of awards that can be given to comments or posts
create table awards (
    id numeric(16)
        constraint award_pk primary key,
    name varchar2(64 char) not null
        constraint award_uq unique,
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
