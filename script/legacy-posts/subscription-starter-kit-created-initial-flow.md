---
layout: post
title: "Subscription Starter Kit: Initial App Layout and SwiftUI Navigation"
date: "May 9, 2023"
author: Skye Freeman
description: "Development of the SwiftUI Subscription Starter Kit is under way. First steps are getting the home and settings screens in place, plus some basic navigation controls."
image: "/images/banner-subscription-starter-kit-initial-layout.jpg"
url_slug: subscription-starter-kit-created-initial-flow
---
With the [planning and ideation done](/blog/subscription-starter-kit-swiftui-boilerplate), I've set to work on an iOS starter kit that will provide all of the infrastructure needed for a cloud enabled, subscription ready native app with reusable foundational features. 

To have a concrete usecase in mind while building this generalized kit, I've decided to build a cloud enabled todo list app. Afterwards I'll work backwards and remove app specific logic and UI, getting the kit ready for *your* projects. 

Starting with building the basic screen structure and navigation controls, this app will have two primary flows, "home" and "settings". Settings is modally presented via the [SFSymbols](https://developer.apple.com/sf-symbols/) "gear" icon:

<div>
<video class="mx-auto max-w-md rounded-lg"
	   controls>
	<source
		src="/images/subscription-initial-navigation.mp4" 
		type="video/mp4">
Your browser does not support video playback.
</video>
</div>

Simple enough. 

Next, I threw together some generalized SwiftUI components to mimic the layout of a [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink), ensuring selection logic is untethered to a navigation stack. Here I've stubbed out these initial section row inside a [SwiftUI List](https://developer.apple.com/documentation/swiftui/list):


<figure class="">
<img class="mx-auto max-w-md rounded-lg"
src="/images/subscription-initial-settings-layout.jpg"
alt="SwiftUI Subscription settings screen layout.">
<figcaption class="text-sm text-center text-gray-500 dark:text-gray-400">
	Settings list controls for company info and support url's.
</figcaption>
</figure>

Extending some interactivity to the Settings page, all of the existing cells either trigger a modally presented view, or push a view onto the navigation stack:

<div>
<video class="mx-auto max-w-md rounded-lg"
	   width="720" height="720" controls>
	<source
		src="/images/subscription-initial-settings-navigation.mp4" 
		type="video/mp4">
Your browser does not support video playback.
</video>
</div>

Great, first steps out of the way. 

## Next Steps

Each iteration of [Swift Starter Kits](https://swiftstarterkits.com) has brought focus to the toolkit. Starting with the authentication and Firebase integration last year, I've slowly improved and expanded the foundation, making it more robust and generalized. The negative side-effect of this approach was lack of focus, but this product release is going to address this exact problem.

I'll be focusing next on getting app functionality in place, followed by a bunch more settings, debug, and infrastructure additions. 
