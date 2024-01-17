use ig_clone;


-- Find the 5 oldest users

select * from users;

select * from users
order by created_at
limit 5;


-- What day of the week do most users register on? We need to figure out when to schedule an ad campaign.

select * from users;

select dayname(created_at) as dayn,count(created_at) as cnt from users
group by dayn
order by cnt desc
limit 1;



-- We want to target our inactive users with an email campaign.Find the users who have never posted a photo?

select * from photos;

select * from photo_tags;

select * from tags;

select id,username from users
where id not in (select p.id from photo_tags as pt
join photos as p
on pt.photo_id=p.id);

 

-- We're running a new contest to see who can get the most likes on a single photo.WHO WON??!! (Adelle96	480)

select * from likes;
select u.username,count(l.user_id) as likes from users as u 
join photos as p
on u.id=p.user_id
join likes as l
using (user_id)
group by u.username
order by likes desc;


-- Find users who have never commented on a photo.? (23)

select * from comments;

select count(*) from users 
where id not in (select u.id 
from users as u
join comments as c
on u.id = c.user_id);



-- Our Investors want to know… How many times does the average user post?HINT - *total number of photos/total number of users(3.4 when taking on total users)
/* average user posts number by active users only*/

with cte as 
(select user_id, count(image_url) as img from photos
group by user_id),
cte_2 as 
(select count(user_id) as total_user ,sum(img)  as sum_posts from cte)
select (sum_posts/total_user) as avg_post
from cte_2;


/* average user posts number by active and non active users*/

select (select count(*) from photos) / (select count(*) from users) as avg_post;



-- user ranking by postings higher to lower

use clone;

select *, dense_rank() over (order by posts desc) as ranks from 
(select u.username,u.id,count(image_url) as posts
from users as u
join photos as p
on u.id = p.user_id
group by u.username,u.id) as abc;


-- total numbers of users who have posted at least one time.

select count(*) as number_of_users_posted_atleast_once from 
(select u.username,u.id,count(image_url) as posts
from users as u
join photos as p
on u.id = p.user_id
group by u.username,u.id) as abc
where posts >=1;



-- A brand wants to know which hashtags to use in a post
select * from
(select t.id,t.tag_name,count(pt.tag_id) as count
from  tags as t
join photo_tags as pt
on pt. tag_id = t.id
group by t.id,t.tag_name) as abc
order by count desc
limit 1; 
 
-- What are the top 5 most commonly used hashtags?
select * from
(select t.id,t.tag_name,count(pt.tag_id) as count
from  tags as t
join photo_tags as pt
on pt. tag_id = t.id
group by t.id,t.tag_name) as abc
order by count desc
limit 5; 

-- We have a small problem with bots on our site...Find users who have liked every single photo on the site.
select user_id,count(photo_id) as photos_liked from 
(select l.user_id,l.photo_id,l.created_at,p.id,p.image_url
from likes as l
cross join photos as p
on l.photo_id=p.id) as abc
group by l.user_id
having photos_liked = 257 ;
