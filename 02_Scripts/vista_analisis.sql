USE WorldCupDataset

select * from players;
select * from worldcups;
select * from matches;

-- 1. ¿Cuantos goles por mundial hicieron los futbolistas que entraron de suplente?
CREATE VIEW vw_Goles_Suplentes AS
WITH EntradasSuplentes AS (
    SELECT 
        MatchID,
        Player_Name,
        Team_Initials,
        Minuto_Evento AS Minuto_Entrada
    FROM players
    WHERE Tipo_Evento IN ('i', 'ih')
),
GolesRegistrados AS (
    SELECT 
        MatchID,
        Player_Name,
        Team_Initials,
        Minuto_Evento AS Minuto_Gol
    FROM players
    WHERE Tipo_Evento IN ('g','G','p','P')
)
SELECT 
    g.Player_Name,
    g.Team_Initials,
    COUNT(*) AS Goles_Como_Suplente
FROM GolesRegistrados g
INNER JOIN EntradasSuplentes s
    ON  g.MatchID       = s.MatchID
    AND g.Player_Name   = s.Player_Name
    AND g.Team_Initials = s.Team_Initials
    AND g.Minuto_Gol   >= s.Minuto_Entrada
GROUP BY 
    g.Player_Name,
    g.Team_Initials;
GO

-- 2. ¿Cual era el top de 5 Maximos anotadores en la historia de los Mundiales hasta brasil 2014?
CREATE VIEW vw_Top5_Goleadores AS
SELECT TOP 5
	Player_Name,
	Team_Initials,
	COUNT(*) as Total_Goles
FROM players
WHERE Tipo_Evento IN ('g','G','p','P')
GROUP BY
	Player_Name,
	Team_Initials
ORDER BY
	Total_Goles DESC;
GO


-- 3. ¿Que equipo es el que mas ha remontado partidos y termina ganandolos?
CREATE VIEW vw_Remontadas AS
WITH Ganadores AS (
    SELECT 
        MatchID,
        CASE 
            WHEN Home_Team_Goals > Away_Team_Goals THEN Home_Team_Initials
            WHEN Away_Team_Goals > Home_Team_Goals THEN Away_Team_Initials
        END AS Equipo_Ganador
    FROM matches
    WHERE Home_Team_Goals <> Away_Team_Goals
),
PrimerGol AS (
    SELECT 
        MatchID, 
        Team_Initials AS Equipo_Primer_Gol
    FROM (
        SELECT 
            MatchID, 
            Team_Initials, 
            Minuto_Evento,
            ROW_NUMBER() OVER(PARTITION BY MatchID ORDER BY Minuto_Evento ASC) AS Orden_Gol
        FROM players
        WHERE Tipo_Evento IN ('g', 'G', 'p', 'P')
    ) GolesOrdenados
    WHERE Orden_Gol = 1
)

SELECT TOP 10
    g.Equipo_Ganador AS Equipo,
    COUNT(*) AS Total_Remontadas
FROM Ganadores g
INNER JOIN PrimerGol p 
    ON g.MatchID = p.MatchID
WHERE g.Equipo_Ganador <> p.Equipo_Primer_Gol
GROUP BY 
    g.Equipo_Ganador
ORDER BY 
    Total_Remontadas DESC;
GO

-- 4. ¿Cual es la tendencia de aumento de personas en los mundiales y que prediccion hay a futuro para los siguientes 3 mundiales?
CREATE VIEW vw_Tendencia AS
SELECT 
    Year, 
    Attendance 
FROM worldcups
GO
-- 5. ¿Quien es el que mas goles ha anotado siendo capitan?
CREATE VIEW vw_GolCapitan AS
SELECT TOP 10
    Player_Name,
    Team_Initials,
    COUNT(*) AS Goles_Como_Capitan
FROM players
WHERE Tipo_Evento IN ('g', 'G', 'p', 'P')
  AND Position LIKE '%C%'
GROUP BY 
    Player_Name,
    Team_Initials
GO
