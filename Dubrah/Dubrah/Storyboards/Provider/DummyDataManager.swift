//
//  DummyDataManager.swift
//  Dubrah
//
//  Created by mohammed ali on 23/12/2025.
//

import Foundation

class DummyDataManager {
    
    static let shared = DummyDataManager()
    
    private init() {}
    
    // Get all bookings
    func getAllBookings() -> [Booking] {
        return [
            // My Bookings (pending/accepted)
            Booking(
                userName: "Adam Kareem",
                date: "Tue, 15 Jan",
                time: "6:00 PM - 7:00 PM",
                service: "Modern Logo Design",
                paid: "30BD",
                status: .accepted
            ),
            Booking(
                userName: "Abdulla Salem",
                date: "Wed, 16 Jan",
                time: "3:00 PM - 4:00 PM",
                service: "Website Development",
                paid: "15BD",
                status: .pending
            ),
            Booking(
                userName: "Sara Ahmed",
                date: "Thu, 17 Jan",
                time: "10:00 AM - 11:00 AM",
                service: "Mobile App Design",
                paid: "45BD",
                status: .accepted
            ),
            
            // Completed Bookings
            Booking(
                userName: "Mohammed Ali",
                date: "Mon, 13 Jan",
                time: "2:00 PM - 3:00 PM",
                service: "Brand Identity",
                paid: "50BD",
                status: .completed
            ),
            Booking(
                userName: "Fatima Hassan",
                date: "Sun, 12 Jan",
                time: "5:00 PM - 6:00 PM",
                service: "UI/UX Design",
                paid: "35BD",
                status: .completed
            ),
            Booking(
                userName: "Youssef Omar",
                date: "Sat, 11 Jan",
                time: "11:00 AM - 12:00 PM",
                service: "Social Media Graphics",
                paid: "20BD",
                status: .completed
            ),
            
            // Incoming Requests
            Booking(
                userName: "Khalid Omar",
                date: "Fri, 18 Jan",
                time: "1:00 PM - 2:00 PM",
                service: "Logo Design",
                paid: "25BD",
                status: .incoming
            ),
            Booking(
                userName: "Layla Ahmed",
                date: "Sat, 19 Jan",
                time: "4:00 PM - 5:00 PM",
                service: "Social Media Graphics",
                paid: "20BD",
                status: .incoming
            ),
            Booking(
                userName: "Hassan Khalifa",
                date: "Sun, 20 Jan",
                time: "9:00 AM - 10:00 AM",
                service: "Business Card Design",
                paid: "15BD",
                status: .incoming
            )
        ]
    }
    
    // Filter methods
    func getMyBookings() -> [Booking] {
        return getAllBookings().filter { $0.status == .pending || $0.status == .accepted }
    }
    
    func getCompletedBookings() -> [Booking] {
        return getAllBookings().filter { $0.status == .completed }
    }
    
    func getIncomingRequests() -> [Booking] {
        return getAllBookings().filter { $0.status == .incoming }
    }
}
