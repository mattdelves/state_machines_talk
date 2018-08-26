# State machines are your friend

---

# Matt Delves (マット)

## iOS and macOS developer

---

# Let's being with a story

---

What this talk is about

 - What
 - Why
 - How

---

# What are state machines?

---

"... a mathematical model of computation. It is an abstract machine that can be in exactly one of a finite number of states at any given time." - Wikipedia

---

# Let's break that down a bit

---

# Model of computation

---

# Finite number of states

---

# Only one at a given time

---

---

# Why use a state machine?

---

# Discrete states

---

# Predicated transitions

---

# A visualisation tool

---

# Simplification of business rules

---

# Communication of requirements

---

---

# How to use state machines

---

# The role of state within an app

---

# View state

``` swift
protocol ViewState {
  case empty
  case loaded([DataModel])
  case loading
  case error
}
```

---

# The state

```swift
protocol State { }
```

---

# The Delegate

```swift
protocol StateMachineDelegate: class {
  associatedtype StateType: State

  func shouldTransition(from: StateType, to: StateType) -> Bool
  func didTransition(from: StateType, to: StateType)
}
```

---

# The Machine

```swift
class StateMachine<DelegateType: StateMachineDelegate> {
  weak var delegate: DelegateType?

  init(initialState: DelegateType.StateType) {
    currentState = initialState
  }

  private var currentState: DelegateType.StateType

  var state: DelegateType.StateType {
    get {
      return currentState
    }
    set {
      guard let delegate = delegate, delegate.shouldTransition(from: self.state, to: newValue) else { return }

      let oldValue = currentState
      currentState = newValue
      delegate.didTransition(from: oldValue, to: newValue)
    }
  }
}
```

---

---

# Examples

 - Onboarding Screen
 - Form Entry
 - Business Rules

---

---

# Onboarding Screen

---

```swift
enum OnboardingFlow: State {
    case initial
    case signup
    case pushNotifications
    case locationServices
}
```

---

```swift
func shouldTransition(from: OnboardingFlow, to: OnboardingFlow) -> Bool {
  switch (from: from, to: to) {
  case (from: _, to: .initial): return true
  case (from: .pushnotifications, to: .locationServices): return true
  case (from: .locationServices, to: .pushNotifications): return true
  case (from: .pushNotifications, to: .signup): return true
  default: return false
  }
}
```

---

```swift
extension OnboardingFlow {
  var segue: String {
    switch self {
    case .initial: return "initial"
    case .pushNotifications: return "pushNotifications"
    case .locationServices: return "locationServices"
    case .signup: return "signup"
    }
  }
}
```

```swift
func didTransition(from: OnboardingFlow, to: OnboardingFlow) {
  performSegue(withIdentifier: to.segue, sender: self)
}
```
---

# Form Entry

---

``` swift
protocol FormState: State {
  case empty
  case error
  case input(String)
  case validated
  case submitted
}
```

---

# Remote content

---

``` swift

protocol ViewState {
  case empty
  case loaded([DataModel])
  case loading
  case error
}

```

---

``` swift
func shouldTransition(from: OnboardingFlow, to: OnboardingFlow) -> Bool {
  switch (from: from, to: to) {
  case (from: _, to: .loading): return true
  case (from: .loading, to: .loaded): return true
  case (from: .loading, to: .empty): return true
  case (from: .loading, to: .error): return true
  default: return false
  }
}
```

---

``` swift
func didTransition(from: OnboardingFlow, to: OnboardingFlow) {
  switch (from: from, to: to) {
  case let (from: .loading, to: .loaded(data)):
    dataSource = data
    tableView.reloadData()
  case (from: .loading, to: .empty):
    displayEmpty()
  case let (from: .loading, to: error(error)):
    display(error: error)
  default:
    break
  }
}
```

---

# Business Rules

---

## This is the real fun stuff

---

## But it's really no different

---

``` swift
enum BusinessTime: State {
  case presented
  case dataEntry
  case validating
  case fetching
  case simpleRule
  case complexRule
  case edgeCase
}
```

---

# Thanks for coming

GitHub repo of talk and playground is available at https://github.com/mattdelves/state\_machines\_talk

---
