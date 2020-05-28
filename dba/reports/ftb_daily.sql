use ftbprod;

select count( distinct du.login_id) as Unique_Login_Count from d3_user du where du.last_login_ts is not null;

select du.login_id,du.host_id,du.last_login_ts,du.previous_login_ts from d3_user du where du.last_login_ts is not null;

select d3u.login_id, m2t.provider_name, count(m2t.Id), sum(amount) from m2_transfer m2t
join d3_user d3u on d3u.id = m2t.user_id and DATE(CONVERT_TZ(m2t.created_ts,'UTC', 'America/New_York')) = DATE(sysdate() - 1) 
group by d3u.login_id, m2t.provider_name;

select d3u.login_id, m2t.provider_name, count(m2t.Id), sum(amount) from m2_transfer m2t
join d3_user d3u on d3u.id = m2t.user_id and DATE(CONVERT_TZ(m2t.created_ts,'UTC','America/New_York')) <= DATE(sysdate() - 1)
group by d3u.login_id, m2t.provider_name;

