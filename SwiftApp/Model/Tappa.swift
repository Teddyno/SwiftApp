import SwiftUI

struct Tappa: Identifiable, Equatable {
    var id = UUID()
    var nome: String
    var descr: String
    var oraArrivo: String
    var foto: Image
    var maps: String
} 