-- Author: Adam Řeřicha


begin

    dbms_stats.delete_table_stats(user, 'awards');
    dbms_stats.delete_table_stats(user, 'comment_awards');
    dbms_stats.delete_table_stats(user, 'comment_votes');
    dbms_stats.delete_table_stats(user, 'comments');
    dbms_stats.delete_table_stats(user, 'communities');
    dbms_stats.delete_table_stats(user, 'community_members');
    dbms_stats.delete_table_stats(user, 'post_awards');
    dbms_stats.delete_table_stats(user, 'post_votes');
    dbms_stats.delete_table_stats(user, 'posts');
    dbms_stats.delete_table_stats(user, 'users');

end;
/