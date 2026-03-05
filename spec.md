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

## Changelog

- Scaffolded Rails 8.1 app with PostgreSQL
- Installed ActionText (Trix editor) and ActiveStorage
- Generated Post resource with title, author, deleted_at, body (rich text), header_attachment, body_attachments
- Added PostsController with full CRUD (index, show, new, create, edit, update, destroy)
- Posts listed in descending order by created_at on index
- Removed state column from posts
- Rotated master.key; removed from source control
