proc import datafile="C:\Users\Freudel AZOKLY\Documents\SQL\netflix_titles.xlsx" 
    out=netflix_raw 
    DBMS=xlsx REPLACE;
    getnames=yes;
run;

/* Création des tables normalisées */

/* Table principale titles */

proc sql;
    create table titles (
        title_id num primary key,
        show_id char(10),
        type char(10),
        title varchar(255),
        date_added date,
        release_year num,
        duration varchar(50),
        description varchar(1000),
        rating_id num
    );
quit;
proc contents data=titles; 
run;
/* Tables de dimensions */
proc sql;
    create table ratings (
        rating_id num primary key,
        classification char(10)
    );

    create table directors (
        director_id num primary key,
        name varchar(255)
    );

    create table actors (
        actor_id num primary key,
        name varchar(255)
    );

    create table countries (
        country_id num primary key,
        name varchar(255)
    );

    create table genres (
        genre_id num primary key,
        name varchar(255)
    );
quit;
/* Tables de liaison */
proc sql;
    create table title_directors (
        title_id NUMERIC,
        director_id NUMERIC
    );
    alter table title_directors
        add constraint pk_title_directors primary key (title_id, director_id);

    create table title_cast (
        title_id NUMERIC,
        actor_id NUMERIC
    );
    alter table title_cast
        add constraint pk_title_cast primary key (title_id, actor_id);

    create table title_countries (
        title_id NUMERIC,
        country_id NUMERIC
    );
    alter table title_countries
        add constraint pk_title_countries primary key (title_id, country_id);

    create table title_genres (
        title_id NUMERIC,
        genre_id NUMERIC
    );
    alter table title_genres
        add constraint pk_title_genres primary key (title_id, genre_id);
quit;

/* Nettoyage et insertion des données */
data netflix_clean;
    set netflix_raw;
    
    /* Supprime les espaces dans release_year */
    release_year_clean = compress(release_year, ' ');

    /* Supprime les espaces et extrait la partie date */
    date_added_clean = strip(scan(date_added, 1, ','));

    /* Convertit la date en format SAS */
    date_added_num = input(date_added_clean, anydtdte.);

    /* Applique le format date9. */
    format date_added_num date9.;

    /* Supprime la variable date_added existante */
    drop date_added_clean date_added;

    /* Renomme la variable date_added_num en date_added */
    rename date_added_num = date_added;
run;


/* Insertion dans titles */

proc contents data=titles;
run;

proc contents data=ratings;
run;
proc print data=netflix_clean(obs=10);
run;
/* Insertion dans titles */

proc sql;
    insert into titles
        (title_id, show_id, type, title, date_added, release_year, duration, description, rating_id)
    select
        monotonic() as title_id,
        substr(show_id, 1, 10) as show_id,  /* Tronquer à 10 caractères */
        substr(type, 1, 10) as type,  /* Tronquer à 10 caractères */
        title,
        date_added as date_added,  /* Conserver la variable date_added en tant que date SAS */
        input(release_year_clean, 8.) as release_year,  /* Utiliser release_year_clean */
        substr(duration, 1, 50) as duration,  /* Tronquer à 50 caractères */
        description,
        (select rating_id
         from ratings
         where ratings.classification = substr(netflix_clean.rating, 1, 10)) as rating_id  /* Tronquer rating */
    from netflix_clean;
quit;

/* Remplissage des tables de dimensions */
proc sql;
    insert into ratings (rating_id, classification)
    select distinct monotonic() as rating_id, rating 
    from netflix_clean;

    insert into directors (director_id, name)
    select distinct monotonic() as director_id, director 
    from netflix_clean where director is not missing;

    insert into actors (actor_id, name)
    select distinct monotonic() as actor_id, scan(cast, 1, ',') /* Extraction premier acteur */
    from netflix_clean where cast is not missing;

    insert into countries (country_id, name)
    select distinct monotonic() as country_id, scan(country, 1, ',') 
    from netflix_clean where country is not missing;

    insert into genres (genre_id, name)
    select distinct monotonic() as genre_id, scan(listed_in, 1, ',') 
    from netflix_clean where listed_in is not missing;
quit;

/* Remplissage des tables de liaison */
proc sql;
    insert into title_directors (title_id, director_id)
    select t.title_id, d.director_id
    from netflix_clean n
    inner join titles t on n.show_id = t.show_id
    inner join directors d on n.director = d.name;

    insert into title_cast (title_id, actor_id)
    select t.title_id, a.actor_id
    from netflix_clean n
    inner join titles t on n.show_id = t.show_id
    inner join actors a on scan(n.cast, 1, ',') = a.name;

    insert into title_countries (title_id, country_id)
    select t.title_id, c.country_id
    from netflix_clean n
    inner join titles t on n.show_id = t.show_id
    inner join countries c on scan(n.country, 1, ',') = c.name;

    insert into title_genres (title_id, genre_id)
    select t.title_id, g.genre_id
    from netflix_clean n
    inner join titles t on n.show_id = t.show_id
    inner join genres g on scan(n.listed_in, 1, ',') = g.name;
quit;

/* Définir le fichier de sortie Word */
ods rtf file="D:\M1_SAS\logit_multinomial_boules.doc" style=htmlblue;

/* Requêtes d'analyses */
/* Nombre de films et séries par année */
proc sql;
    select release_year, type, count(*) as count
    from titles
    group by release_year, type
    order by release_year desc;
quit;

/* Durée moyenne des films */
proc sql;
    select avg(input(scan(duration, 1, ' '), best.)) as avg_duration
    from titles
    where type = 'Movie';
quit;

/* Top 10 des réalisateurs les plus présents */
proc sql outobs=10;
    select d.name, count(*) as num_films
    from title_directors td
    inner join directors d on td.director_id = d.director_id
    group by d.name
    order by num_films desc;
quit;

/* Distribution des genres */
proc sql;
    select g.name, count(*) as count
    from title_genres tg
    inner join genres g on tg.genre_id = g.genre_id
    group by g.name
    order by count desc;
quit;
/* Nombre de films et de séries ayant été ajoutés chaque année */
proc sql;
    select release_year, type, count(*) as num_shows
    from titles
    group by release_year, type
    order by release_year desc;
quit;
/* film le plus long */  
proc sql outobs=1;
    select title, duration
    from titles
    where type = 'Movie'
    order by input(scan(duration, 1, ' '), best.) desc;
quit;
/* les 10 films avec la description la plus longue */ 
proc sql outobs=10;
    select title, length(description) as desc_length
    from titles
    where type = 'Movie'
    order by desc_length desc;
quit;
/* films ayant été ajoutés récemment  */
proc sql;
    select title, date_added
    from titles
    where type = 'Movie'
    and date_added >= today() - 30; /* Les films ajoutés dans les 30 derniers jours */
quit;
/* Les 10 pays qui produisent le plus de films */
proc sql outobs=10;
    select c.name as country, count(*) as num_movies
    from title_countries tc
    inner join titles t on tc.title_id = t.title_id
    inner join countries c on tc.country_id = c.country_id
    where t.type = 'Movie'
    group by c.name
    order by num_movies desc;
quit;
/* les 10 acteurs les plus présents */
proc sql outobs=10;
    select a.name, count(*) as num_titles
    from title_cast tc
    inner join actors a on tc.actor_id = a.actor_id
    group by a.name
    order by num_titles desc;
quit;
/* les 10 premiers réalisateurs ayant travaillé sur plusieurs genres différents */
proc sql outobs=10;
    select d.name, count(distinct g.name) as num_genres
    from title_directors td
    inner join directors d on td.director_id = d.director_id
    inner join title_genres tg on td.title_id = tg.title_id
    inner join genres g on tg.genre_id = g.genre_id
    group by d.name
    order by num_genres desc;
quit;
/* les 10 premiers acteurs ayant joué dans des films de plusieurs genres */
proc sql outobs=10;
    select a.name, count(distinct g.name) as num_genres
    from title_cast tc
    inner join actors a on tc.actor_id = a.actor_id
    inner join title_genres tg on tc.title_id = tg.title_id
    inner join genres g on tg.genre_id = g.genre_id
    group by a.name
    order by num_genres desc;
quit;
/* les réalisateurs ayant la plus grande diversité de casting. */

proc sql outobs=10;
    select d.name, count(distinct a.name) as num_actors
    from title_directors td
    inner join directors d on td.director_id = d.director_id
    inner join title_cast tc on td.title_id = tc.title_id
    inner join actors a on tc.actor_id = a.actor_id
    group by d.name
    order by num_actors desc;
quit;
/* les titres avec les castings les plus riches */

proc sql outobs=10;
    select t.title, count(*) as num_actors
    from title_cast tc
    inner join titles t on tc.title_id = t.title_id
    group by t.title
    order by num_actors desc;
quit;
/*  les réalisateurs spécialisés dans un genre*/
proc sql outobs=10;
    select d.name, g.name as genre, count(*) as num_titles
    from title_directors td
    inner join directors d on td.director_id = d.director_id
    inner join title_genres tg on td.title_id = tg.title_id
    inner join genres g on tg.genre_id = g.genre_id
    group by d.name, g.name
    order by num_titles desc;
quit;

/* Fermer le fichier Word */
ods rtf close;



/* Optimisation */
 /* Ajout d’index pour améliorer la performance des requêtes */
proc sql;
    create index release_year on titles (release_year);
    create index type on titles (type);
    create index rating_id on titles (rating_id);
quit;

/* Création de vues pour analyses fréquentes */
proc sql;
    create view v_top_directors as
    select d.name, count(*) as num_films
    from title_directors td
    inner join directors d on td.director_id = d.director_id
    group by d.name
    order by num_films desc;
quit;








