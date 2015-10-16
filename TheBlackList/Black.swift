import Foundation

class Black {
    //mandatory
    var id: Int
    var who: String
    var amount: Double
    var currency: String
    //optional
    var why: String
    var when: String
    var imageUrl: String

    init(id: Int, who: String, amount: Double, currency: String, why: String, when: String, imageUrl: String) {
        self.id = id
        self.who = who
        self.amount = amount
        self.currency = currency
        self.why = why
        self.when = when
        self.imageUrl = imageUrl
    }
    
    init(id: Int) {
        self.id = id
        self.who = ""
        self.amount = 0
        self.currency = ""
        self.why = ""
        self.when = ""
        self.imageUrl = ""
    }
}