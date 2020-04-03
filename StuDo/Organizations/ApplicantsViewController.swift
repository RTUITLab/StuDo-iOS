//
//  ApplicantsViewController.swift
//  StuDo
//
//  Created by Andrew on 4/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

let reuseId = "cell"
class ApplicantsViewController: UITableViewController {
    
    var organization: Organization
    var applicants: [OrganizationMember] = [] {
        didSet {
            noApplicationsLabel.animateVisibility(shouldHide: !applicants.isEmpty, duration: 0)
        }
    }
    let client = APIClient()
    
    let noApplicationsLabel = UILabel()
    
    init(organization: Organization) {
        self.organization = organization
        super.init(style: .plain)
        tableView.register(ApplicantTableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.tableFooterView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(noApplicationsLabel)
        noApplicationsLabel.translatesAutoresizingMaskIntoConstraints = false
        noApplicationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noApplicationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        
        noApplicationsLabel.text = Localizer.string(for: .organizationNoWishers)
        noApplicationsLabel.font = .preferredFont(for: .headline, weight: .bold)
        noApplicationsLabel.textColor = UIColor.placeholderText

        client.delegate = self
        if applicants.isEmpty {
            client.getWishers(forOrganizationWithId: organization.id)
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applicants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! ApplicantTableViewCell
        
        let currentMember = applicants[indexPath.row]
        
        cell.initialsLabel.text = String(currentMember.user.firstName.prefix(1)) + currentMember.user.lastName.prefix(1)
        cell.nameLabel.text = "\(currentMember.user.firstName) \(currentMember.user.lastName)"
        
        cell.addButtonClosure = {
            self.client.attach(right: .member, for: currentMember, in: self.organization)
            self.client.detach(right: .wisher, for: currentMember, in: self.organization)
        }
        
        return cell
    }

}


extension ApplicantsViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didRecieveOrganizationWishers wishers: [OrganizationMember]) {
        self.applicants = wishers
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func apiClientDidAttachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember) {
        if let applicantElement = applicants.enumerated().filter({ member.user.id! == $0.element.user.id! }).first {
            applicants.remove(at: applicantElement.offset)
            let indexPath = IndexPath(row: applicantElement.offset, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
