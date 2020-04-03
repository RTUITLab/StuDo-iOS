//
//  RightsViewController.swift
//  StuDo
//
//  Created by Andrew on 4/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

fileprivate let userCellId = "userCellId"
fileprivate let rightCellId = "rightCellId"

class RightsViewController: UITableViewController {
    
    let currentOrganization: Organization
    let currentMember: OrganizationMember
    
    var rights: Set<OrganizationMemberRight>
    let availableRights: [OrganizationMemberRight]
    
    let client = APIClient()
    
    enum SectionInfo: String {
        case profileDescription
        case rights
    }
    
    let infoPositions: [SectionInfo] = [.profileDescription, .rights]

    
    init(member: OrganizationMember, organization: Organization) {
        let rights = OrganizationMemberRight.allCases
        self.availableRights = rights.filter({ $0 != .member && $0 != .wisher })
        self.currentMember = member
        self.rights = Set(member.rights)
        self.currentOrganization = organization
        super.init(style: .grouped)
        client.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: userCellId)
        tableView.register(SettingsListItemCell.self, forCellReuseIdentifier: rightCellId)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoPositions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = infoPositions[section]
        
        if currentSection == .rights {
            return availableRights.count
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = infoPositions[indexPath.section]
        
        switch currentSection {
        case .profileDescription:
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! CurrentUserTableViewCell
            cell.fullnameLabel.text = "\(currentMember.user.firstName) \(currentMember.user.lastName)"
            cell.generateProfileImage(for: currentMember.user)
            cell.emailLabel.text = currentMember.user.email
            cell.setupCell()
            cell.selectionStyle = .none
            return cell
        case .rights:
            let cell = tableView.dequeueReusableCell(withIdentifier: rightCellId, for: indexPath) as! ListItemCell
            cell.selectionStyle = .none
            
            let right = availableRights[indexPath.row]
            let containsRight = rights.contains(right)
            cell.tickGlyph.alpha = containsRight ? 1 : 0
            cell.tickGlyph.isHidden = containsRight ? false : true
            
            switch right {
            case .canDeleteOrganization:
                cell.textLabel?.text = Localizer.string(for: .rightCanDeleteOrganization)
            case .canEditAd:
                cell.textLabel?.text = Localizer.string(for: .rightCanEditAd)
            case .canEditMembers:
                cell.textLabel?.text = Localizer.string(for: .rightCanEditMembers)
            case .canEditOrganizationInformation:
                cell.textLabel?.text = Localizer.string(for: .rightCanEditOrganizationInformation)
            case .canEditRights:
                cell.textLabel?.text = Localizer.string(for: .rightCanEditRights)
            case .member, .wisher:
                break
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = infoPositions[indexPath.section]
        
        if currentSection == .rights {
            let right = availableRights[indexPath.row]
            var detached = false
            if rights.contains(right) {
                client.detach(right: right, for: currentMember, in: currentOrganization)
                detached = true
            } else {
                client.attach(right: right, for: currentMember, in: currentOrganization)
            }
            
            let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 1)) as! ListItemCell
            cell.tickGlyph.animateVisibility(shouldHide: detached)
        }
    }

}


extension RightsViewController: APIClientDelegate {
    func apiClientDidAttachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember) {
        rights.insert(right)
    }
    
    func apiClientDidDetachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember) {
        rights.remove(right)
    }
}
