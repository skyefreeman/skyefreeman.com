---
layout: post
title: "SwiftStarterKits' RevenueCat Integration: The Story So Far."
date: "May 3, 2023"
author: Skye Freeman
description: "Shifting gears back to product work, SwiftStarterKits is going to soon deliver on its promise of amplifying development of subscription apps with the help of RevenueCat."
image: "/images/banner-initial-revenuecat-integration.jpg"
url_slug: initial-swiftstarterkits-revenuecat-integration
---
With the first version of the [SwiftStarterKits documentation](/blog/shipped-swiftstarterkits-documentation-v1) published, I'd like to shift gears to improving the SwiftStarterKits core product. While the existing documentation needs more investment, I simultaneously started marketing product features that *don't currently exist*. 

Thankfully (?), I haven't made any new sales since publishing some new marketing copy alongside the [documentation](https://swiftstarterkits.com/documentation/introduction), but I do feel a little iffy about making promises that I haven't delivered on quite yet.

## Medium Term Product Goals

I've slowly consolidated the original vision for SwiftStarterKits from "starter kits for many types of iOS apps", to "starter kit for subscription iOS apps". It's been a necessary transition for focusing the marketing and product strategy. At the start, it felt that I was trying to build a product for too many people, but in reality wasn't solving a problem for anybody. 

Smaller scope, focused messaging. After a few more product releases I'm itching to build some apps, dog-fooding the SwiftStarterKits toolchain internally. 

The medium term plan:

- Provide a starting point for in-app subscriptions.
- Provide scripted tooling for generating new projects quickly. Currently, creating a new project with SwiftStarterKits and customizing it is cumbersome.

With both of these problems solved, the marketing copy and product will once again be in sync.

## Enter, RevenueCat

With just a couple hours of work, I have a generic implementation of RevenueCat integrated, with all the bells and whistles for offline mock transaction testing.

<figure class="mx-auto">
<img class="max-w-full h-auto rounded-lg"
src="/images/revenue-cat-mock-transaction.jpg"
alt="SwiftStarterKits has a RevenueCat integration">
<figcaption class="text-sm text-center text-gray-500 dark:text-gray-400">
SwiftStarterKits has a working RevenueCat integration!
</figcaption>
</figure>

Why use RevenueCat rather than the native StoreKit? Ease of implementation, cross-platform purchase support, amazing docs, no data lock-in. The common theme for SwiftStarterKits so far has been to fully embrace the native iOS platform, while ensuring that business data is portable. The same goes for using Firebase over CloudKit. If developers are going to build a business on top of SwiftStarterKits, I'd like to leave the option to integrate Web and Android platforms down the road. 

Again, I'm bullish on native software experiences as a whole, they simply can't be matched by cross-platform tech. If you want an incredible experience, you can do no wrong staying as close to the platform as possible. But for solutions to data storage, analytics, authentication, payments, you may as well leave the option to grow alongside your business.



