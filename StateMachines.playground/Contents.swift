import Foundation
import XCTest

protocol State { }

protocol StateMachineDelegate: class {
    associatedtype StateType: State
    
    func shouldTransition(from: StateType, to: StateType) -> Bool
    func didTransition(from: StateType, to: StateType)
}

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

enum ExampleState: State {
    case one
    case two
    case three
}

final class ExampleStateMachineDelegate: StateMachineDelegate {
    typealias StateType = ExampleState

    func shouldTransition(from: ExampleState, to: ExampleState) -> Bool {
        switch (from: from, to: to) {
        case (from: .one, to: .two):
            return true
        case (from: .two, to: .three):
            return true
        default:
            return false
        }
    }
    
    func didTransition(from: ExampleState, to: ExampleState) {

    }
}

final class Example {
    var delegate: ExampleStateMachineDelegate = ExampleStateMachineDelegate()

    lazy var stateMachine: StateMachine<ExampleStateMachineDelegate> = {
        let machine: StateMachine<ExampleStateMachineDelegate> = StateMachine(initialState: .one)
        machine.delegate = delegate
        
        return machine
    }()
}

class ExampleTests: XCTestCase {
    var example: Example!
    
    override func setUp() {
        super.setUp()
        
        example = Example()
    }
    
    func testShouldTransitionOneTwo() {
        example.stateMachine.state = .two
        XCTAssertEqual(example.stateMachine.state, .two)
    }
    
    func testShouldTransitionTwoThree() {
        example.stateMachine.state = .two
        example.stateMachine.state = .three
        XCTAssertEqual(example.stateMachine.state, .three)
    }
    
    func testShouldNotTransitionOneThree() {
        example.stateMachine.state = .three
        XCTAssertNotEqual(example.stateMachine.state, .three)
    }
}

class TestObserver: NSObject, XCTestObservation {
    private func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: UInt) {
        assertionFailure(description, line: lineNumber)
    }
}
let testObserver = TestObserver()
XCTestObservationCenter.shared.addTestObserver(testObserver)
ExampleTests.defaultTestSuite.run()
