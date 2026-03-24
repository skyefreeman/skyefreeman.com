---
layout: post
title: "Building an iMessage App"
date: "October 5, 2022"
author: Skye Freeman
description: "A small side project in building and releasing a standalone iMessage app."
image: "/images/banner-building-an-imessage-app.jpg"
url_slug: building-an-imessage-app
---
I took a small detour the past couple of days from
[SwiftStarterKits](https://swiftstarterkits.com) to build an iMessage
app. Here's a short \"how-to\" in creating a standalone iMessage app:

## How to build an iMessage sticker pack

Technically speaking, an iMessage sticker app is straightforward. The
Xcode 'Sticker Pack App' template gets you most of the way there:

<div>

![Sticker Pack App Xcode Template
Example](/images/imessage-project-template.jpg)

Sticker Pack App Xcode Template

</div>

Decide on universal sticker sizes in the Xcode attributes inspector,
ensuring that the target images are consumable at the target size:

<div>

![Sticker Sizing Example](/images/imessage-sticker-sizing.jpg)

Sticker Sizing

</div>

Image dimensions don't need to match the target size exactly, and will
only affect the sticker dimensions that display on an end user's
iMessage chat pane. The configurable choices are denoted by keyboard
column size:

-   2 Column: 618 x 618 pixels
-   3 Column: 408 x 408 pixels
-   4 Column: 300 x 300 pixels

Assuming sticker images already exist, drag and drop them into the
Stickers \> Sticker Pack asset pane, no code required.

<div>

![Sticker drag and drop
example](/images/imessage-xcode-dragdrop.gif)

Drag and drop!

</div>

Build and run. You're good to go!

## Submitting a standalone iMessage app for App Store Review

There's very little that is different from submitting a standalone
iMessage app into the App Store from a fully fledged iOS app. You'll
need content for all the usual suspects:

-   App icons
-   App name, subtitle, and description
-   Keywords
-   Screenshots
-   App Previews (Optional)
-   Category. Set the primary category to \"Stickers\", if this is a
    standalone sticker pack.

### Adding iMessage Device Screenshots

On the App Store Connect website, when adding App Store marketing
materials you will need to submit screenshots for both the iOS Previews
and Screenshots *and* iMessage App sections. I found this odd given only
an iMessage app binary is required, but app submission is prevented
without content for each. I ultimately used the same screenshot content
for both sections, even though only the iMessage app section's
screenshots will be utilized.

Additionally, iMessage apps work out of the box on both iPhone's and
iPad's, meaning that marketing screenshots are required for both
platforms before submission. Here's the minimum required screenshot
sizes for iMessage Apps (as of 10/5/2022):

:::
<div>

6.5 inch iPhone:

-   1284 × 2778 pixels (Portrait)
-   2778 x 1284 pixels (Landscape)
-   Possible device types: iPhone 14 Plus, iPhone 13 Pro Max, iPhone 12
    Pro Max, iPhone 11 Pro Max.

</div>

<div>

5.5 inch iPhone:

-   1242 × 2208 pixels (Portrait)
-   2208 x 1242 pixels (Landscape)
-   Possible device types: iPhone 8 Plus, iPhone 7 Plus, iPhone 6s Plus.

</div>

<div>

12.9 inch iPad (2nd gen device frames):

-   2048 x 2732 pixels (Portrait)
-   2732 x 2048 pixels (Landscape)
-   Possible device types: iPad Pro (2nd gen).

</div>

<div>

12.9 inch iPad (3rd gen and above device frames):

-   2048 x 2732 pixels (Portrait)
-   2732 x 2048 pixels (Landscape)
-   Possible device types: iPad Pro (3rd gen), iPad Pro (4th gen).

</div>
:::

Screenshots for other devices are naturally allowed, however the above
devices sizes are the base minimum required. Each will be used as the
basis when viewing in the App Store while on a different device, with a
matching aspect ratio. A full list of devices and screenshots
specifications can be found
[here](https://help.apple.com/app-store-connect/#/devd274dd925) on
Apple's App Store Connect help website.
