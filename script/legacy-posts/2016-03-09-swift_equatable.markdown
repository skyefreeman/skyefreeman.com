---
layout: post
title: "Swift's Equatable Protocol"
date: "March 9th 2016"
author: Skye Freeman
description: "The mathematical operators utilized by Swift are just functions with special names. For example, the ‘==’ operator tests equality between two types."
url_slug: swift-equatable-protocol
---
Mathematical notation provides the foundation to which programming languages are built. These universally understood symbols allow us to convey meaning and intent to our programs in a concise way. The mathematical operators utilized by Swift are just regular functions with special names. For example, the '==' operator tests equality between two types.

```swift
let a = 10
let b = 10
let c = 2

a == b // true
a == c // false
```

More specifically, ‘==‘ tests equality between two types that conform to the Equatable protocol.  In the example above we define 3 constants of type Int (which conforms to Equatable).  Other Equatable conforming types defined in Swift’s standard library are Float, Double and String [(There are many, many more)][equatable-link].

Let's see what would happen were we to check equality between two instances of a custom defined type.

```swift
struct Cat {
    let name: String
    let breed: String
}

let rex = Cat(name: "Rex", breed: "American Wirehair")
let belle = Cat(name: "Belle", breed: "American Shorthair")

rex == belle // error
```

This snippet doesn't even compile.  This is because our custom Cat struct hasn't told the compiler how two instances should be tested for equality.  Let's make Cat conform to the Equatable protocol.

```swift
struct Cat: Equatable {
    let name: String
    let breed: String
}

func ==(firstCat: Cat, secondCat: Cat) -> Bool {
    return (firstCat.name == secondCat.name) && (firstCat.breed == secondCat.breed)
}
```

We now define the rule for '==' between two Cat's to return true only if both the name and breed of the both Cat instances are the same.  Let's test '==' on our two cats one more time.

```swift
let rex = Cat(name: "Rex", breed: "American Wirehair")
let new_rex = Cat(name: "Rex", breed: "American Wirehair”)

let belle = Cat(name: "Belle", breed: "American Shorthair")

rex == belle // false
rex == new_rex // true
```

Adopting the Equatable protocol on your custom types and objects is a great way to make your code more readable and intuitive.  Don't abuse it though, the rule defined for a Equatable conforming type needs to make sense.  For instance, it's very possible that two different cats have the same name and breed, making our definition of '==' ambiguous under more complicated use cases.  It's very important to make sure that two types compare logically to avoid confusion during a projects evolution.

[equatable-link]: https://developer.apple.com/library/tvos/documentation/Swift/Reference/Swift_Equatable_Protocol/index.html#//apple_ref/swift/intf/s:PSs9Equatable
