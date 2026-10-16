# skyefreeman.com — Spec

## Overview

Personal website built with Ruby on Rails. Supports authoring and publishing posts with rich text content and file attachments.

## Models

### Post
- `published_at` (datetime, nullable) — nil for drafts; publishing sets the current time
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

- Removed the All posts, All links, and All games links beneath the home feed. Pagination remains deferred.

- Increased the combined home feed limit from 10 to 30 items, preserving chronological ordering and draft visibility. Updated limit coverage for mixed and post-only feeds.

- Made home-feed post titles and excerpts a single tappable link, and game titles and cartridge images a single tappable link. Metadata remains separate, with existing title styling preserved.

- Home-feed game entries now show their attached cartridge image directly beneath the title, using pixelated rendering and lazy loading. Cover attachments are preloaded for the feed.

- Moved home-feed type badges to the beginning of the date row beneath each entry, inline with its timestamp.

- Added home-feed type badges directly beneath titles: blue for blog posts, green for links, and purple for games. Badges share the archived-project shape and typography; draft status badges remain yellow.

- Home now shows the ten newest entries across posts, links, and games, interleaved by publication time for published posts and creation time for drafts, links, and games. Drafts remain restricted to signed-in users. Projects are excluded. Added links to each full listing and integration coverage for ordering, visibility, limits, and empty feeds.

- Home and blog draft entries now display their creation date and time next to the yellow DRAFT badge, with a machine-readable time element.

- Home and blog now interleave drafts by creation time with published posts by publication time, newest first. Drafts remain private to signed-in users and use the shared yellow archived-project badge styling on listings and post detail pages.

- Updated the About bio to name Engineering Manager at Duolingo as the current role and move Aura Frames into previous experience.

- Applied pixelated image rendering to game cover images on the listing and detail pages to preserve sharp pixel-art edges when scaled.

- Updated /games to show two columns above 480px and one column on smaller screens, matching /projects with light gray cards, rounded corners, padding, and spacing. Added browser layout coverage for desktop and mobile.

- Updated AGENTS.md to prohibit automatic commits and require user review and explicit approval before committing changes.

- Added upload percentage and saving feedback to new/edit game forms, disabled duplicate submission during uploads, and preserved inputs on validation, oversized upload, session, network, timeout, and server failures. Game create/update support JSON responses alongside the existing HTML flow. Added Rails integration and dependency-free JavaScript tests.

- Added Unpublish to the published post edit form, saving edits while returning the post to a draft without deleting its content, slug, tags, or attachments. Drafts remain available to signed-in users and can be republished with a new publication date. Public direct post URLs now return 404 for drafts; listings, archives, tags, and feeds exclude unpublished posts. Added integration coverage for visibility, authentication, validation, and republishing.

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
