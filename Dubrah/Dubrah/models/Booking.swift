//
//  Booking.swift
//  Dubrah
//
//  Created by mohammed ali on 23/12/2025.
//

import Foundation

enum BookingStatus: String, Codable {
    case incoming = "incoming"
    case pending = "pending"
    case accepted = "accepted"
    case completed = "completed"
    case rejected = "rejected"
}

struct Booking: Codable {
    let userName: String
    let date: String
    let time: String
    let service: String
    let paid: String
    let status: BookingStatus
    
    // For system icon image (dummy)
    var profileImage: String {
        return "person.circle.fill"
    }
}
