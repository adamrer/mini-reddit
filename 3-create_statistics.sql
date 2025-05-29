-- Author: Adam Řeřicha

begin 
    dbms_stats.gather_table_stats(user,'awards',cascade => true);
    dbms_stats.gather_table_stats(user,'comment_awards',cascade => true);
    dbms_stats.gather_table_stats(user,'comment_votes',cascade => true);
    dbms_stats.gather_table_stats(user,'comments',cascade => true);
    dbms_stats.gather_table_stats(user,'communities',cascade => true);
    dbms_stats.gather_table_stats(user,'community_members',cascade => true);
    dbms_stats.gather_table_stats(user,'post_awards',cascade => true);
    dbms_stats.gather_table_stats(user,'post_votes',cascade => true);
    dbms_stats.gather_table_stats(user,'posts',cascade => true);
    dbms_stats.gather_table_stats(user,'users',cascade => true);
end;
/

