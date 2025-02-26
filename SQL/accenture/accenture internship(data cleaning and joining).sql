Create database internship;
Select* from internship.content;
Select * from Content where "URL" is null or "URL" = '';
Alter table content
Drop column URL;  
Alter table content
Drop column MyUnknownColumn;
Select *
FROM information_schema.columns
WHERE table_name = 'content';

Select category from content ;
Update content
Set category= trim(trailing'"'From category); 
Select Distinct Category from content;

Alter table content
Drop column `User ID`;

Select * from content;
Select count(*) - count(`Content ID`) from content;

Select* from reactions where `Content ID` is null or `Content ID` ='';
Select* from reactions;

Alter table reactions
Drop column `Datetime`;

Alter table reactions
Drop column MyUnknownColumn;

Select* from reactions;

Select* from reactiontypes
Where (`type` is null or `type`='') or (`sentiment` is null or `sentiment`='') or (`score` is null);

Alter table content
change type `Content Type` varchar(200);
Alter table reactiontypes
change type `Reaction Type` varchar(200);

drop table reactions;
Select * from reactions;
Alter table reactions
change type `Reaction Type` varchar(200);
Delete from reactions where `reaction type`='' or `reaction type` is null;

Select c.`Content ID`,c.`Content Type`, c.`Category`, r.`Reaction Type`, rt.`Score`, sum(rt.`Score`) over(partition by c.Category) as agg_score
from content c
Join reactions r
On r.`Content ID`=c.`Content ID`
Join `reactiontypes` rt
On rt.`Reaction Type`= r.`Reaction Type`
Order by agg_score desc;

