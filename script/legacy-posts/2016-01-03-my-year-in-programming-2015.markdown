---
layout: post 
title: "My Year in Programming" 
date: 2016-01-03 16:01:33 
author: Skye Freeman 
categories: Personal
---

Starting a blog has been on my todo list for a while now, I can finally check it off!  I thought that a good place to start might be a look back at my year in programming. Being a new year, there's no better time for reflection.

Right out of the gate in early 2015, as part of the team at Happy Medium Interactive we shipped [Junganew: A Herd of Sounds][junganewlink], a speech and language adventure iPad app for children learning their sounds.  Being my first "real" gig, the entire process was a paramount learning experience.  I had began work on the app as a freelancer in mid 2014, contracted to help fix memory issues.  After taking my first peek at the codebase something was immediately apparent, the app at this stage was never going to be shippable.  I didn't realize it immediately, but I had walked right into a [coding horror][codinghorror].  The project was almost a year into development, already past deadline and had little budget left.  I had inherited a codebase with multi thousand line view controllers, no documentation and no tests.  Most of the methods were more than 100 lines, and variables were given descriptive names like 'a' and ‘b'.

Right away I informed the team that this was essentially un-refactorable, and would take longer than starting from scratch.  After some discussion, they agreed and I took over as the sole developer on the project.  A couple months of hard work later finally got the product into the app store, followed quickly by a free version.  It was by no means perfect, but something I was sufficiently proud of.  Also a ton of kudos goes to the rest of the [Junganew team][junganewteam], the artwork, audio, animation and writing were outstanding.

In late July I received a call from my step-mother, asking if I'd be willing to donate some of my time to build a companion app to [Geva Theatre Center’s][gevatheatre] Journey to the Son Festival, celebrating the life and legacy of blues legend [Son House][sonhousewiki].  Having grown up around theatre, and having a general soft spot for the arts, I of course said yes.  Within a two - three week time period of just nights and weekends, I put together an interactive time line of Son House's life.  Which was complimented with an informational guide, helping the user plan out which landmarks they were going to visit in Rochester, NY during the festival. The end product was called [Son House Trail][sonhousetrail] It was a simple app to use, but useful nonetheless.  I also gave my first ever [interview][sonhouseinterview] as a developer, cool!

In the summer, again with Happy Medium Interactive, I worked on a project with City of Hope Medical Center to develop a smoking cessation solution for mobile.  Having only a few months, we got right to work.  The result was [Taper][taperapp], which consisted of an iOS app, Apple Watch extension and web app.  My experience building each component of the platform was humbling as I was constantly kept outside my comfort zone. Having never built an Apple Watch extension or web app, I was forced to learn a considerable amount in a very short period of time. The WatchOS SDK was more a challenge in keeping it simple, whereas the web portion required teaching myself enough Javascript to hit the ground running.  It was a tough, yet rewarding project.  The app is still in a closed beta, but I hope it will become available to the public some time in 2016.

A few months back I was contracted to build a neat social app that aims to ease the process of finding new things to do, with the help of your trusted friends.  Unfortunately I can't talk much more about it until the public marketing campaign begins.  But it was a fun project to work on, getting the chance to utilize both Parse and the Google Places API. This cool piece of software should be in the App Store in early 2016.

Lastly, my pet side project for he past few months has been a nice little reader for [Hacker News][hackernews].  What started as a weekend hack for personal use has turned into something I plan on shipping.  The idea came out of reading a story or two on the Hacker News website on my phone every morning with coffee.  The mobile website experience wasn't great, and there wasn't any way to store interesting links for later. (I mean, you could add it to the safari reading list, but what fun is that).  So I decided to hack out a quick solution using their Firebase REST API that I've been using ever since.  All thats left before shipping is finishing the redesign and some light refactoring!  I've also done the whole project [in the open][hackernewsrepo], if anyone would like to contribute or follow along.

In review, I had a wild second year developing software professionally.  It's such a rewarding experience to open a code base from a few months ago and be shocked at how far I've come since.  I'm so excited at the prospect of continuing to improve as a developer in the new year, and continuing to ship those apps!

[junganewlink]: http://junganew.com
[junganewteam]: http://junganew.com/team/
[codinghorror]: http://blog.codinghorror.com
[gevatheatre]: http://www.gevatheatre.org
[sonhousewiki]: https://en.wikipedia.org/wiki/Son_House
[sonhousetrail]: https://itunes.apple.com/us/app/son-house-trail/id1027450271?mt=8
[sonhouseinterview]: https://gevajournal.wordpress.com/2015/08/24/getting-ready-to-celebrate-the-son-house-trail-app/
[taperapp]: http://www.taperapp.com
[hackernews]: https://news.ycombinator.com
[hackernewsrepo]: https://github.com/skyefreeman/HackerNewz
