use ipl;
show tables;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_player;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_team_players;
select * from ipl_team_standings;
select * from ipl_tournament;
select * from ipl_user;

-- 1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select bdr_dt.bidder_id 'Bidder ID', bdr_dt.bidder_name 'Bidder Name', 
(select count(*) from ipl_bidding_details bid_dt 
where bid_dt.bid_status = 'won' and bid_dt.bidder_id = bdr_dt.bidder_id) / 
(select no_of_bids from ipl_bidder_points bdr_pt 
where bdr_pt.bidder_id = bdr_dt.bidder_id)*100 as 'Percentage of Wins (%)'
from ipl_bidder_details bdr_dt order by 3 desc;

-- 2. Which teams have got the highest and the lowest no. of bids?

select team_id, team_name 'Team Name', count(*) 'Number of Bids' from ipl_team t join ipl_bidding_details bid_dt
on t.team_id = bid_dt.bid_team where bid_status <> 'cancelled' group by bid_team 
having count(*) = (select count(*) from ipl_bidding_details where bid_status <> 'cancelled' 
group by bid_team order by count(*) desc limit 1) or 
count(*) = (select count(*) from ipl_bidding_details where bid_status <> 'cancelled' 
group by bid_team order by count(*) limit 1);

-- 3. In a given stadium, what is the percentage of wins by a team which had won the toss?

select stadium_id 'Stadium ID', stadium_name 'Stadium Name',
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;

-- 4. What is the total no. of bids placed on the team that has won highest no. of matches?

select team_id 'Team ID', team_name 'Team Name', count(*) 'Total Bids'
from ipl_bidding_details join ipl_team on team_id = bid_team 
where bid_status <> 'cancelled' group by bid_team
having bid_team = (select team_id from ipl_team_standings order by matches_won desc limit 1);

-- 5. From the current team standings, if a bidder places a bid on which of the teams, 
-- there is a possibility of (s)he winning the highest no. of points – in simple words, 
-- identify the team which has the highest jump in its total points (in terms of percentage) 
-- from the previous year to current year.

select t.team_id 'Team ID', t.team_name 'Team Name', 
((select total_points from ipl_team_standings ts where ts.team_id = t.team_id and tournmt_id = 2018) - 
(select total_points from ipl_team_standings ts where ts.team_id = t.team_id and tournmt_id = 2017) ) /
(select total_points from ipl_team_standings ts where ts.team_id = t.team_id and tournmt_id = 2017) * 100 
as 'Jump in total points from last year (%)'
from ipl_team t order by 3 desc limit 1;
