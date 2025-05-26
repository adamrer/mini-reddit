-- Author: Adam Øeøicha


--  U S E R S

create or replace package users_package as

    -- adds a new user to the database
    procedure add_user(p_username users.username%type, p_email users.email%type);
    
    -- returns user's id by his username
    function user_id(p_username users.username%type) return users.id%type;
end users_package;
/



create sequence users_id_seq 
    start with 1 
    increment by 1
    nocycle;

create or replace package body users_package as

    procedure add_user(
        p_username users.username%type, 
        p_email users.email%type) as
    begin
        insert into users(id, username, email)
            values (users_id_seq.nextval,
            p_username,
            p_email);
    end;
    
    function user_id(p_username users.username%type) return users.id%type
    as
        retval users.id%type;
    begin
        select id 
            into retval 
            from users 
            where username = p_username;
        return retval;    
    end;
    
end users_package;
/


--  C O M M U N I T I E S

create or replace package communities_package as 

    -- adds a new community
    procedure add_community(
        p_name communities.name%type, 
        p_description communities.description%type
        );
        
    -- returns the id of a community with the given name
    function community_id(p_name communities.name%type) return communities.id%type;
        
end communities_package;
/

create sequence communities_id_seq 
    start with 1 
    increment by 1
    nocycle;
    
create or replace package body communities_package as

    procedure add_community(
        p_name communities.name%type, 
        p_description communities.description%type
        ) as
    begin
        insert into communities(id, name, description)
            values(communities_id_seq.nextval, p_name, p_description);
    end;
    
    function community_id(p_name communities.name%type) return communities.id%type
    as
        retval communities.id%type;
    begin
        select id 
            into retval 
            from communities
            where name = p_name;
        return retval;    
    end;
    
end communities_package;
/


--  A W A R D S

create or replace package awards_package as 

    -- adds new award
    procedure add_award(
        p_name awards.name%type, 
        p_icon_path awards.icon_path%type
        );
        
    function award_exists(p_award_id awards.id%type) return boolean;   
        
end awards_package;
/

create sequence awards_id_seq 
    start with 1 
    increment by 1
    nocycle;
    
create or replace package body awards_package as

    procedure add_award(
        p_name awards.name%type, 
        p_icon_path awards.icon_path%type
        ) as
    begin
        insert into awards(id, name, icon_path)
            values(awards_id_seq.nextval, p_name, p_icon_path);
    end;
        
    function award_exists(p_award_id awards.id%type) return boolean
    as
        v_dummy number;
    begin
        select 1 into v_dummy
            from awards
            where id = p_award_id;
        return true;
    exception
        when no_data_found then
            return false;
    end;
end awards_package;
/

--  C O M M E N T S

create or replace package comments_package as 

    -- adds a new comment with author username
    procedure add_comment(
        p_author_username users.username%type,
        p_parent_comment_id comments.parent_comment_id%type,
        p_post_id comments.post_id%type,
        p_text comments.text%type
        );
    
    -- checks if comment with given id exists
    function comment_exists(
        p_comment_id comments.id%type
        ) return boolean;
    
    -- return number of comments attached to a post
    function comments_count(
        p_post_id posts.id%type
        ) return number;
        
end comments_package;
/

create sequence comments_id_seq 
    start with 1 
    increment by 1
    nocycle;
    
create or replace package body comments_package as

    procedure add_comment(
        p_author_username users.username%type,
        p_parent_comment_id comments.parent_comment_id%type,
        p_post_id comments.post_id%type,
        p_text comments.text%type
        ) as
    begin
        if users_package.user_id(p_author_username) is null
        then
            raise_application_error(-20100,'User with username "'||p_author_username||'" does not exist.');
        end if;
        if not comments_package.comment_exists(p_parent_comment_id) then
            raise_application_error(-20101,'Comment with id "'||p_parent_comment_id||'" does not exist.');
        end if;    
        
        insert into comments(id, author_id, parent_comment_id, post_id, text)
            values(
                comments_id_seq.nextval, 
                users_package.user_id(p_author_username), 
                p_parent_comment_id, 
                p_post_id, 
                p_text);
    end;
    
    function comment_exists(p_comment_id comments.id%type) return boolean
    as
        v_dummy number;
    begin
        select 1 into v_dummy
            from comments
            where id = p_comment_id;
        return true;
    exception
        when no_data_found then
            return false;
    end;
    
    function comments_count(
        p_post_id posts.id%type
        ) return number
        as
            v_comments_count number;
        begin
            select count(*) into v_comments_count from comments where post_id=p_post_id;
            return v_comments_count;
        end;
        
end comments_package;
/

--  P O S T S

create or replace package posts_package as 

    -- adds post by author username and community name
    procedure add_post(
        p_author_username users.username%type,
        p_community_name communities.name%type,
        p_title posts.title%type,
        p_text posts.text%type,
        p_image_path posts.image_path%type
        );
    
    -- checks if post with given id exists
    function post_exists(p_post_id posts.id%type) return boolean;
    
    
end posts_package;
/

create sequence posts_id_seq 
    start with 1 
    increment by 1
    nocycle;
    
create or replace package body posts_package as

    procedure add_post(
        p_author_username users.username%type,
        p_community_name communities.name%type,
        p_title posts.title%type,
        p_text posts.text%type,
        p_image_path posts.image_path%type
        ) as
    begin
        if users_package.user_id(p_author_username) is null
        then
            raise_application_error(-20102,'User with username "'||p_author_username||'" does not exist.');
        end if;
        if communities_package.community_id(p_community_name) is null
        then
            raise_application_error(-20103,'Community with name "'||p_community_name||'" does not exist.');
        end if;    
        
        insert into posts(id, author_id, community_id, title, text, image_path)
            values(
                posts_id_seq.nextval, 
                users_package.user_id(p_author_username),
                communities_package.community_id(p_community_name), 
                p_title, 
                p_text,
                p_image_path);
    end;
    
    function post_exists(p_post_id posts.id%type) return boolean
    as
        v_dummy number;
    begin
        select 1 into v_dummy
            from posts
            where id = p_post_id;
        return true;
    exception
        when no_data_found then
            return false;
    end;
    
end posts_package;
/

--  C O M M E N T _ A W A R D S

create or replace package comment_awards_package as

    procedure add_comment_award(
        p_comment_id comments.id%type,
        p_award_id awards.id%type,
        p_user_username users.username%type
        );
        
    function awards_count(
        p_comment_id comments.id%type
        ) return number;
        
end comment_awards_package;
/
    
create or replace package body comment_awards_package as
    procedure add_comment_award(
        p_comment_id comments.id%type,
        p_award_id awards.id%type,
        p_user_username users.username%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if not comments_package.comment_exists(p_comment_id) then
                raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');
            end if; 
            if not awards_package.award_exists(p_award_id)
            then
                raise_application_error(-20103,'Award with id "'||p_award_id||'" does not exist.');
            end if;   
            insert into comment_awards(comment_id, award_id, user_id)
                values(p_comment_id, p_award_id, users_package.user_id(p_user_username));
        end;
        
    function awards_count(
        p_comment_id comments.id%type
        ) return number
        as
            v_awards_count number;
        begin
            select count(*) into v_awards_count from comment_awards where comment_id=p_comment_id;
            return v_awards_count;
        end;
        
end comment_awards_package;
/


--  P O S T _ A W A R D S

create or replace package post_awards_package as

    procedure add_post_award(
        p_post_id posts.id%type,
        p_award_id awards.id%type,
        p_user_username users.username%type
        );
        
    function awards_count(
        p_post_id posts.id%type
        ) return number;
        
end post_awards_package;
/
    
create or replace package body post_awards_package as
    procedure add_post_award(
        p_post_id posts.id%type,
        p_award_id awards.id%type,
        p_user_username users.username%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if not posts_package.post_exists(p_post_id) then
                raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');
            end if; 
            if not awards_package.award_exists(p_award_id)
            then
                raise_application_error(-20103,'Award with id "'||p_award_id||'" does not exist.');
            end if;   
            insert into post_awards(post_id, award_id, user_id)
                values(p_post_id, p_award_id, users_package.user_id(p_user_username));
        end;
        
    function awards_count(
        p_post_id posts.id%type
        ) return number
        as
            v_awards_count number;
        begin
            select count(*) into v_awards_count from post_awards where post_id=p_post_id;
            return v_awards_count;
        end;
end post_awards_package;
/


--  C O M M E N T _ V O T E S

create or replace package comment_votes_package as

    procedure add_like(
        p_comment_id comments.id%type,
        p_user_username users.username%type
        );
  
  
    procedure add_dislike(
        p_comment_id comments.id%type,
        p_user_username users.username%type
        );   
        
    function get_comment_vote_value(
        p_comment_id comments.id%type
        ) return number;
        
end comment_votes_package;
/
    
create or replace package body comment_votes_package as
    procedure add_like(
        p_comment_id comments.id%type,
        p_user_username users.username%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if not comments_package.comment_exists(p_comment_id) then
                raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');
            end if;
            insert into comment_votes(comment_id, user_id, vote_value)
                values(p_comment_id, users_package.user_id(p_user_username), 1);
        end;
   
    procedure add_dislike(
        p_comment_id comments.id%type,
        p_user_username users.username%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if not comments_package.comment_exists(p_comment_id) then
                raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');
            end if;
            insert into comment_votes(comment_id, user_id, vote_value)
                values(p_comment_id, users_package.user_id(p_user_username), -1);
        end;  
        
    function get_comment_vote_value(
        p_comment_id comments.id%type
        ) return number
        as 
            v_vote_value number;
        begin
            select sum(vote_value) into v_vote_value from comment_votes where comment_id=p_comment_id;
            return v_vote_value;
        end;
end comment_votes_package;
/



--  P O S T _ V O T E S

create or replace package post_votes_package as

    procedure add_like(
        p_post_id posts.id%type,
        p_user_username users.username%type
        );
        
    procedure add_dislike(
        p_post_id posts.id%type,
        p_user_username users.username%type
        );  
        
    function get_post_vote_value(
        p_post_id posts.id%type
        ) return number;
        
end post_votes_package;
/
    
create or replace package body post_votes_package as
    procedure add_like(
        p_post_id posts.id%type,
        p_user_username users.username%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if not posts_package.post_exists(p_post_id) then
                raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');
            end if;
            insert into post_votes(post_id, user_id, vote_value)
                values(p_post_id, users_package.user_id(p_user_username), 1);
        end;
 
    procedure add_dislike(
        p_post_id posts.id%type,
        p_user_username users.username%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if not posts_package.post_exists(p_post_id) then
                raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');
            end if;
            insert into post_votes(post_id, user_id, vote_value)
                values(p_post_id, users_package.user_id(p_user_username), -1);
        end;  
        
    function get_post_vote_value(
        p_post_id posts.id%type
        ) return number
        as 
            v_vote_value number;
        begin
            select sum(vote_value) into v_vote_value from post_votes where post_id=p_post_id;
            return v_vote_value;
        end;
end post_votes_package;
/  



--  C O M M U N I T Y _ M E M B E R S

create or replace package community_members_package as

    procedure add_member(
        p_user_username users.username%type,
        p_community_name communities.name%type
        );
        
end community_members_package;
/
    
create or replace package body community_members_package as
    procedure add_member(
        p_user_username users.username%type,
        p_community_name communities.name%type
        ) as
        begin
            if users_package.user_id(p_user_username) is null
            then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
            end if;
            if communities_package.community_id(p_community_name) is null
            then
                raise_application_error(-20103,'Community with name "'||p_community_name||'" does not exist.');
            end if; 
            insert into community_members(user_id, community_id)
                values(users_package.user_id(p_user_username), communities_package.community_id(p_community_name));
        end;
        
end community_members_package;
/  