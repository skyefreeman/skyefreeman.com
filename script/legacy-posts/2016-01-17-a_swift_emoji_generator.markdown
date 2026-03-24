---
layout: post
title: "String's, Emoji's and Generator's."
date: "January 17th, 2016"
author: Skye Freeman
description: "A core feature of any programming languages is the ability to model and manipulate text. When defining a variable that represents text, we traditionally call it a string. In Swift, strings are a series of encoding-independent unicode characters."
url_slug: strings-emojis-and-generators-in-swift
---

A core feature of any programming languages is the ability to model and manipulate text.  When defining a variable that represents text, we traditionally call it a string. In Swift,  strings are a series of encoding-independent unicode characters.  This means that any character can be accessed directly by their unicode representation and vice-versa. For example, the hexadecimal unicode representation for the capital letter 'A' is '0x41', which can be accessed in a Swift string like so:

```swift
var unicodeLetterA = "\u{41}"
var regularLetterA = "A"

unicodeLetterA == regularLetterA 
// true
```

This same functionality extends to all unicode characters, including emoji's. You can even define variables in Swift using emoji characters! Not necessarily useful, but fun none the less. Now how does one find unicode emoji representations without looking them up manually?  Doing a few searches online, you can find that there are a couple of distinct ranges of unicode hex values that pertain to emoji characters.  This is what I came up with:

```html
0x1F601 -- 0x1F64F
0x2702  -- 0x27B0
0x1F680 -- 0x1F6C0
0x1F600 -- 0x1F636
0x1F681 -- 0x1F6C5
0x1F30D -- 0x1F567
```

Armed with these values, I set out to build a code generator that spits out a Swift struct of all emoji characters retrievable by their corresponding name value. My goal was to be able to retrieve an emoji string like this:

```swift
Emoji.wearyCatFace
```

Before I could do this however, I first needed to build a way to parse all the emoji characters.  Starting at the top, I packed the hex value's into an array of range collections:

```swift
let emojiRanges0 = 0x1F601...0x1F64F
let emojiRanges1 = 0x2702...0x27B0
let emojiRanges2 = 0x1F680...0x1F6C0
let emojiRanges3 = 0x1F600...0x1F636
let emojiRanges4 = 0x1F681...0x1F6C5
let emojiRanges5 = 0x1F30D...0x1F567

let emojiArray = [emojiRanges0,emojiRanges1,emojiRanges2,emojiRanges3,emojiRanges4,emojiRanges5]
```

Before I get outraged emails asking why not make my code more swifty and place the ranges directly into an array like so:

```swift
let emojiArray = [
    0x1F601...0x1F64F,
    0x2702...0x27B0,
    0x1F680...0x1F6C0,
    0x1F600...0x1F636,
    0x1F681...0x1F6C5,
    0x1F30D...0x1F567
]
```

Xcode would hang indefinitely while compiling, but for some reason separating them into variables first would work fine.  If anybody knows why shoot me an email.  Moving on, we have our ranges packed into an array and ready to go.  Looping over each hex number, we retrieve the emoji character by converting it into its [Unicode Scalar Value][unicodeScalarLink]. Swift makes this easy:

```swift
for i in range { 	   	      
    let emojiChar = String(UnicodeScalar(i))   	  	     
}
```

Great! We have our emoji characters.  Next we wanted to label each emoji with its corresponding Unicode name.  Doing some digging through Apple's docs, I found that the [CFMutableString type][cfMutableStringLink] has a method called [CFStringTransform][cfStringTransformLink].  Here's the transformation in action:

```swift
private func unicodeNameForString(string: String) -> String {
    let cfString = NSMutableString(string: String(string)) as CFMutableString
    var range = CFRangeMake(0, CFStringGetLength(cfString))
    CFStringTransform(cfString, &range, kCFStringTransformToUnicodeName, false)
    return cfString as String
}
```

Here's how this function works.  Using the passed in String value, we convert this into a CFMutableString type using its Cocoa Foundation counterpart NSMutableString.  Next we retrieve the CFRange of the original string (0 - number of characters).  Using our converted CFMutableString and CFRange pointer we apply them to CFStringTransform along with our transformation type [kCFStringTransformToUnicodeName][cfStringTransformsLink] and a boolean value of whether we want to use the inverse transform operation.  Lastly we return our CFString after converting it back into a String type.

Phew, after putting all of this together we have our Dictionary of Emoji values:

```swift
var dictArray: [String:String] = [:]
for range in rangeArray {
    for i in range {
    	let emojiChar = String(UnicodeScalar(i))
	let emojiName =  unicodeNameForString(emojiChar)).toCamelCase()
	 // toCamelCase is a String extension that trims and formats the unicode string
	
	emojiDict[emojiChar] = emojiName
    }
}
```

Great, the hard part is done.  We have a huge dictionary collection of emoji characters as keys to each character name.  Now let's turn this into something we can actually use by making a code generator! First lets encapsulate this into a separate class called EmojiCodeGenerator:

```swift
class EmojiCodeGenerator {
}
```

The Cocoa library offers access directly to the file system using the NSFileManager class.  Let's create a NSFileManager constant and call it fileManager, initializing it with the default manager already in use by the filesystem.

```swift
class EmojiCodeGenerator {
    let fileManager: NSFileManager
    
    init() {
        fileManager = NSFileManager.defaultManager()
     }
}
```

Now we need a reference to the directory that we want to generate our new file to, lets create a new constant called desktopDirectory of type NSURL, and initialize it to the desktop directory.

```swift
class EmojiCodeGenerator {
    let fileManager: NSFileManager
    let desktopDirectory: NSURL
    
    init() {
        fileManager = NSFileManager.defaultManager()
        desktopDirectory = try! fileManager.URLForDirectory(.DesktopDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
}
```

Okay, now were all prepped to generate some emoji's.  Let's create a new function for the EmojiCodeGenerator class called generate, which takes a fileName String along with a Dictionary (of emoji's!).

```swift
func generate(fileName: String, emojiDict: Dictionary<String,String>) {
}
```

Now we build a URL with the new file along with the complete directory path, then pass it to our NSFileManager, creating our new file.

```swift
func generate(fileName: String, emojiDict: Dictionary<String,String>) {
     let fileDestination = desktopDirectory.URLByAppendingPathComponent(fileName + ".swift").relativePath
     fileManager.createFileAtPath(fileDestination!, contents: nil, attributes: nil)
}
```

Next comes the fruit of all our labors, we need to construct the text of our newly generated code file. First we create a variable called codeString and set it to the initial contents of our file (\n denotes a new line).

```swift
func generate(fileName: String, emojiDict: Dictionary<String,String>) {

     ...

     var codeString = "\n\nimport Foundation\n\npublic struct Emoji {"
}
```

Once written this will look like:

```swift
import Foundation

public struct Emoji {
```


Now let's append each of our emoji key value pairs to codeString:

```swift
func generate(fileName: String, emojiDict: Dictionary<String,String>) {

     ...

     var codeString = "\n\nimport Foundation\n\npublic struct Emoji {"
     for key in emojiDict.keys {
     	 codeString += "\n static public let \(dict[key]!) = \"\(key)\""
     }
     codeString += "\n}"
}
```

This loops through every single dictionary key passed into our function, appending a new line followed by a static constant definition named to our Unicode 'name' values, and set to equal the corresponding emoji character.  Lastly the codeString variable is capped off with a closing curly brace.

The last step is to write our final string to the file we created previously, giving us the final result:

```swift
func generate(fileName: String, emojiDict: Dictionary<String,String>) {

     // Create a new file
     let fileDestination = desktopDirectory.URLByAppendingPathComponent(fileName + ".swift").relativePath
     fileManager.createFileAtPath(fileDestination!, contents: nil, attributes: nil)

     // build the code string
     var codeString = "\n\nimport Foundation\n\npublic struct Emoji {"
     for key in emojiDict.keys {
     	 codeString += "\n static public let \(dict[key]!) = \"\(key)\""
     }
     codeString += "\n}"

     // write to file
     print(codeString)
     try! codeString.writeToFile(fileDestination!, atomically: true, encoding: NSUTF8StringEncoding)
}
```

Hooray we just built nearly 1000 emoji constants!  The final contents of which [can be viewed here][emojiConstantLink].

After covering quite a lot let's recap real quick.  We learned a little about how Swift models text and Unicode, how to dig into text using the Foundation libraries, and most importantly how to create a code generator!  Code generator's are a terrific tool in the developer's arsenal for automating rote tasks. Could you imagine putting together a comprehensive list of Emoji's manually one at a time?! Bleh.

The full project is available on [github][emojiBuilderLink] for your perusal. The file that was generated is also now available on [github][emojiConstantLink] and as a cocoapod.

[unicodeScalarLink]: http://www.unicode.org/glossary/#unicode_scalar_value
[cfMutableStringLink]: https://developer.apple.com/library/mac/documentation/CoreFoundation/Reference/CFMutableStringRef/
[cfStringTransformLink]: https://developer.apple.com/library/prerelease/ios/documentation/CoreFoundation/Reference/CFMutableStringRef/index.html#//apple_ref/c/func/CFStringTransform
[emojiConstantLink]: https://github.com/skyefreeman/EmojiConstants/blob/master/Pod/Classes/Emoji.swift
[emojiBuilderLink]: https://github.com/skyefreeman/EmojiBuilder
[cfStringTransformsLink]: https://developer.apple.com/library/ios/documentation/CoreFoundation/Reference/CFMutableStringRef/#//apple_ref/doc/constant_group/Transform_Identifiers_for_CFStringTransform
[emojiConstantLink]: https://github.com/skyefreeman/EmojiConstants
