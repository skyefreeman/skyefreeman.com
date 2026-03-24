---
layout: post
title: "Designing an Upcoming SwiftUI App Template"
date: "October 14, 2022"
author: Skye Freeman
description: "A short design exploration, while brainstorming the first free SwiftStarterKits app template."
---
After my previous brainstorm about [next steps for
SwiftStarterKits](/blog/swift-starter-kits-mini-pivot) , I'm now
working towards a completely free and open source app template, focusing
on the boring parts that aren't usually business differentiators
(login, signup, password recovery, etc).

I quickly threw together a design this morning in
[Sketch](https://www.sketch.com) , taking inspiration from several
popular apps:

::: space-y-2
![Onboarding and login
layout](/images/ios-firebase-template-onboarding-design.jpeg)

Onboarding and login
:::

::: space-y-2
![Account creation and password reset
layout](/images/ios-firebase-template-signup-design.jpeg)

Account creation and password reset
:::

::: space-y-2
![Home page and settings
layout](/images/ios-firebase-template-home-design.jpeg)

Home page and settings
:::

Pretty straightforward. These are necessary screens for the majority of
apps which require any form of user authentication.

One point I'd like to highlight from these designs are the
\"onboarding\" cells. Rather than merely providing stubbed data which
developers will need to remove upon download, these cells can provide a
guided on-device walkthrough. This can sit alongside the documentation
that ships with the template, and can facilitate the setup experience as
you tinker with the code base for the first time.

This app template is going to implement several parts of the [Firebase
SDK](https://github.com/firebase/firebase-ios-sdk) , making it easy to
get started and ship immediately without rolling your own backend. If
you already have your own backend, or want to roll your own, it will be
straight forward to rip out the Firebase integration and adapt it to a
separate data source.

6 screens, 20-ish UI components (I'll have an exact number once I build
this out), and lots of documentation. I'll be sure to update this post
with links to the codebase and product page once it's done. I'm
estimating 2 weeks.
