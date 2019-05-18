//
//  DataMockup.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

struct PublicAccountInfo {
    let name: String
    let surname: String
    let nickname: String
}

struct PrivateAccountInfo {
    var publicInfo: PublicAccountInfo
    var profiles: [Profile]?
    var ads: [Advertisement]?
}

struct Profile {
    var associatedAccount: PublicAccountInfo? = nil
    let briefDescription: String
    let description: String
}

struct Advertisement {
    var associatedAccount: PublicAccountInfo? = nil
    let headline: String
    let description: String
    let tags: Set<String>?
}

struct DataMockup {
    
    func getPrototypeAds(count: Int) -> [Advertisement] {
        var ads = [Advertisement]()
        for _ in 0...count {
            let headline = headlineMockup[Int.random(in: 0..<headlineMockup.count)]
            let description = descriptionMockup[Int.random(in: 0..<descriptionMockup.count)]
            
            var tags = Set<String>()
            let tagsCount = Int.random(in: 0..<tagMockup.count)
            for _ in 0...tagsCount {
                tags.insert(tagMockup[Int.random(in: 0..<tagMockup.count)])
            }
            
            ads.append(
                Advertisement(associatedAccount: nil, headline: headline, description: description, tags: tags)
            )
        }
        return ads
    }
    
    func getPrototypePeople(count: Int) -> [Profile] {
        var people = [Profile]()
        for _ in 0...count {
            let briefDescription = profileDescriptionMockup[Int.random(in: 0..<profileDescriptionMockup.count)]
            let description = descriptionMockup[Int.random(in: 0..<descriptionMockup.count)]

            people.append(
                Profile(associatedAccount: nil, briefDescription: briefDescription, description: description)
            )
        }
        return people
    }
    
    func getPrototypeAccount() -> PrivateAccountInfo {
        let name = nameMockup[Int.random(in: 0..<nameMockup.count)]
        let surname = surnameMockup[Int.random(in: 0..<surnameMockup.count)]
        let nickname = nicknameMockup[Int.random(in: 0..<nicknameMockup.count)]
        
        let publicInfo = PublicAccountInfo(name: name, surname: surname, nickname: nickname)
        
        var profiles = getPrototypePeople(count: 3)
        var ads = getPrototypeAds(count: 5)
        
        for i in 0..<3 {
            profiles[i].associatedAccount = publicInfo
            ads[i].associatedAccount = publicInfo
        }
        
        return PrivateAccountInfo(publicInfo: publicInfo, profiles: profiles, ads: ads)
        
    }
    
    var nameMockup = ["Igor", "Diana", "Misha", "Danil", "Ivan", "Alisa", "Anna"]
    
    var surnameMockup = ["Ivanov", "Markov", "Gratz", "Williams"]
    
    var nicknameMockup = ["micks", "skynett", "blits", "wayone"]
    
    var profileDescriptionMockup = ["Best ever programmer", "Gardener", "Chiller"]

    
    var headlineMockup = ["laboris nisi ut aliquip ex",
                    "dolor in reprehenderit in voluptate",
                    "Excepteur sint occaecat cupidatat",
                    "nulla aliquet enim tortor at auctor"
    ]
    
    var descriptionMockup = [
        "Blandit aliquam etiam erat velit scelerisque in. Non sodales neque sodales ut",
        "Duis convallis convallis tellus id. Molestie a iaculis at erat pellentesque adipiscing commodo. Ac auctor augue mauris augue neque gravida in fermentum et. Massa ultricies mi quis hendrerit dolor magna eget.",
        "Facilisi cras fermentum odio eu feugiat. Tempor commodo ullamcorper a lacus. Nam at lectus urna duis. Pharetra pharetra massa massa ultricies mi quis hendrerit dolor magna. Ipsum a arcu cursus vitae congue. Et sollicitudin ac orci phasellus egestas tellus rutrum."
    ]
    
    var tagMockup = ["Code", "Game", "Chillout", "Test", "Algebra", "Physics", "Math", "Calculus", "Easy"]
    
    
}
