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
