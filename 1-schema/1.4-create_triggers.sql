-- Author: Adam Øeøicha


-- COMMENT TRIGGERS

create or replace trigger trg_comment_cycle
before insert on comments
for each row
begin
    if :new.parent_comment_id = :new.id then
        raise_application_error(-20001, 'Comment cannot be a parent to himself');
    end if;    
end;
/

create or replace trigger trg_comment_empty
before insert on comments
for each row
begin
    if trim(:new.text) is null then
        raise_application_error(-20003, 'New comment cannot be empty');
    end if;
end;
/

create or replace trigger trg_comment_update_timestamp
before update on comments
for each row
begin
    :new.updated_at := systimestamp;
end;
/

-- POST TRIGGERS

create or replace trigger trg_post_empty
before insert or update on posts
for each row
begin 
    if trim(:new.text) is null and :new.image_path is null then
        raise_application_error(-20002, 'Post must have an image or a text');
    end if;    
end;    
/

create or replace trigger trg_post_update_timestamp
before update on posts
for each row
begin
    :new.updated_at := systimestamp;
end;
/