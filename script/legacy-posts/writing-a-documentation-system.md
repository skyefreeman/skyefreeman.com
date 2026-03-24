---
layout: post
title: "Working on a Documentation System for SwiftStarterKits"
date: "April 24, 2023"
author: Skye Freeman
description: "SwiftStarterKits is slowly but surely getting docs and developer focused guides."
---
Since the first customers purchased a SwiftStarterKits license, the most frequent feedback I've received has been to improve documentation. So that's what I'm focusing on.

Documentation can mean several things though. Am I documenting the classes and objects of the system, or writing guides that provide solutions to specific problems? Both are valuable, but lets focus on the beginner story of SwiftStarterKits first. 

## First we crawl.

Priority will be guiding customers through the setup experience. It should be obvious at a glance how to:

- Download the starter kit.
- Install dependencies.
- Build and run the project for the first time.
- Compile the local documentation reference. (with [DocC](https://developer.apple.com/documentation/docc)).
- Integrate your own Apple Developer ID, RevenueCat and Firebase API tokens.
- Create new projects using the SwiftStarterKits workspace as a base.
- Receive and integrate starter kit updates.

That should hopefully cover the most common questions, ensuring everyone starts from the same spot before making the kit their own.

## Then we take our first steps.

Once the basics are published, I'll document some specifics about the system:

- Project architectural overview.
- Module architectural overview (The whole system is designed around "modules", but I don't explain this anywhere).
- Building and designing new modules.

This should provide enough context to start building effectively on top of the SwiftStarterKits system.

## Then we run.

SwiftStarterKits will be in a much better place once I get all the above published. After this, I'll focus on problem specific guides:

- How to store data locally.
- How to store data externally (cloud storage using Firebase).
- How to fetch data from an external data source (API requests and networking).
- How to initiate an in-app purchase or subscription.
- How to send and receive push notifications.
- How to manage and change themes globally.
- How to add analytics to your features.
- How to A/B test features.
- How to upload beta and release builds through TestFlight.
- How to get ready to release to the App Store.
- How to monitor for crashes in production
- How to localize and internationalize your app.
- How to write effect tests.
- How to set up CI/CD and build automation.

This covers a wide spectrum of problems that SwiftStarterKits aims to solve. Having the coverage of these guides is definitely a long term goal, and a fair amount of product work needs to happen first before they are relevent. I'm pivoting the next phase of product work to be focused on building documentation first. Let's coin a new term, "Documentation Driven Development".

Lots to do! I'll eventually host an API reference on [The SwiftStarterKits website](https://swiftstarterkits.com), but for now I see it as secondary to everything else just listed given that customers already have access to it locally.


