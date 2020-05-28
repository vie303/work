update user_dest set dest_value='INVALIDEMAILADDRESS' where lower(dest_type) = 'email' and user_profile_id in (select u.user_profile_id from d3_user u where u.deleted=true and u.deleted_ts > date_sub(curdate(),interval 21 day));

update user_dest set dest_value='1111111111' where lower(dest_type) = 'phone' and user_profile_id in (select u.user_profile_id from d3_user u where u.deleted=true and u.deleted_ts > date_sub(curdate(),interval 21 day));

update m2_transfer set status='CANCELLED' where provider_name='D3ACH' and status='PENDING' and scheduled_date >= curdate() and user_id in (select u.id from d3_user u where u.deleted=true and u.deleted_ts > date_sub(curdate(),interval 21 day));

update d3_user set login_id = concat(login_id,'_',date(sysdate()),'_dead') where deleted = true and login_id not like '%_dead';
