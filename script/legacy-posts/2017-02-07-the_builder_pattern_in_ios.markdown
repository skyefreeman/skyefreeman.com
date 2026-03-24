---
layout: post 
title: "iOS: The Builder Pattern"
date: 2017-02-07 08:49:02 
author: Skye Freeman 
categories: Programming
---

Some of the most involved and repetitive code we write is the instantiation and configuration of objects. So why ever do it more than once? As an objects interface grows, the amount of code needed to instantiate the same object externally will grow equally. This increases the possibility of inconsistencies between similar objects, and obfuscates the task at hand.

One solution to this problem is inheritance, abstracting away configuration behind the facade of a new class. Sometimes this may be the answer. But why add an unnecessary layer of complexity by growing our class hierarchy vertically, when we can grow it horizontally. What's more, managing a new subclass for each variation in a super class's construction can become a real pain in the ass. We don't want to add more data types to work with than we have to.

My favorite solution to this problem? [The builder pattern][builder-link]

Essentially, a builder allows us to abstract away instantiation behind a new interface, with the added benefit of allowing the organization of similar objects in the same place. 

For example, let's start by modeling a phone object:

```swift
struct Phone {
    let manufacturer: String
    let operatingSystem: String
    let model: String
    let year: Int
    let color: UIColor
}
```

Great, now let's say we are creating an application that displays a list of phones. We'll need a view controller that can contain our phone objects for presentation:

```swift
/* A spoon full of sugar ... */
extension Array {
    mutating func append(_ newElements: Element...) {
        for element in newElements {
            append(element)
        }
    }
}

class PhoneViewController: UITableViewController {
    
    var phones = [Phone]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blackIphone7Plus = Phone(
            manufacturer: "Apple",
            operatingSystem: "iOS",
            model: "7 Plus",
            year: 2016,
            color: UIColor.black
        )
        
        let whiteSamsungGalaxyS7 = Phone(
            manufacturer: "Samsung",
            operatingSystem: "Android",
            model: "Galaxy S7",
            year: 2016,
            color: UIColor.white
        )
        
        phones.append(blackIphone7Plus, whiteSamsungGalaxyS7)

	// setup our data source, cells, etc...
    }
}
```

For simplicity we only have two types of smart phones in existence, iPhone's and Android phones. Here we've created these two variation of our `Phone` model, added them to an array, and now they're ready for presentation.

But how can we make this better? We don't want to duplicate the instantiation of these same `Phone` objects in the future, and we definitly don't want to create an iPhone or Android subclass (A struct protects us from this, but inheritance would be an option if we were using a class). So what do we do? Let's make a builder!

```swift
class PhoneBuilder {

    static func iPhone7Plus(color: UIColor) -> Phone {
        return Phone(
            manufacturer: "Apple",
            operatingSystem: "iOS",
            model: "7 Plus",
            year: 2016,
            color: color
        )
    }
    
    static func samsungGalaxyS7(color: UIColor) -> Phone {
        return Phone(
            manufacturer: "Samsung",
            operatingSystem: "Android",
            model: "Galaxy S7",
            year: 2016,
            color: color
        )
    }
}
```

Introducing a `PhoneBuilder` ensures each variation of `Phone` is contained in a single place, while also making sure setup occurs in exactly the same way every time. This minimizes duplication, enforces consistency, and leaves flexibility for the future. What does our view controller look like now?

```swift
class PhoneViewController: UITableViewController {
    
    var phones = [Phone]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phones.append(
            iPhone7Plus(color: UIColor.black),
            samsungGalaxyS7(color: UIColor.white)
        )
    }
}
```

Slick, we can do even better though. Let's add a container to our builder that will hold every variation of smartphone, and instantiate them all in one shot.  Providing an even higher level of abstraction.

```swift
class PhoneBuilder {

    static var smartPhones: [Phone] {
        return [
            iPhone7Plus(color: UIColor.black),
            samsungGalaxyS7(color: UIColor.white)
        ]
    }
    
    static func iPhone7Plus(color: UIColor) -> Phone {
        return Phone(
            manufacturer: "Apple",
            operatingSystem: "iOS",
            model: "7 Plus",
            year: 2016,
            color: color
        )
    }
    
    static func samsungGalaxyS7(color: UIColor) -> Phone {
        return Phone(
            manufacturer: "Samsung",
            operatingSystem: "Android",
            model: "Galaxy S7",
            year: 2016,
            color: color
        )
    }
}
```

Perfect, we've even given our container of phone objects a more descriptive name: `smartPhones`. Letting our external objects know exacly what kind of phone's they will be recieving. One more peak at our final, ultra lean view controller:

```swift
class PhoneViewController: UITableViewController {
    
    let phones: [Phone] = PhoneBuilder.smartPhones
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```

Simple, obvious, with the added bonus of allowing for `phones` to become immutable, simplifying our solution exponentially.

So, when is the time right for a builder?

- An object has a large and obfuscated interface.
- An object is instantiated in pieces, multiple times, in various locations.
- A specific instance of an object needs a better name.
- Massive View Controller.

The beauty in builders is that they can be as flexible or as rigid as you want, and can lead to a tremendous reduction in repetition in your code base.

[builder-link]: https://en.wikipedia.org/wiki/Builder_pattern
