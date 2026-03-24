---
layout: post
title: "Firebase iOS App Template Launch"
date: "December 12, 2022"
author: Skye Freeman
description: "An overdue progress update on SwiftStarterKits. I'll talk about shipping the latest starter kit, Firebase edge-case handling, and some new tools I've picked up."
---
I'm long overdue for an update on
[SwiftStarterKits](https://swiftstarterkits.com/). My previous post,
[designing a free app
template](https://skyefreeman.com/blog/swift-starter-kits-designing-firebase-starter-kit)
was nearly two months ago! Towards the end of that piece, I mention an
estimate on building the already planned 'SwiftUI Firebase Template'
as being two weeks. Boy was I wrong.

Well, flash forward 6 weeks, [it's
shipped](https://swiftstarterkits.com/products/ios-firebase-starter-template)!

The final product ended up having far more features than I originally
envisioned. I had planned for login, account creation, a settings page
and an onboarding screen, each with essential but minimal feature sets.
Each step of the way, I recognized glaring holes of functionally that
didn't feel natural to leave out, especially for a product whose value
proposition is \"saving time and money\" while building your shippable
MVP.

## Build settings and build automation

Besides the expansion in product scope, I also chose to add a slew of
customizable build settings to an xcconfig file which ships with the
product
([PewPewTheSpells](https://pewpewthespells.com/blog/xcconfig_guide.html)
has an excellent guide to xcconfig files). I realized that there had to
be an easy way to document which build settings need changing once you
open your Xcode project the first time. I wish .xcodeproj settings came
with an xcconfig by default, which would make maintanance easier and
more portable. Once automated testing and beta builds exist in a
projects lifecycle, having an xcconfig file managing your build
configuration(s) goes a long way to make iOS CI/CD manageable.

Expanding on the subject of build automation is definitely a medium term
goal of [SwiftStarterKits](https://swiftstarterkits.com/). A couple more
projects out the door, and some iteration on making these templates
portable (I have my sights on adding iOS, iPad, Mac support by default
on all templates), then I plan to focus on CI/CD support.

## Firebase integration

Besides expanded product scope, there were several snags while
integrating the Firebase SDK. One flow in particular (changing a user's
email) required a ton of finagling with undocumentated Firebase
functions to achieve the envisioned state. A brief overview: It turns
out that requiring email verification before accepting an email change
(which I think should be standard behaviour) results in a
de-authentication from the Firebase instance. Instead I needed to
implement an alternate API for changing a user's email, without
requiring verification first, THEN initiating an email verification
request after the fact.

Non-happy path flows like this are a perfect example of why software
estimation can be so difficult. This wasn't a feature in the original
spec, but was essential as soon as I used the software I had built. Once
I looked under the hood to make it happen, I found several
inconsistencies that required cleanup and special handling. At least the
final product handles this (and other implementation specifics) nicely,
so customers don't have to.

## A dash of marketing

Besides building the Firebase Starter Kit, I've also done a fair amount
of marketing and website work in the past month. In no particular order:

1.  Created a [blog for
    SwiftStarterKits](https://swiftstarterkits.com/blog), which is a
    space for how-to's, guides, and product release announcements.
2.  Wrote the [first SwiftStarterKits
    guide](https://swiftstarterkits.com/blog/configure-firebase), about
    integrating a Firebase backend into our latest app templates.
3.  Created a fun little custom [404
    page](https://swiftstarterkits.com/blahhhhhh).
4.  Started using UberSuggest for daily webpage scans, which has helped
    track down SEO problems both on this website and on
    [SwiftStarterKits](https://swiftstarterkits.com/) (I recommend it!).
5.  Designed social media banners for all
    [SwiftStarterKits](https://swiftstarterkits.com/) web pages, along
    with a nice little Sketch template to make it easy to have a custom
    branded banner for each blog post.
6.  Designed some nice looking device screenshot templates with [morflax
    things](https://things.morflax.com) (This tool came at a great time.
    It's excellent for creating device mockups, and they support all
    current Apple devices, plus the 3D editor is very good).

## What's next?

This upcoming week I'll be spending some time writing, doing some
website work, and prototyping SwiftUI components. Here are my specific
goals for the week:

1.  Publish a blog post on SwiftStarterKits, in which I already have a
    draft of an introductory article about the latest Firebase app
    template. I want to discuss use-cases, who the product is for, and
    answer some higher level questions. I might use some of this copy
    around the website, too.
2.  Update the SwiftStarterKits hosted
    [Terms](https://swiftstarterkits.com/terms) +
    [License](https://swiftstarterkits.com/license) pages to match the
    changes I made in the most recent app template. I really need to
    align these. Right now I have an HTML version, and a markdown
    version that ships alongside template downloads, but they don't
    share a common source. Maybe acceptable duplication for now, but
    I'll think about this.
3.  Create a SwiftStarterKits changelog page, so I can transparently
    keep track of product changes.
4.  Prototype some SwiftUI components! Before I dive into another full
    blown app template, I'd like to shrink the iteration time a bit and
    work towards a suite of paid components, which can plug into the
    free template.
