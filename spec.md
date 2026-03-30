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
- `tag_names` / `tag_names=` — convenience accessors for comma-separated tag names

### Tag
- `name` (string, unique, case-insensitive)
- `has_many :posts, through: :taggings`

### Tagging
- Join model between `Post` and `Tag`
- `post_id`, `tag_id` (foreign keys)
- Unique constraint on `[post_id, tag_id]` to prevent duplicate taggings

## Routes

RESTful resource: `resources :posts`

| Verb   | Path             | Action  |
|--------|------------------|---------|
| GET    | /posts           | index   |
| GET    | /posts/:id       | show    |
| GET    | /posts/new       | new     |
| POST   | /posts           | create  |
| GET    | /posts/:id/edit  | edit    |
| PATCH  | /posts/:id       | update  |
| DELETE | /posts/:id       | destroy |

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
