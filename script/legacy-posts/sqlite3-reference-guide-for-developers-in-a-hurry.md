---
layout: post
title: "Practical SQLite3 Reference For Developers In A Hurry"
date: "April 26, 2023"
author: Skye Freeman
description: "As it is with all computer related things, I occasionally find myself needing a reminder on how to achieve certain database related tasks. Let this be a living reference for working with SQLite3. No guarantees are made regarding completeness."
image: "/images/banner-sqlite3-reference-for-developers.jpg"
url_slug: sqlite3-reference-guide-for-developers-in-a-hurry
---
SQLite is a terrific, lightweight, general purpose tool. But, as it is with all computer related things, I occasionally find myself needing a reminder on how to achieve certain database related tasks. 

Let this be a living reference for working with SQLite3. No guarantees are made regarding completeness.

## Installing SQLite3 [#](#installing-sqlite3)

With Homebrew:

```bash
brew install sqlite3
```

With MacPorts:
```
port install sqlite3
```

Or, from a precompiled binary:

- Download from the [SQLite Download Page](https://www.sqlite.org/download.html).

## How to create a database [#](#how-to-create-a-sqlite-database)

```bash
sqlite3 awesome-project-database.db
```

## How to create a table [#](#how-to-create-a-sqlite-table)

```sqlite3
create table user (
	name text not null,
	email text not null unique
);
```

## How to get all rows in a table [#](#how-to-get-all-rows-from-a-sqlite-table)

```sqlite3
select * 
	from user;
```

## How to get a row from a table [#](#how-to-get-a-row-from-a-sqlite-table)

```sqlite3
select email
	from user
	where name = 'Skye';
```

## How to insert a row into a table [#](#how-to-insert-a-row-into-a-sqlite-table)

```sqlite3
insert into user (name, email)
	values('Skye', 'skye@swiftstarterkits.com');
```

## How to update a row in a table [#](#how-to-update-a-row-in-a-sqlite-table)

```sqlite3
update user
	set email = mega-super-great-email@icloud.com'
	where name = 'Skye';
```

## How to delete a row in a table [#](#how-to-delete-a-row-in-a-sqlite-table)

```sqlite3
delete from user
	where name = 'Skye';
```
