# skyefreeman.com

Personal website built with Ruby on Rails.

## Requirements

- Ruby 3.4.5
- PostgreSQL

## Setup

```bash
bundle install
rails db:create db:migrate
```

## Running the app

```bash
bin/dev
```

## Running tests

```bash
rails test
```

Run the upload controller tests with Node.js 20 or newer (no npm install needed):

```bash
node --test test/javascript/*.mjs
```

## Game uploads

New and edited games show upload progress followed by a saving status. Save
is disabled while a request is in progress. Validation, upload size, session,
server, and network failures appear in the form without clearing selected
files or entered values. Uploads time out after ten minutes. After a timeout
or connection failure, check the Games page before retrying because the
server may already have saved the game.

The production proxy must allow the combined size of the cover image and
game packages. Upload progress does not increase the server's upload limit.

## Publishing posts

Signed-in users can save drafts and publish posts. To return a published
post to a draft, open **Edit Post** and select **Unpublish**. This saves
the form changes and removes the post from public pages and the feed.
Visitors receive a 404 at both the direct post URL and its old dated URL.
The post remains accessible to signed-in users and can be published again;
republishing sets a new publication date and may change its dated URL.

## Loading fixture data

```bash
rails db:fixtures:load
```
