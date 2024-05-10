Create database game_analysis;

Use game_analysis;

select * from level_details2;
select * from player_details;

-- Q1) Extract P_ID,Dev_ID,PName and Difficulty_level of all players at level 0

select table1.P_ID,Dev_ID,PName,Difficulty FROM level_details2 as table1
left join player_details as table2 on table1.P_ID =table2.P_ID
where table1.Level= 0;

-- Q2) Find Level1_code wise Avg_Kill_Count where lives_earned is 2 and atleast 3 stages are crossed

select table2.L1_Status,avg(Kill_Count) from level_details2 as table1
left join player_details as table2 on table1.P_ID =table2.P_ID
where table1.Lives_Earned = 2 and table1.Stages_crossed>=3 
group by table2.L1_Status;

-- Q3) Find the total number of stages crossed at each diffuculty level where for Level2 with players use zm_series devices. Arrange the result
-- in decsreasing order of total number of stages crossed.

Select table1.Difficulty,sum(Stages_crossed) as 'Total number of stages crossed' from level_details2 as table1
left join player_details as table2 on table1.P_ID =table2.P_ID
where table1.Level = 2 and table1.Dev_ID like 'zm%'
group by table1.Difficulty order by 'Total number of stages crossed' desc;

-- Q4) Extract P_ID and the total number of unique dates for those players who have played games on multiple days.

select P_ID,count(distinct(TimeStamp)) as Unique_dates from level_details2 
group by P_ID having count(distinct(TimeStamp)) >1;

-- Q5) Find P_ID and level wise sum of kill_counts where kill_count is greater than avg kill count for the Medium difficulty.

select P_ID,Level,sum(Kill_Count) as 'Total kill' from level_details2
where Kill_Count > (select avg(Kill_Count) from level_details2
where Difficulty = "Medium") 
group by P_ID,Level;

-- Q6)  Find Level and its corresponding Level code wise sum of lives earned excluding level 0. Arrange in asecending order of level.

select table1.Level,table2.L1_Code,table2.L2_Code,sum(Lives_Earned) from level_details2 as table1
left join player_details as table2 on table1.P_ID =table2.P_ID
where table1.Level <> 0 
group by table1.Level,table2.L1_Code,table2.L2_Code order by table1.Level;

-- Q7) Find Top 3 score based on each dev_id and Rank them in increasing order using Row_Number. Display difficulty as well. 

with new_table as (select Dev_ID,Difficulty,Score, row_number() over(partition by Dev_ID order by
Score desc) as Ranked from level_details2)
select Dev_ID,Score,Difficulty Ranked from new_table 
where Ranked<=3;

-- Q8) Find first_login datetime for each device id

select Dev_ID,min(TimeStamp) from level_details2 
group by Dev_ID;

-- Q9) Find Top 5 score based on each difficulty level and Rank them in  increasing order using Rank. Display dev_id as well.

with new_table as (select Dev_ID,Score,Difficulty, rank() over(partition by Dev_ID order by
Score desc) as Ranked from level_details2)
select Dev_ID,Score,Difficulty, Ranked from new_table 
where Ranked<=5;

-- Q10) Find the device ID that is first logged in(based on start_datetime)  for each player(p_id). Output should contain player id, device id and first login datetime.

select P_ID,Dev_ID,min(TimeStamp) from level_details2 
group by Dev_ID,P_ID;

-- Q11) For each player and date, how many kill_count played so far by the player. That is, the total number of games played -- by the player until that date.
-- a) window function
-- b) without window function

-- a) window function
select distinct P_ID, cast(TimeStamp as Date) as Dated, sum(Kill_Count)
over(partition by P_ID,cast(TimeStamp as Date) order by cast(TimeStamp as Date))
as Total_number_killed from level_details2 order by P_ID,Dated;

-- b) without window function

select P_ID, cast(TimeStamp as Date) as Dated, sum(Kill_Count)
as Total_number_killed from level_details2 group by P_ID,cast(TimeStamp as Date) order by P_ID,Dated;


-- Q12) Find the cumulative sum of an stages crossed over a start_datetime for each player id but exclude the most recent start_datetime

with task as (select P_ID,Stages_crossed,TimeStamp,row_number() over(partition by P_ID order by
TimeStamp desc) as CS from level_details2)
select P_ID,sum(Stages_crossed),TimeStamp from task
where CS >1 group by P_ID,TimeStamp; 

-- Q13) Extract top 3 highest sum of score for each device id and the corresponding player_id

with task as(select P_ID,Dev_ID,sum(Score) as score,row_number() over(partition by Dev_ID order by
sum(Score) desc) as Ranked from level_details2 group by P_ID,Dev_ID)
select P_ID,Dev_ID,score from task
where Ranked<4;

-- Q14) Find players who scored more than 50% of the average score, scored by the sum of scores for each `P_ID`.

select P_ID,sum(Score) from level_details2 group by P_ID
having sum(Score) >0.5*(select avg(Score) from level_details2);

-- Q15) Create a stored procedure to find the top `n` `headshots_count` based on each `Dev_ID` 
--- and rank them in increasing order using `Row_Number`. Display the difficulty as well.

Create Procedure TopN(IN n INT)
select Dev_ID,Headshots_Count,Difficulty 
From(select Dev_ID,Headshots_Count,Difficulty,
row_number() over(partition by P_ID order by
Headshots_Count) as Ranked from level_details2)
as task
where Ranked<= n;
call TopN(9)
























