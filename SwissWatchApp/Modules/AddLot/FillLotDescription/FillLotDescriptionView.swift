//
//  FillLotDescriptionView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/2/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias FillLotDescriptionViewAction = ((FillLotDescriptionViewActionType) -> Void)

enum FillLotDescriptionViewActionType {
    case back
    case submitSuccess
}

protocol IFillLotDescriptionView: IAddLotView {}

private let estimatedRowHeight: CGFloat = 500.0

class FillLotDescriptionView: BaseViewController {
    private var step: AddLotStep = .description
    let addLotService = AddLotAPIService()
    
    private var images: [UIImage] = []
    private var brands: [Brand] = []
    func setImages(_ images: [UIImage]) {
        self.images = images
    }
    func setBrands(_ brands: [Brand]) {
        self.brands = brands
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewDataAdapter: FillLotDataAdapter?
    
    @IBOutlet weak var progressBar: AddLotProgressView?
    
    var onAction: FillLotDescriptionViewAction?
    func onAction(_ callback: FillLotDescriptionViewAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.onViewWillAppear()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.onViewWillLayoutSubviews()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.onAction?(.back)
    }
}

private extension FillLotDescriptionView {
    func onViewWillAppear() {
    }
    
    func onViewWillLayoutSubviews() {
        self.progressBar?.updateWithProgress(self.step.progress)
    }
    
    func setup() {
        self.loadIndication(displayed: false)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = estimatedRowHeight
        self.tableViewDataAdapter = FillLotDataAdapter(brands: self.brands)
        self.tableView.dataSource = self.tableViewDataAdapter
        self.tableView.delegate = self.tableViewDataAdapter
        
        self.tableViewDataAdapter?.actionHandler = { [weak self] action in
            guard let self = self,
                let dataAdapter = self.tableViewDataAdapter else { return }
            switch action {
            case .submit:
                guard self.validateYear(fields: dataAdapter.fieldModels) else {
                    self.showInvalidYearAlert(nil)
                    return
                }
                self.showAddLotAlert {
//                    self.callAddLotApiWithModels(fields: dataAdapter.fieldModels,
//                                                 checks: dataAdapter.checkModels)
                }
            default:
                break
            }
        }
    }
}

private extension FillLotDescriptionView {
    func validateYear(fields: [FillLotModel.Field]) -> Bool {
        let year = fields.first(where: { $0.key == .model_year })?.text ?? ""
        guard !year.isEmpty else { return true }
        guard let intYear = Int(year) else { return true }
        let currentYear = Calendar.current.component(.year, from: Date())
        if intYear > currentYear || intYear < 1600 {
            return false
        } else {
            return true
        }
    }
    
    func callAddLotApiWithModels(fields: [FillLotModel.Field], checks: [FillLotModel.CheckBox]) {
        let brand = fields.first(where: { $0.key == .watch_name })?.id ?? -1
        let model = fields.first(where: { $0.key == .watch_model })?.text ?? ""
        let year = fields.first(where: { $0.key == .model_year })?.text ?? ""
        let reference = fields.first(where: { $0.key == .reference_no })?.text ?? ""
        let box = checks.first(where: { $0.key == .box })?.checked ?? false
        let documents = checks.first(where: { $0.key == .documents })?.checked ?? false
        let images = self.images
        let description = fields.first(where: { $0.key == .description })?.text ?? ""
        self.loadIndication(displayed: true)
        
        self.addLotService.sendLot(
        brand: brand,
        year: year,
        box: box,
        documents: documents,
        model: model,
            reference: reference, description: description,
        images: images) { [weak self] lot_id in
            guard let self = self else { return }
            if lot_id != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.onAction?(.submitSuccess)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.loadIndication(displayed: false)
                }
            } else {
                self.loadIndication(displayed: false)
                self.showError(title: "Error",
                                message: "Unexpected error")
            }
        }
    }
}

extension FillLotDescriptionView: IFillLotDescriptionView {
    func setStep(_ step: AddLotStep) {
        self.step = step
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        let cantFind = self.tableViewDataAdapter?.updateErrorsWithKeyValues(dict) ?? [:]
        onMainQueue {
            self.tableView.reloadData()
        }
        return cantFind
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.containerView.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}

private extension FillLotDescriptionView {
    func showAddLotAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Your post will become visible",
                   button1Title: "Confirm",
                   button2Title: "Cancel",
                   button1Style: .black,
                   button2Style: .white,
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .one:
                confirm?()
            default: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
    
    func showInvalidYearAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Invalid Year",
                   button1Title: "OK",
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .one:
                confirm?()
            default: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
}
