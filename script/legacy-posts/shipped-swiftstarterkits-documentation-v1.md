---
layout: post
title: "Shipped SwiftStarterKits Documentation"
date: "May 1, 2023"
author: Skye Freeman
description: "There's finally a starting point for documentation and guides on using SwiftStarterKits effectively."
image: "/images/banner-shipped-swiftstarterkits-documentation.jpg"
url_slug: shipped-swiftstarterkits-documentation-v1
---
I've recently been working on building out a documentation system for SwiftStarterKits, which I write about in detail [here](/blog/writing-a-documentation-system) and [here](/blog/building-a-documentation-system-with-common-lisp-and-pandoc).

Flash forward a week and the first version of this is shipped! It's minimal and straight to the point, rendered fully on the server.

<figure class="mx-auto">
  <img class="max-w-full h-auto rounded-lg"
       src="/images/swiftstarterkits-documentation-v1.jpg"
       alt="SwiftStarterKits documentation was shipped.">
  <figcaption class="text-sm text-center text-gray-500 dark:text-gray-400">
	The first version of SwiftStarterKits' documentation has been shipped.
  </figcaption>
</figure>

Reiterating my previous discussions on this topic, SwiftStarterKits has been sorely missing guides on using the starter kit and its various integrations. For a developer focused business, documentation is essentially part of the core product. This is a pretty good start I think.

## Please write some docs

The layers of complexity to building software cannot be understated, and to write a system that provides a *serious add in value* there needs to be a certain level of automated support. From experience, developers tend to assume their systems are obvious on the outset, but usually the opposite is true. 

No matter how obvious it may seem, 3 things need to be answered about a software system as soon as possible in you docs:

1. How do I get it? A direct binary install? A package manager command? Do I clone the repo directly?
2. What is the least amount of knowledge that I need to use it?
3. What else does this system do? Expand on the core experience, only after basic setup is complete.

Don't make things too complicate at first, but please, explain what the software does, and how to use it.

## Next Steps

Sidebar aside, I plan to expand on these docs in the coming weeks:

- Project creation.
- Creating new modules.
- Integration specific how-to's (Firebase, RevenueCat, deeplinking, push notifications, etc).
- An API reference.

Plus I feel behind on product work, gotta carve out more iOS time this week.

