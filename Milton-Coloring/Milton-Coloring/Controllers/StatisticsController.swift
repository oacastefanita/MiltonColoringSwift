//
//  StatisticsController.swift
//  MiltonStorybook
//
//  Created by Stefanita Oaca on 15.01.2024.
//

import Foundation

enum StatisticEventTypes: String, Codable{
    case bookCompleted
    case bookStarted
    case bookClosed
}

class StatisticEntry: NSObject, Codable{
    var date: Date
    var eventType: StatisticEventTypes
    
    var duration: Double? //in seconds
    var numberOfTriggers: Int?
    
    init(eventType: StatisticEventTypes, duration: Double? = nil, numberOfTriggers: Int? = nil) {
        self.date = Date()
        self.eventType = eventType
        
        self.duration = duration
        self.numberOfTriggers = numberOfTriggers
    }
    
    private enum CodingKeys: String, CodingKey {
        case date
        case duration
        case eventType
    }
    
    // Encode the object to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(eventType, forKey: .eventType)
    }
    
    // Decode the object from JSON
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        eventType = try container.decode(StatisticEventTypes.self, forKey: .eventType)
    }
}

class StatisticsController: NSObject {
    @objc public static let shared = StatisticsController()
    var entriesList: [StatisticEntry] = [StatisticEntry]()
    
    var numberOfSessions: Int = 0//number of entries where eventType == .started
    var numberOfCompletedSessions: Int = 0//number of entries where eventType == .completed
    var totalSessionDuration: Double = 0
    var averageSessionDuration: Double = 0//each entry .actionTriggered must also have a duration, compute the average duration
    var totalSessionDurationInMin: Double {
        return Double(round(10 * totalSessionDuration / 60) / 10)
    }
    var averageSessionDurationInMin: Double {
        return Double(round(10 * averageSessionDuration / 60) / 10)
    }
        
    override init() {
        super.init()
        loadEvents()
        computeStatistics()
    }
    
    func computeStatistics(){
        numberOfSessions = entriesList.filter { $0.eventType == .bookStarted }.count
        numberOfCompletedSessions = entriesList.filter { $0.eventType == .bookCompleted }.count
        
        let closedEntries = entriesList.filter { $0.eventType == .bookClosed}
        totalSessionDuration = closedEntries.reduce(0.0) { $0 + ($1.duration ?? 0.0) }
        
        let totalEntriesCount = Double(closedEntries.count)
        averageSessionDuration = totalEntriesCount == 0 ? 0 : totalSessionDuration / totalEntriesCount
    }
    
    //loads from NSUserDefaults
    func loadEvents(){
        if let data = UserDefaults.standard.data(forKey: "entriesListKey") {
            do {
                let decoder = JSONDecoder()
                entriesList = try decoder.decode([StatisticEntry].self, from: data)
            } catch {
                print("Error decoding entriesList: \(error)")
            }
        }
    }
    
    //Saves to NSUserDefaults
    func saveEvents(){
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entriesList)
            UserDefaults.standard.set(data, forKey: "entriesListKey")
        } catch {
            print("Error encoding entriesList: \(error)")
        }
    }
    
    func addEvent(_ event: StatisticEntry){        
        entriesList.append(event)
        saveEvents()
        computeStatistics()
    }
}

