CREATE TABLE leagues (
    league_id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    understatement VARCHAR(50)
);
CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE players (
    player_id INTEGER PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE games (
    game_id INTEGER PRIMARY KEY,
    league_id INTEGER REFERENCES leagues(league_id),
    season VARCHAR(255),
    date TIMESTAMP, 
    home_team_id INTEGER REFERENCES teams(team_id),
    away_team_id INTEGER REFERENCES teams(team_id),
    home_goals INTEGER,
    away_goals INTEGER,
    home_probability FLOAT,
    draw_probability FLOAT,
    away_probability FLOAT,
    home_goals_halftime INTEGER,
    away_goals_halftime INTEGER,
    B365H FLOAT,
    B365D FLOAT,
    B365A FLOAT,
    BWH FLOAT,
    BWD FLOAT,
    BWA FLOAT,
    IWH FLOAT,
    IWD FLOAT,
    IWA FLOAT,
    PSH FLOAT,
    PSD FLOAT,
    PSA FLOAT,
    WHH FLOAT,
    WHD FLOAT,
    WHA FLOAT,
    VCH FLOAT,
    VCD FLOAT,
    VCA FLOAT,
    PSCH FLOAT,
    PSCD FLOAT,
    PSCA FLOAT
);

CREATE TABLE appearances (
    game_id INTEGER REFERENCES games(game_id),
    player_id INTEGER REFERENCES players(player_id),
    goals INTEGER,
    own_goals INTEGER,
    shots INTEGER,
    xgoals FLOAT,
    xgoal_chain FLOAT,
    xgoal_buildup FLOAT,
    assists INTEGER,
    key_passes INTEGER,
    xassists FLOAT,
    position VARCHAR(255),
    position_order INTEGER,
    yellow_card INTEGER,
    red_card INTEGER,
    time_played INTEGER,
    substitute_in INTEGER,
    substitute_out INTEGER,
    league_id INTEGER REFERENCES leagues(league_id)
);

CREATE TABLE shots (
    game_id INTEGER REFERENCES games(game_id),
    shooter_id INTEGER REFERENCES players(player_id),
    assister_id INTEGER REFERENCES players(player_id),
    minute INTEGER,
    situation VARCHAR(255),
    last_action VARCHAR(255),
    shot_type VARCHAR(255),
    shot_result VARCHAR(255),
    xgoal FLOAT,
    position_x FLOAT,
    position_y FLOAT
);

CREATE TABLE teamstats (
    game_id INTEGER REFERENCES games(game_id),
    team_id INTEGER REFERENCES teams(team_id),
    season VARCHAR(255),
    date TIMESTAMP, 
    location VARCHAR(255),
    goals INTEGER,
    xgoals FLOAT,
    shots INTEGER,
    shots_on_target INTEGER,
    deep INTEGER,
    ppda FLOAT,
    fouls INTEGER,
    corners INTEGER,
    yellow_cards INTEGER,
    red_cards INTEGER,
    result VARCHAR(50)
);
