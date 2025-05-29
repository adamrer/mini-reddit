-- Author: Adam Řeřicha


--  U S E R S

create or replace package users_package as

    -- adds a new user to the database
    procedure add_user(p_username users.username%type, p_email users.email%type);
    
    -- delete a user
    procedure delete_user(
        p_username users.username%type
    );

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
    exception
        when dup_val_on_index then
            raise_application_error(-20012, 'User "'||p_username||'" already exists.');
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
    exception 
        when no_data_found then
            return null;
    end;
    
    procedure delete_user(
        p_username users.username%type
    ) as
        v_user_id users.id%type;
    begin
        select id into v_user_id from users where username = p_username
        for update;
    
        delete from users where id = v_user_id;
    exception
        when no_data_found then
            raise_application_error(-20100, 'User with username "'||p_username||'" does not exist.');
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
        
    -- delete a community
    procedure delete_community(
        p_name communities.name%type
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
        if p_name is null then
            raise_application_error(-20011, 'Community name must not be null.');
        end if;
        insert into communities(id, name, description)
            values(communities_id_seq.nextval, p_name, p_description);
    exception
        when dup_val_on_index then
            raise_application_error(-20010, 'Community "'||p_name||'" already exists.');
    end;
    
    procedure delete_community(
        p_name communities.name%type
        ) as
        v_community_id communities.id%type;
    begin
        select id into v_community_id from communities where name = p_name
        for update;
        delete from communities where id = v_community_id;
    exception
        when no_data_found then
            raise_application_error(-20103,'Community with name "'||p_name||'" does not exist.');
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
    exception 
        when no_data_found then
            return null;  
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
        
    -- delete an award
    procedure delete_award(
        p_award_id awards.id%type
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
    exception            
        when dup_val_on_index then
            raise_application_error(-20013, 'Award "'||p_name||'" already exists.');
    end;
        
    procedure delete_award(
        p_award_id awards.id%type
        ) as
        v_dummy number;
    begin
        select 1 into v_dummy from awards where id = p_award_id
        for update;
        delete from awards where id = p_award_id;
        
    exception
        when no_data_found then
            raise_application_error(-20103,'Award with id "'||p_award_id||'" does not exist.');
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
    
    -- updates text of a comment
    procedure update_comment(
        p_comment_id comments.id%type,
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
        
    -- return comments attached to a post
    function comments_attached_to_post(
        p_post_id posts.id%type
        ) return sys_refcursor;
        
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
        v_author_id users.id%type;
        v_dummy number;
    begin
        select id into v_author_id from users where username = p_author_username
        for update;
    
        if p_parent_comment_id is not null then
            select 1 into v_dummy from comments where id = p_parent_comment_id
            for update;
        end if;
    
        insert into comments(
            id, author_id, parent_comment_id, post_id, text
        ) values (
            comments_id_seq.nextval,
            v_author_id,
            p_parent_comment_id,
            p_post_id,
            p_text
        );
    
    exception
        when no_data_found then
            if p_parent_comment_id is not null then
                raise_application_error(-20101, 'Parent comment with id "'||p_parent_comment_id||'" does not exist.');
            else
                raise_application_error(-20100, 'User with username "'||p_author_username||'" does not exist.');
            end if;
    end;
        
    procedure update_comment(
        p_comment_id comments.id%type,
        p_text comments.text%type
        ) as
        v_dummy number;
    begin
        select 1 into v_dummy from comments where id = p_comment_id
        for update;
        
        update comments set text=p_text where id = p_comment_id;
    exception
        when no_data_found then
            raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');
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
        exception 
            when no_data_found then
                return null;
        end;
        
    function comments_attached_to_post(
        p_post_id posts.id%type
        ) return sys_refcursor
        as
            v_cursor sys_refcursor;
        begin
            open v_cursor for
                select c.*
                from comments c
                where c.post_id = p_post_id;
                
            return v_cursor;    
        exception 
            when no_data_found then
                return null;
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
        
    -- delete a post
    procedure delete_post(
        p_post_id posts.id%type
        );
        
    -- update a post
    procedure update_post(
        p_post_id posts.id%type,
        p_title posts.title%type,
        p_text posts.text%type,
        p_image_path posts.image_path%type
        );
    
    -- return all posts by user with given username
    function get_posts_by_user(
        p_username users.username%type
        ) return sys_refcursor;

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
        v_author_id users.id%type;
        v_community_id communities.id%type;
    begin
        select id into v_author_id from users where username = p_author_username
        for update;
        
        begin
            select id into v_community_id
            from communities
            where name = p_community_name
            for update;
        exception
            when no_data_found then
                raise_application_error(-20101, 'Community with name "'||p_community_name||'" does not exist.');
        end;  
        
        insert into posts(id, author_id, community_id, title, text, image_path)
            values(
                posts_id_seq.nextval, 
                users_package.user_id(p_author_username),
                communities_package.community_id(p_community_name), 
                p_title, 
                p_text,
                p_image_path);
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_author_username||'" does not exist.');
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
    
    procedure delete_post(
        p_post_id posts.id%type
    ) as
        v_dummy number;
    begin
    
        select 1 into v_dummy from posts where id=p_post_id
        for update;
        
        delete from posts where id = p_post_id;
    exception
        when no_data_found then
            raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');
    end;
    
    procedure update_post(
        p_post_id posts.id%type,
        p_title posts.title%type,
        p_text posts.text%type,
        p_image_path posts.image_path%type
    ) as
        v_dummy posts.id%type;
    begin
        select 1 into v_dummy from posts where id = p_post_id
        for update;
        
    
        update posts
        set title = p_title,
            text = p_text,
            image_path = p_image_path
        where id = p_post_id;
    exception
        when no_data_found then
            raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');
    end;
    
    
    function get_posts_by_user(
        p_username users.username%type
        ) return sys_refcursor
        as
            v_user_id users.id%type;
            v_cursor sys_refcursor;
        begin
            v_user_id := users_package.user_id(p_username);
            open v_cursor for
                select p.*
                from posts p
                where p.author_id = v_user_id;
                
            return v_cursor;    
        exception 
            when no_data_found then
                return null;
        end;
    
    
end posts_package;
/

--  C O M M E N T _ A W A R D S

create or replace package comment_awards_package as

    procedure award_comment(
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
    procedure award_comment(
        p_comment_id comments.id%type,
        p_award_id awards.id%type,
        p_user_username users.username%type
        ) as
            v_user_id users.id%type;
            v_dummy number;
        begin
            select id into v_user_id from users where username = p_user_username
            for update;
            
            begin
                select 1 into v_dummy from comments where id = p_comment_id
                for update;
            exception
                when no_data_found then
                    raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');    
            end;
                       
            begin
                select 1 into v_dummy from awards where id = p_award_id
                for update;
            exception
                when no_data_found then
                    raise_application_error(-20103,'Award with id "'||p_award_id||'" does not exist.');
            end;
            insert into comment_awards(comment_id, award_id, user_id)
                values(p_comment_id, p_award_id, v_user_id);
        exception
            when no_data_found then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
        end;
        
    function awards_count(
        p_comment_id comments.id%type
        ) return number
        as
            v_awards_count number;
        begin
            select count(*) into v_awards_count from comment_awards where comment_id=p_comment_id;
            return v_awards_count;
        exception 
            when no_data_found then
                return null;
        end;
        
end comment_awards_package;
/


--  P O S T _ A W A R D S

create or replace package post_awards_package as

    procedure award_post(
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
    procedure award_post(
        p_post_id posts.id%type,
        p_award_id awards.id%type,
        p_user_username users.username%type
        ) as
            v_user_id users.id%type;
            v_dummy number;
        begin
            select id into v_user_id from users where username = p_user_username
            for update;
            
            begin
                select 1 into v_dummy from posts where id = p_post_id
                for update;
            exception
                when no_data_found then
                    raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');    
            end;
                       
            begin
                select 1 into v_dummy from awards where id = p_award_id
                for update;
            exception
                when no_data_found then
                    raise_application_error(-20103,'Award with id "'||p_award_id||'" does not exist.');
            end;
            insert into post_awards(post_id, award_id, user_id)
                values(p_post_id, p_award_id, v_user_id);
        exception
            when no_data_found then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
        end;
        
    function awards_count(
        p_post_id posts.id%type
        ) return number
        as
            v_awards_count number;
        begin
            select count(*) into v_awards_count from post_awards where post_id=p_post_id;
            return v_awards_count;
        exception 
            when no_data_found then
                return null;
        end;
end post_awards_package;
/


--  C O M M E N T _ V O T E S

create or replace package comment_votes_package as

    procedure like_comment(
        p_comment_id comments.id%type,
        p_user_username users.username%type
        );
  
  
    procedure dislike_comment(
        p_comment_id comments.id%type,
        p_user_username users.username%type
        );   
        
        
    procedure delete_vote(
        p_comment_id comments.id%type,
        p_user_username users.username%type
    );
        
    function get_comment_vote_value(
        p_comment_id comments.id%type
        ) return number;
        
end comment_votes_package;
/
    
create or replace package body comment_votes_package as
    procedure like_comment(
        p_comment_id comments.id%type,
        p_user_username users.username%type
    ) as
        v_user_id users.id%type;
        v_dummy number;
    begin
        
        select id into v_user_id from users where username = p_user_username
        for update;
        
        begin
            select 1 into v_dummy from comments where id = p_comment_id
            for update;
        exception
            when no_data_found then
                raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');    
        end;

        begin
            select vote_value into v_dummy
            from comment_votes
            where comment_id = p_comment_id and user_id = v_user_id
            for update;
    
            update comment_votes
            set vote_value = 1
            where comment_id = p_comment_id and user_id = v_user_id;
    
        exception
            when no_data_found then
                insert into comment_votes(comment_id, user_id, vote_value)
                values(p_comment_id, v_user_id, 1);
        end;
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;

    procedure dislike_comment(
        p_comment_id comments.id%type,
        p_user_username users.username%type
    ) as
        v_user_id users.id%type;
        v_dummy number;
    begin
        
        select id into v_user_id from users where username = p_user_username
        for update;
        
        begin
            select 1 into v_dummy from comments where id = p_comment_id
            for update;
        exception
            when no_data_found then
                raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');    
        end;

        begin
            select vote_value into v_dummy
            from comment_votes
            where comment_id = p_comment_id and user_id = v_user_id
            for update;
    
            update comment_votes
            set vote_value = -1
            where comment_id = p_comment_id and user_id = v_user_id;
    
        exception
            when no_data_found then
                insert into comment_votes(comment_id, user_id, vote_value)
                values(p_comment_id, v_user_id, -1);
        end;
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;
 
    procedure delete_vote(
        p_comment_id comments.id%type,
        p_user_username users.username%type
    ) as
        v_user_id users.id%type;
        v_dummy number;
    begin
        select id into v_user_id from users where username = p_user_username
        for update;
        begin
            select 1 into v_dummy from comments where id = p_comment_id
            for update;
        exception
            when no_data_found then
                raise_application_error(-20101,'Comment with id "'||p_comment_id||'" does not exist.');
        end;
        delete from comment_votes
        where comment_id = p_comment_id and user_id = v_user_id;
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;
    
    function get_comment_vote_value(
        p_comment_id comments.id%type
        ) return number
        as 
            v_vote_value number;
        begin
            select sum(vote_value) into v_vote_value from comment_votes where comment_id=p_comment_id;
            if v_vote_value is null then
                return 0;
            end if;
            return v_vote_value;
        exception 
            when no_data_found then
                return null;
        end;
end comment_votes_package;
/



--  P O S T _ V O T E S

create or replace package post_votes_package as

    procedure like_post(
        p_post_id posts.id%type,
        p_user_username users.username%type
    );

    procedure dislike_post(
        p_post_id posts.id%type,
        p_user_username users.username%type
    );

    procedure delete_vote(
        p_post_id posts.id%type,
        p_user_username users.username%type
    );

    function get_post_vote_value(
        p_post_id posts.id%type
    ) return number;

end post_votes_package;
/
    
create or replace package body post_votes_package as
    procedure like_post(
        p_post_id posts.id%type,
        p_user_username users.username%type
    ) as
        v_user_id users.id%type;
        v_dummy number;
    begin
        
        select id into v_user_id from users where username = p_user_username
        for update;
        
        begin
            select 1 into v_dummy from posts where id = p_post_id
            for update;
        exception
            when no_data_found then
                raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');    
        end;

        begin
            select vote_value into v_dummy
            from post_votes
            where post_id = p_post_id and user_id = v_user_id
            for update;
    
            update post_votes
            set vote_value = 1
            where post_id = p_post_id and user_id = v_user_id;
    
        exception
            when no_data_found then
                insert into post_votes(post_id, user_id, vote_value)
                values(p_post_id, v_user_id, 1);
        end;
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;
 
    procedure dislike_post(
        p_post_id posts.id%type,
        p_user_username users.username%type
    ) as
        v_user_id users.id%type;
        v_dummy number;
    begin
        
        select id into v_user_id from users where username = p_user_username
        for update;
        
        begin
            select 1 into v_dummy from posts where id = p_post_id
            for update;
        exception
            when no_data_found then
                raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');    
        end;

        begin
            select vote_value into v_dummy
            from post_votes
            where post_id = p_post_id and user_id = v_user_id
            for update;
    
            update post_votes
            set vote_value = -1
            where post_id = p_post_id and user_id = v_user_id;
    
        exception
            when no_data_found then
                insert into post_votes(post_id, user_id, vote_value)
                values(p_post_id, v_user_id, -1);
        end;
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;
 
    procedure delete_vote(
        p_post_id posts.id%type,
        p_user_username users.username%type
    ) as
        v_user_id users.id%type;
        v_dummy number;
    begin
        select id into v_user_id from users where username = p_user_username
        for update;
    
        begin
            select 1 into v_dummy from posts where id = p_post_id
            for update;
        exception
            when no_data_found then
                raise_application_error(-20104,'Post with id "'||p_post_id||'" does not exist.');   
        end;
        delete from post_votes
        where post_id = p_post_id and user_id = v_user_id;
    exception 
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;
    

    function get_post_vote_value(
        p_post_id posts.id%type
        ) return number
        as 
            v_vote_value number;
        begin
            select sum(vote_value) into v_vote_value from post_votes where post_id=p_post_id;
            if v_vote_value is null then
                return 0;
            end if;
            return v_vote_value;
        exception 
            when no_data_found then
                return null;
        end;
end post_votes_package;
/  



--  C O M M U N I T Y _ M E M B E R S

create or replace package community_members_package as

    procedure add_member(
        p_user_username users.username%type,
        p_community_name communities.name%type
        );
        
    procedure remove_member(
        p_user_username users.username%type,
        p_community_name communities.name%type
        );
        
    function members_count(
        p_community_name communities.name%type
        ) return number;
        
end community_members_package;
/
    
create or replace package body community_members_package as
    procedure add_member(
        p_user_username users.username%type,
        p_community_name communities.name%type
        ) as
            v_user_id users.id%type;
            v_community_id communities.id%type;
        begin
            select id into v_user_id from users where username = p_user_username
            for update;
            
            begin
                select id into v_community_id from communities where name = p_community_name
                for update;
            exception
                when no_data_found then
                    raise_application_error(-20103,'Community with name "'||p_community_name||'" does not exist.');
            end;
            insert into community_members(user_id, community_id)
                values(v_user_id, v_community_id);
        exception
            when no_data_found then
                raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
        end;
        
        
    procedure remove_member(
        p_user_username users.username%type,
        p_community_name communities.name%type
        ) as
        v_user_id users.id%type;
        v_community_id communities.id%type;
    begin
        select id into v_user_id from users where username = p_user_username
        for update;
        
        begin
            select id into v_community_id from communities where name = p_community_name
            for update;
        exception
            when no_data_found then
                raise_application_error(-20103,'Community with name "'||p_community_name||'" does not exist.');    
        end;

        delete from community_members where user_id=users_package.user_id(p_user_username) and community_id=communities_package.community_id(p_community_name);
    exception
        when no_data_found then
            raise_application_error(-20102,'User with username "'||p_user_username||'" does not exist.');
    end;
    
    function members_count(
        p_community_name communities.name%type
    ) return number
    as 
        v_community_id communities.id%type;
        retval number;
    begin
        select id into v_community_id from communities where name = p_community_name;
        select count(*) into retval from community_members where community_id = v_community_id;
        return retval;
    exception
        when no_data_found then
            raise_application_error(-20103,'Community with name "'||p_community_name||'" does not exist.');
    end;
    
end community_members_package;
/  
