---
layout: post 
title: Swift - Comparable
date: 2016-04-03 17:35:51 
author: Skye Freeman 
categories: Programming
---

My last blog post I wrote briefly about [Swift's Equatable protocol][equatable-link], which allows the use of == and != between custom defined types. Naturally, I feel its fitting to talk a bit about Equatable's close relative -- the [Comparable protocol][comparable-link].

Adopting the Comparable protocol allows for a custom type to define its own rule for the <, <=, >, >= infix operators.  Before we see this in action, lets first describe an object that models a user's bank account.

```swift
struct BankAccount {
    let identifier: Int
    var balance: Double
}
```

Here we create a struct called BankAccount that requires a identifier constant of type Int, and a balance variable of type Double. Next, let's try defining and comparing two separate BankAccount objects.

```swift
let smallAccount = BankAccount(identifier: 123, balance: 100.0)
let largeAccount = BankAccount(identifier: 123, balance: 1000.0)

smallAccount < largeAccount // error
```

Here you should receive an error saying: "Binary operator '<' cannot be applied to two 'BankAccount' operands".  This is because our BankAccount struct has not defined how two BankAccount instances should be compared.  Lets fix this by making BankAccount conform to Comparable.

```swift
struct BankAccount: Comparable {
    let identifier: Int
    var balance: Double
}

func <(lhs: BankAccount, rhs: BankAccount) -> Bool {
    return lhs.balance < rhs.balance
}
```

Now we define '<' between two BankAccount instances to return true if the left hand side BankAccount's balance is less than the right hand sides balance. Notice how we only need to define the '<' operator.  By doing this, Swift can infer the definition of >, >= and <=, without requiring individual functions describing each.

There's still one problem before we have a program that builds.  It turns out that Comparable inherits directly from the Equatable protocol, which means we must provide a definition to the '==' operator as well.

```swift
struct BankAccount: Comparable {
    let identifier: Int
    let balance: Double
}

func ==(lhs: BankAccount, rhs: BankAccount) -> Bool {
    return lhs.balance == rhs.balance
}
 
func <(lhs: BankAccount, rhs: BankAccount) -> Bool {
    return lhs.balance < rhs.balance
}
```

Awesome. Now let's test out some BankAccount comparisons one more time.

```swift
let smallAccount = BankAccount(identifier: 123, balance: 10000.0)
let largeAccount = BankAccount(identifier: 123, balance: 100000.0)

smallAccount < largeAccount  // true
smallAccount <= largeAccount // true

smallAccount > largeAccount  // false
smallAccount >= largeAccount // false

smallAccount != largeAccount // true
smallAccount == largeAccount // false
```

Keep in mind though, its up to you, the developer, to make sure that adopting the Comparable protocol does in fact make your code base more readable/maintainable. Without adopting the comparable protocol, we could have instead written:

```swift
let smallAccount = BankAccount(identifier: 123, balance: 10000.0)
let largeAccount = BankAccount(identifier: 123, balance: 100000.0)

smallAccount.balance < largeAccount.balance // true
```

Which is perfectly valid, and one could argue is more understandable than comparing the objects directly. Be sure that adopting either the Comparable or Equatable protocol is in fact the right design decision, rather than just defaulting to the most 'terse' option.

[equatable-link]: http://skyefreeman.io/programming/2016/03/09/swift_equatable.html
[comparable-link]: https://developer.apple.com/library/watchos/documentation/Swift/Reference/Swift_Comparable_Protocol/index.html
