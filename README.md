# Netflix-SQL-Analysis.
Netflix-SQL-Analysis est un projet d’analyse du catalogue Netflix. Il inclut la préparation des données (nettoyage et normalisation), la création d’un entrepôt relationnel, et des analyses descriptives réalisées avec SAS et SQL  pour identifier les tendances et insights sur films et séries.


Netflix-SQL-Analysis

Présentation

Netflix-SQL-Analysis est un projet d’analyse du catalogue Netflix. Il se concentre sur la normalisation et le nettoyage des données, la création d’un entrepôt de données relationnel, et la réalisation d’analyses descriptives avancées via SAS et SQL. Le projet permet d’extraire des insights sur les films et séries, les réalisateurs, acteurs, genres et pays de production.

Fonctionnalités clés

Import des données depuis Excel (netflix_titles.xlsx) avec PROC IMPORT.

Nettoyage et préparation des données (release_year, date_added, duration, etc.).

Création d’un schéma relationnel complet :

Table principale : titles

Tables de dimensions : ratings, directors, actors, countries, genres

Tables de liaison : title_directors, title_cast, title_countries, title_genres

Analyses descriptives avancées :

Nombre de films et séries par année

Durée moyenne des films

Top 10 des réalisateurs et acteurs

Distribution et diversité des genres

Films récemment ajoutés

Pays producteurs les plus prolifiques

Réalisateurs et acteurs avec la plus grande diversité de genres et castings

Export des résultats vers Word via ODS (.rtf).

Optimisation des performances : index sur les colonnes clés et vues SQL pour analyses fréquentes.

Installation

Installer SAS sur votre machine.

Placer netflix_titles.xlsx dans un répertoire connu et mettre à jour le chemin dans le script PROC IMPORT.

Ouvrir SAS et exécuter le script principal (netflix_analysis.sas).

Utilisation

Importer et nettoyer les données :

proc import datafile="C:\chemin\netflix_titles.xlsx"
    out=netflix_raw
    DBMS=xlsx REPLACE;
    getnames=yes;
run;


Créer les tables normalisées (fact, dimensions, liens) via PROC SQL.

Insérer les données nettoyées (netflix_clean) dans les tables.

Exécuter les requêtes descriptives pour générer les insights.

Exporter les résultats avec ODS :

ods rtf file="output.doc" style=htmlblue;
...requêtes SQL...
ods rtf close;

Schéma de la base de données
titles
  ├─ title_id (PK)
  ├─ show_id
  ├─ type
  ├─ title
  ├─ date_added
  ├─ release_year
  ├─ duration
  ├─ description
  └─ rating_id (FK)

ratings, directors, actors, countries, genres

title_directors (title_id, director_id)
title_cast (title_id, actor_id)
title_countries (title_id, country_id)
title_genres (title_id, genre_id)

Optimisations

Index sur release_year, type, rating_id pour accélérer les requêtes.

Vues SQL pour les analyses fréquentes, par exemple v_top_directors.

Auteur
Freudel AZOKLY







Netflix-SQL-Analysis
Overview

Netflix-SQL-Analysis is a project designed to analyze the Netflix catalog. It focuses on data cleaning, normalization, and structuring into a relational database, and performs descriptive analyses using SAS and SQL. The project extracts insights on movies and series, directors, actors, genres, and countries of production.

Features

Import data from Excel (netflix_titles.xlsx) using PROC IMPORT.

Normalize and clean raw data.

Create a relational data warehouse with:

Fact table: titles

Dimension tables: ratings, directors, actors, countries, genres

Link tables: title_directors, title_cast, title_countries, title_genres

Perform descriptive analyses:

Number of movies and series per year

Average movie duration

Top 10 directors and actors

Distribution of genres

Recently added titles

Countries producing the most movies

Directors with diverse genres and cast

Export results to Word via ODS (.rtf).

Performance optimization with indexes and views.

Installation

Install SAS on your machine.

Place netflix_titles.xlsx in a known directory (update the file path in PROC IMPORT).

Open SAS and run dashboard.sas (or the main script file).

Usage

Import and clean the data:

proc import datafile="C:\path\netflix_titles.xlsx"
    out=netflix_raw
    DBMS=xlsx REPLACE;
    getnames=yes;
run;


Create normalized tables (titles, dimensions, links) via PROC SQL.

Clean and prepare data (netflix_clean).

Insert data into fact and dimension tables.

Run descriptive queries to generate insights.

Export results with ODS:

ods rtf file="output.doc" style=htmlblue;
...queries...
ods rtf close;

Database Schema
titles
  ├─ title_id (PK)
  ├─ show_id
  ├─ type
  ├─ title
  ├─ date_added
  ├─ release_year
  ├─ duration
  ├─ description
  └─ rating_id (FK)

ratings
directors
actors
countries
genres

title_directors (title_id, director_id)
title_cast (title_id, actor_id)
title_countries (title_id, country_id)
title_genres (title_id, genre_id)

Key Analyses

Trends of movies and series by year.

Top 10 directors and actors by number of works.

Genre distribution and diversity of directors/actors.

Most productive countries.

Longest movies and movies with richest cast.

Optimization

Indexes on release_year, type, rating_id.

Views for frequently queried results (v_top_directors).

Author

Freudel AZOKLY
