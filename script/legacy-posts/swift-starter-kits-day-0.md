---
layout: post
title: "Day 0 of Building a Software Business"
date: "September 11, 2022"
author: Skye Freeman
description: "Building an app template and mobile app infrastructure business, and my goal to be transparent about it."
---
I've been working on a project in my spare time called
[SwiftStarterKits](https://swiftstarterkits.com). It's shipped,
functional, and pre-revenue. What exists so far is the bare minimum that
I figured constituted a viable business.

In the spirit of transparency, I'd like to move development of the
business to an open communication style. Where I document my progress
building a software company from the ground up and share it publically.
I'll talk about metrics, code, marketing strategy, SEO, and generally
what I'm working on from day to day.

I started this endeavor about a month ago, so the declaration \"from the
ground up\" is a little untrue. Here's an overview of what I've done
so far:

## Choosing a business

1.  When choosing a business to get started on, I kicked around tons of
    ideas for far too long (years), including many half baked prototypes
    and thrown out experiments. I came to the conclusion that this
    pattern of false starts was just procrastination disguised as due
    diligence. I ultimately forced myself to choose something with an
    existing market and existing competitors.
2.  The initial vision for
    [SwiftStarterKits](https://swiftstarterkits.com) : \"Pre-made
    software templates, but for native iOS apps\". Wordpress and other
    web based companies have offered pre-made templates for years. The
    same business model applied to mobile apps seems to have far fewer
    competitors, most of which are offering solutions also using web
    based technologies.
3.  I set to work on a website after snagging the domain
    ([SwiftStarterKits](https://swiftstarterkits.com) seemed like a
    fitting domain that described the business well), with the plan that
    I'd get some infrastructure in place without any iOS app templates
    first.

## Building an MVP

1.  I set up a new server on my existing VPS instance hosted by
    [Linode](https://linode.com) (Which this site is also running on).
    Traffic is routed through an [NGINX](https://nginx.com) reverse
    proxy, and forwarded to the
    [SwiftStarterKits](https://swiftstarterkits.com) server.
2.  The [SwiftStarterKits](https://swiftstarterkits.com) project itself
    is a single Git repository, with two subdirectories:
    \"starterkits-web\" and \"starterkits-ios\". One houses the website
    and server infrastructure, and the other the iOS template projects
    and shareable components, respectively.
3.  The server is built completely with Common Lisp, backed by the
    excellent [Caveman2 web
    framework](https://github.com/fukamachi/caveman) and serving dynamic
    content created using the [Djula](https://github.com/mmontone/djula)
    templating engine (based on Python's venerable Django templating
    engine). Layout and styling is handled directly within HTML using
    [TailwindCSS](https://tailwindcss.com). Javascript is generated
    using [Parenscript](https://parenscript.common-lisp.dev) , the Lisp
    to JS transpiler (It's really really cool, but I'll talk about
    this another time).
4.  SQLite3 for storage, wrapped by the
    [CL-DBI](https://github.com/fukamachi/cl-dbi) package for portable
    database interactions.
5.  On my VPS, server processes are started/restarted automatically
    using **systemctl**, and logs are monitored using **journalctl**.
6.  I'm doing deployment the old fashion way: Push to Github, SSH into
    the VPS, pull from Github and restart the server process. These
    steps are wrapped in a single shell script, then hotkeyed in my
    Emacs configuration.
7.  Basic uptime monitoring is done via
    [UptimeRobot](https://uptimerobot.com). Currently using the free
    plan. This service quickly notifies me when the service goes down
    for whatever reason.
8.  For analytics, I'm using
    [SimpleAnalytics](https://simpleanalytics.com) and paying for the
    yearly plan. Definitely worth the investment, allowing for anonymous
    tracking that respects user privacy.
9.  For emails, I wrote a small wrapper around the
    [Sendgrid](https://sendgrid.com) API. Emails can be scheduled and
    sent from the Common Lisp repl.
10. For payments, I've integrated the [Stripe](https://stripe.com)
    payments API, and hooked up a webhook to notify my server when a
    payment goes through.
11. For product delivery, I'm storing zipped Xcode projects in a AWS S3
    bucket, and emailing users a dynamic download link upon receiving a
    payment webhook. This will probably need to be revisited in the
    future, since I haven't built user authentication into
    [SwiftStarterKits](https://swiftstarterkits.com) quite yet (As a
    result, self-service redownloading of previously purchased templates
    is unsupported right now). I figure this is a non-problem at the
    moment, given I can handle this manually if emailed by customers.
12. On the iOS side of things, the MVP template is a fully functional
    app that integrates all popular third party authentication providers
    (Google, Apple, Facebook, etc). With much of the user management
    boilerplate built out, a login page, app onboarding, and a cohesive
    architecture that is easily extendable. Additionally, I've included
    the foundations of a reusable design system implementation, with
    sematic color and component names.
13. With a purchase/download, customers receive the complete Xcode
    project, with source files, assets, documentation for getting set
    up, and a straight forward license of what you can/can't do with
    the project (Ship it, but please don't resell it as your own
    template). I'm including a license and terms along every download,
    but is also a hard copy of the license that I'm hosting [on the
    website](https://swiftstarterkits.com/license). While the product is
    \"Xcode project templates\", customers are really buying a license
    to use the packaged source code. Maybe I sell different license
    types with varying usage terms in the future (I.E. offer an
    enterprise license with an added support package)?
14. Once the MVP template was finished, I spent some time factoring out
    all the reusable bits into a \"Default Template\". Which I'm using
    as a more sane starting point for upcoming iOS work.
15. I'm building out templates using UIKit, but plan to adopt SwiftUI
    where it makes sense. I'm of the opinion that UIKit still has its
    place at the core of a production ready app, and SwiftUI can be
    adopted iteratively while providing out of the box support for using
    both technologies in unison.

## What's next?

My immediate roadmap consists of three things:

1.  Working on a dedicated product page (The only existing template has
    a tiny overview on the homepage, which doesn't give any space for
    upselling usecases and features).
2.  Working on a small overhaul of the home page, to make room for a
    grid based catalogue of products.
3.  Working on a free template, which can provide a better foundation
    for upselling paid templates.

Lots to do! I plan to be as transparent as I can about what I'm
building and why. If and when we get some sales, you'll be the first to
hear about it.
