import Foundation

class Black {
    //mandatory
    var id: Int
    var who: String
    var amount: Double
    var currency: String
    //optional
    var friendlyName: String
    var why: String
    var when: String
    
    
    init(id: Int, who: String, amount: Double, currency: String, friendlyName: String, why: String, when: String) {
        self.id = id
        self.who = who
        self.amount = amount
        self.currency = currency
        self.friendlyName = friendlyName
        self.why = why
        self.when = when
    }
    
    
}