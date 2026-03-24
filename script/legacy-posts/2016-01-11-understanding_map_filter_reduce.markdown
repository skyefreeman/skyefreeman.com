---
layout: post 
title: "Understanding Swift's SequenceType Protocol" 
date: 2016-01-11 23:36:38 
author: Skye Freeman 
categories: Programming
---

One of the great features of Swift's collection implementation is the first party support of various ["higher order"][higherOrderFunctionsLink] functions like map, filter and reduce.  When Objective-C still reigned supreme, the iOS open-source community created [their own abstractions][objectiveSugarLink] in an attempt to make Objective-C more functional.  While the community did a wonderful job of making a verbose language more terse, it never really felt like Objective-C was meant for it.  This time around however, Swift gives us built in support through the SequenceType protocol.  The [Swift Developer Library][swiftDeveloperLibraryLink] defines SequenceType as being any "type that can be iterated with a for...in loop."  This means that any collection that can be iterated over (i.e. Array, Set) can adopt the SequenceType protocol, gaining access to its useful top-level functions.  You can even adopt SequenceType within your own [custom collections][adoptingSequenceTypeLink]! 

The SequenceType protocol aims to solve a number of common problems in a functional and expressive way, making your code more readable and succinct. Here's a rundown of what SequenceType has to offer:

Say we start with a standard Swift array like so.

```swift
var numbers = [10,2,60,100]
// [10,2,60,100]
```

After passing this collection around our app, we need to manipulate it by adding a '$' sign before each number.  Easy, let's use Map.

```swift
numbers.map({"$\($0)"})
// ["$10","$2","$60","$100"]
```

What's happening here is that the whole 'numbers' array is iterated over, appending each number into a string along with a '$' sign.  The '$0' is shorthand in Swift for the first argument to this [closure][closureLink].  Let's contrast this to what it would look like without Map.

```swift
var money = [String]()
for number in numbers {
    money.append("$\(number)")
}
// ["$10","$2","$60","$100"]
```

Way more verbose.  While this is still understandable and standard code, I don't like the thought process of it.  This naive approach I tend to read as "Initialize an array called money that accepts String types, then iterate over each number in the numbers array appending a string that concatenates $ and number". Bleh.  The Map version on the other hand can be read "for each number in numbers, map $ and number to a string".

Our goal while programming should always be to write code that is easily understood. The Map function lets us easily do this by clearly conveying intent, while still remaining as succinct as possible. Lets take a look at the other instance methods of the SequenceType protocol.

Need to "filter" your array by a comparator?  Use Filter.

```swift
numbers.filter({$0 > 10})
// [60, 100]
```

What about "reducing" each number in my array to a single sum?  Go use Reduce.

```swift
numbers.reduce(0, combine: {$0 + $1})
// 172 (i.e. 10 + 2 + 60 + 100)
```

This can even be further "reduced" since operators are also methods in Swift.

```swift
numbers.reduce(0, combine: +)
// 172 (i.e. 10 + 2 + 60 + 100)
```

Lets drop the first number in numbers

```swift
numbers.dropFirst()
// [2, 60, 100]
```

Woops, I meant the last.

```swift
numbers.dropLast()
// [10, 2, 60]
```

Nevermind, the first two actually

```swift
numbers.dropFirst(2)
// [60, 100]
```

Can we check if the number 2 exists in the array? Sure.

```swift
numbers.contains(2)
// true
```

What about 10000?

```swift
numbers.contains(10000)
// false
```

Darn, lets  see if this other array matches our good old number array.

```swift
numbers.elementsEqual([10,2, 60, 100])
// true
```

Woo! What about this array?

```swift
numbers.elementsEqual([10])
// false
```

Shucks. Can we "join" all of our numbers together into one String?  Sure, but only if they are Strings in the first place.

```swift
let numberStrings = numbers.map({"\($0)"}) // Map to string values

numberStrings.joinWithSeparator(" | ")     // then join
// "10 | 2 | 60 | 100"
```

You know what, lets just print all of our numbers out, since SequenceType functions don't overwrite our mutable data.

```swift
numbers.enumerate()
// Outputs:
// 0 : 10
// 1 : 2
// 2 : 60
// 3 : 100
```

[higherOrderFunctionsLink]: https://en.wikipedia.org/wiki/Higher-order_function
[objectiveSugarLink]: https://github.com/supermarin/objectivesugar
[swiftDeveloperLibraryLink]: https://developer.apple.com/library/tvos/documentation/Swift/Reference/Swift_SequenceType_Protocol/index.html#//apple_ref/swift/intfm/SequenceType/s:FeRq_Ss12SequenceTypeqqq_S_9GeneratorSs13GeneratorType7ElementS__SsS_7flattenuRq_S_qqq_S_9GeneratorS0_7ElementS__Fq_FT_GVSs15FlattenSequenceq__
[adoptingSequenceTypeLink]: http://kelan.io/2015/swift-adopting-sequencetype/
[closureLink]: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html
