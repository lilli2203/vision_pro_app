
import Foundation
import Observation

enum FlowStatey{
    case one
    case two
    case three
}


@Observable
class ViewModel{
    var flowState = FlowStatey.one
    var isPanel: Bool = false
}
