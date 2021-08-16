import Combine
import Foundation

/*
 noun: a defined structure for the processing or display of data

 These objects provide definitions on how to present data
 
 For example: suppose some source will emit `Date` values, however they should be displayed in a localized format
 
 let dateFormat: Format<Date, String> = Format(format: { date in return "localized string" })
 dateFormat.applyFormatting(from: someDateSource)
 
 The apply formatting method returns a publisher itself allowing this to be chained in a subscription
 */
public struct Format<T, V>
{
    public init(format: @escaping (T) -> V) {
        self.format = format
    }
    
    public typealias FormattedOutput = AnyPublisher<V, Never>
    
    let format: (T) -> V
    
    /// The apply formatting method returns a publisher itself allowing this to be chained in a subscription
    public func applyFormatting<P>(from source: P) -> FormattedOutput
    where P: Publisher,
          P.Output == T,
          P.Failure == Never
    {
        source
            .map(format)
            .eraseToAnyPublisher()
    }
}

/*
 noun: a defined structure for the processing or display of data

 These objects provide definitions on how to present data
 
 Convenience method that allows for passing a format object into a publisher chain.
 
 For example:
 
 let format: Format<Int, String> = Format(format: { number in "\(number)" })
 [1,2,3,4,5]
    .publisher
    .formatUsing(format)
    .sink(receiveValue: { print($0) })
 */
extension Publisher {
    /// Allows for the publisher chain to take a format parameter
    public func formatUsing<FormatOutput>(_ format: Format<Output, FormatOutput>) -> AnyPublisher<FormatOutput, Failure>
    where Failure == Never
    {
        format.applyFormatting(from: self)
    }
}
