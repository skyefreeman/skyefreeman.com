# skyefreeman.com — Spec

## Overview

Personal website built with Ruby on Rails. Supports authoring and publishing posts with rich text content and file attachments.

## Models

### Post
- `title` (string)
- `author` (string)
- `deleted_at` (datetime, nullable) — soft delete marker
- `created_at`, `updated_at` (timestamps)
- `body` (ActionText rich text via `has_rich_text`)
- `header_attachment` (ActiveStorage `has_one_attached`)
- `body_attachments` (ActiveStorage `has_many_attached`)
- `tags` (has many through `taggings`)
- `tag_names` / `tag_names=` — comma-separated tag name accessors; tags created on first use if absent

### Tag
- `name` (string, unique, case-insensitive)
- `has_many :posts, through: :taggings`

### Tagging
- Join model between `Post` and `Tag`
- `post_id`, `tag_id` (foreign keys)
- Unique constraint on `[post_id, tag_id]` to prevent duplicate taggings

### Note
- `title` (string)
- `created_at`, `updated_at` (timestamps)
- `body` (ActionText rich text via `has_rich_text`)

### Idea
- `title` (text)
- `output_url` (string, optional)
- `created_at`, `updated_at` (timestamps)

## Routes

RESTful resource: `resources :posts`

| Verb   | Path                        | Action            |
|--------|-----------------------------|-------------------|
| GET    | /posts/:id                  | show              |
| GET    | /posts/new                  | new               |
| POST   | /posts                      | create            |
| GET    | /posts/:id/edit             | edit              |
| PATCH  | /posts/:id                  | update            |
| DELETE | /posts/:id                  | destroy           |
| GET    | /blog                       | blog              |
| GET    | /blog/tags                  | tags_index        |
| GET    | /blog/tags/:name            | tags_show         |
| GET    | /blog/:year                 | by_year           |
| GET    | /blog/:year/:month          | by_month          |
| GET    | /blog/:year/:month/:day     | by_day            |

RESTful resource: `resources :notes`

| Verb   | Path                | Action  |
|--------|---------------------|---------|
| GET    | /notes              | index   |
| GET    | /notes/:id          | show    |
| GET    | /notes/new          | new     |
| POST   | /notes              | create  |
| GET    | /notes/:id/edit     | edit    |
| PATCH  | /notes/:id          | update  |
| DELETE | /notes/:id          | destroy |

RESTful resource: `resources :ideas`

| Verb   | Path                | Action  |
|--------|---------------------|---------|
| GET    | /ideas              | index   |
| GET    | /ideas/:id          | show    |
| GET    | /ideas/new          | new     |
| POST   | /ideas              | create  |
| GET    | /ideas/:id/edit     | edit    |
| PATCH  | /ideas/:id          | update  |
| DELETE | /ideas/:id          | destroy |

## Views & Helpers

### Meta Tags
- `app/views/shared/_meta_tags.html.erb` — partial accepting `title`, `description`, `og_type`, `canonical_url`, `image_url` locals
- Renders standard `<meta name="description">`, canonical link, Open Graph, and Twitter Card tags
- All locals are optional; falls back gracefully when absent
- `twitter:card` is `summary_large_image` when `image_url` is present, `summary` otherwise

### PostsHelper
- `post_url_path(post)` — returns relative path (date-slug or `/posts/:id`)
- `post_full_url(post)` — returns absolute URL for canonical/OG tags
- `post_og_image_url(post)` — returns absolute URL for `header_attachment`, or `nil`

## Changelog

- Scaffolded Rails 8.1 app with PostgreSQL
- Installed ActionText (Trix editor) and ActiveStorage
- Generated Post resource with title, author, deleted_at, body (rich text), header_attachment, body_attachments
- Added PostsController with full CRUD (index, show, new, create, edit, update, destroy)
- Posts listed in descending order by created_at on index
- Removed state column from posts
- Rotated master.key; removed from source control
- Added post tagging system: Tag and Tagging models with has_many :through association on Post
- Added Tags field to post new/edit form; input is comma-separated, tags auto-created if absent
- Added /blog/tags (all tags with post counts) and /blog/tags/:name (posts for a tag) routes and views
- Added Note resource with title, body (rich text via ActionText); full CRUD behind authentication; views styled to match Posts flow
- Added Idea resource with title (text) and optional output_url; index/show public, write actions behind authentication; index displays output_url as clickable link only when present
