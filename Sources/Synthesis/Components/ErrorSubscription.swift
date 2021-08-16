import Combine
import Foundation

/*
 _subscription_ noun: the action of making or agreeing to make an advance payment in order to receive something

 This specialized Subscription is a part of `Combine.Subscribers` that allow for the receipt of errors
 
 Using this subscriber allows for the caller of an action to be notified if a particular action emits an error.
 
 For example: some object that wishes to be made aware of an error
 
 class SomeClass {
 
    func doSomething() {
        let action = SomeAction(connector: someConnector, kernel: someKernel)
        let errorSubscription = Subscribers.ErrorSubscription(onError: { error in print("\(error)")
        action.execute(onError: errorSubscription)
    }
 }
 */
extension Subscribers {
    struct ErrorSubscription: Subscriber {
        init(onError: @escaping (Error) -> Void) {
            self.onError = onError
        }
        
        let onError: (Error) -> Void
        let combineIdentifier: CombineIdentifier = .init()
        
        func receive(subscription: Subscription) {
            subscription.request(.max(1))
        }
        
        func receive(_ input: Error) -> Subscribers.Demand {
            onError(input)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Never>) { }
    }
}
