-- 1. Top 10 equipos con mayor cantidad de victorias y menor cantidad de faltas --

WITH TeamWins AS (
    SELECT
        team_id,
        COUNT(CASE WHEN result = 'W' THEN 1 END) AS wins
    FROM
        teamstats
    GROUP BY
        team_id
),
TeamFouls AS (
    SELECT
        team_id,
        SUM(fouls) AS total_fouls
    FROM
        teamstats
    GROUP BY
        team_id
)

SELECT
    w.team_id,
    t.name AS team_name,
    w.wins,
    f.total_fouls
FROM
    TeamWins w
JOIN
    TeamFouls f ON w.team_id = f.team_id
JOIN
    teams t ON w.team_id = t.team_id
ORDER BY
    w.wins DESC,
    f.total_fouls ASC
LIMIT 10;

--2. Top 10 equipos victoriosos como home teams y away teams--

--Home teams--
WITH HomeTeamWins AS (
    SELECT
        home_team_id AS team_id,
        COUNT(*) AS wins
    FROM
        games
    WHERE
        home_goals > away_goals
    GROUP BY
        home_team_id
)

SELECT
    t.team_id,
    t.name AS team_name,
    htw.wins
FROM
    HomeTeamWins htw
JOIN
    teams t ON htw.team_id = t.team_id
ORDER BY
    htw.wins DESC
LIMIT 10;

--Away teams--

WITH AwayTeamWins AS (
    SELECT
        away_team_id AS team_id,
        COUNT(*) AS wins
    FROM
        games
    WHERE
        away_goals > home_goals
    GROUP BY
        away_team_id
)

SELECT
    t.team_id,
    t.name AS team_name,
    atw.wins
FROM
    AwayTeamWins atw
JOIN
    teams t ON atw.team_id = t.team_id
ORDER BY
    atw.wins DESC
LIMIT 10;

-- 3. Top 10 equipos con mayor precisión de tiro --

WITH TeamShotAccuracy AS (
    SELECT
        team_id,
        SUM(shots_on_target) AS total_shots_on_target,
        SUM(shots) AS total_shots,
        CASE
            WHEN SUM(shots) > 0 THEN SUM(shots_on_target)::FLOAT / SUM(shots)
            ELSE 0
        END AS shot_accuracy
    FROM
        teamstats
    GROUP BY
        team_id
)

SELECT
    t.team_id,
    t.name AS team_name,
    tsa.total_shots_on_target,
    tsa.total_shots,
    tsa.shot_accuracy
FROM
    TeamShotAccuracy tsa
JOIN
    teams t ON tsa.team_id = t.team_id
ORDER BY
    tsa.shot_accuracy DESC
LIMIT 10;

--4. el equipo con mayor número de goles marcados--

SELECT
    ts.team_id,
	t.name as team_name,
    SUM(goals) AS total_goals
FROM
    teamstats ts
join teams t on t.team_id=ts.team_id
GROUP BY
    ts.team_id,
	t.name
ORDER BY
    total_goals DESC
LIMIT 10;

--5. el equipo con menos goles encajados--

SELECT
    ts.team_id,
	t.name,
    SUM(goals) AS total_goals_conceded
FROM
    teamstats ts
join teams t on t.team_id=ts.team_id
WHERE
    result = 'L'  
GROUP BY
    ts.team_id,
	t.name
ORDER BY
    total_goals_conceded ASC
LIMIT 10;

--6. los 10 equipos con la mayor tasa de victorias (porcentaje de victorias sobre el total de juegos jugados)--

WITH TeamWins AS (
    SELECT
        team_id,
        COUNT(*) AS wins
    FROM
        teamstats
    WHERE
        result = 'W'
    GROUP BY
        team_id
),
TotalGames AS (
    SELECT
        team_id,
        COUNT(*) AS total_games
    FROM
        teamstats
    GROUP BY
        team_id
)
SELECT
    t.team_id,
    t.name AS team_name,
    CASE
        WHEN tg.total_games > 0 THEN (tw.wins::FLOAT / tg.total_games) * 100
        ELSE 0
    END AS win_rate
FROM
    TeamWins tw
JOIN
    TotalGames tg ON tw.team_id = tg.team_id
JOIN
    teams t ON tw.team_id = t.team_id
ORDER BY
    win_rate DESC
LIMIT 10;

--7. los 10 equipos con más portería a cero (partidos sin goles encajados).--

SELECT
    ts.team_id,
    t.name as team_name,
    COUNT(*) AS clean_sheets
FROM
    teamstats ts
join teams t on t.team_id=ts.team_id
WHERE
    goals = 0
GROUP BY
    ts.team_id,
	t.name
ORDER BY
    clean_sheets DESC
LIMIT 10;

--8. los 10 equipos con mayor número de goles marcados como anfitriones--
SELECT
    g.home_team_id AS team_id,
	t.name as team_name,
    SUM(g.home_goals) AS total_home_goals
FROM
    games g
join teams t on t.team_id=g.home_team_id
GROUP BY
    g.home_team_id,
	t.name
ORDER BY
    total_home_goals DESC
LIMIT 10;