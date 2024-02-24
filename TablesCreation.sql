CREATE TABLE leagues (
    league_id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    understatement VARCHAR(50)
);
CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE games (
    game_id INTEGER PRIMARY KEY,
    league_id INTEGER,
    season VARCHAR(255),
    date TIMESTAMP,
    home_team_id INTEGER,
    away_team_id INTEGER,
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
    PSCA FLOAT,
    FOREIGN KEY (league_id) REFERENCES leagues(league_id),
    FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);
CREATE TABLE players (
    player_id INTEGER PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE appearances (
    game_id INTEGER,
    player_id INTEGER,
    goals INTEGER,
    own_goals INTEGER,
    shots INTEGER,
    xgoals FLOAT,
    xgoal_chain FLOAT,
    xgoal_buildup FLOAT,
    assists INTEGER,
    key_passes INTEGER,
    xassists FLOAT,
    position VARCHAR(50),
    position_order INTEGER,
    yellow_card INTEGER,
    red_card INTEGER,
    time_played INTEGER,
    substitute_in BOOLEAN,
    substitute_out BOOLEAN,
    league_id INTEGER,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (league_id) REFERENCES leagues(league_id)
);
CREATE TABLE shots (
    game_id INTEGER,
    shooter_id INTEGER,
    assister_id INTEGER,
    minute INTEGER,
    situation VARCHAR(50),
    last_action VARCHAR(50),
    shot_type VARCHAR(50),
    shot_result VARCHAR(50),
    xgoal FLOAT,
    position_x FLOAT,
    position_y FLOAT,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (shooter_id) REFERENCES players(player_id),
    FOREIGN KEY (assister_id) REFERENCES players(player_id)
);
CREATE TABLE teamstats (
    game_id INTEGER,
    team_id INTEGER,
    goals INTEGER,
    own_goals INTEGER,
    shots INTEGER,
    xgoals FLOAT,
    xgoal_chain FLOAT,
    xgoal_buildup FLOAT,
    assists INTEGER,
    key_passes INTEGER,
    xassists FLOAT,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);
