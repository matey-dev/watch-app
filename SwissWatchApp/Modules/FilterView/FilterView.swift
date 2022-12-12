//
//  FilterView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/5/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias FilterViewAction = (FilterViewActionType) -> Void
enum FilterViewActionType {
    case willDismiss
    case clear
    case applyFilter(DealerFilter)
}

class FilterView: BaseViewController {
    var filter: DealerFilter?
    
    private let networking = FilterAPIService()
    private var filterDataAdapter: DealerFilterDataAdapter?
    
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var fieldsContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet weak var brandTextField: DropdownFloatingTextField!
    @IBOutlet weak var modelTextField: DropdownFloatingTextField!
    @IBOutlet weak var yearTextField: DropdownFloatingTextField!
    private var textFields: [DropdownFloatingTextField] {
        return [self.brandTextField,
                self.modelTextField,
                self.yearTextField]
    }
    
    private var onAction: FilterViewAction?
    func onAction(_ callback: FilterViewAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func keyboardWillBeShown() {
        super.keyboardWillBeShown()
        self.moveMainContainerToCenter()
    }
    
    override func keyboardWillBeHidden() {
        super.keyboardWillBeHidden()
        self.moveMainContainerToCenter()
    }
}

// MARK: - actions
private extension FilterView {
    @IBAction func dissmissAction(_ sender: Any) {
        self.action(.willDismiss)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.filterDataAdapter?.clearFilter()
        self.brandTextField.text = nil
        self.modelTextField.text = nil
        self.yearTextField.text = nil
        self.action(.clear)
    }
    
    @IBAction func findAction(_ sender: Any) {
        self.filterDataAdapter.map { self.action(.applyFilter($0.dealerFilter())) }
    }
    
    func action(_ actionType: FilterViewActionType) {
        self.onAction?(actionType)
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - api
private extension FilterView {
    func getFilterFromAPI() {
        self.networking.getDealerFilters(self.filter?.selectedIfNotEmpty) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                var filter = DealerFilter(brands: success.brands,
                                          models: success.models,
                                          years: success.years)
                self.filter.map { filter.apply(selected: $0.selected) }
                self.filter = filter
                self.filterDataAdapter = DealerFilterDataAdapter(filter: filter,
                                                                 brandTextField: self.brandTextField,
                                                                 modelTextField: self.modelTextField,
                                                                 yearTextField: self.yearTextField)
                self.filterDataAdapter?.onDidSelect = { [weak self] in
                    self?.filter = self?.filterDataAdapter?.dealerFilter()
                    self?.getFilterFromAPI()
                    self?.setState(active: true)
                }
                self.setUserInteraction(enabled: true)
            case .failure(let failure):
                self.showError(title: "Error",
                               message: failure.localizedDescription)
            }
        }
    }
}

// MARK: - private
private extension FilterView {
    func setup() {
        self.setUserInteraction(enabled: false)
        self.getFilterFromAPI()
        let state = self.filter?.hasAnySelected ?? false
        self.setState(active: state)
    }
    
    func setUserInteraction(enabled: Bool) {
        self.cleanButton.isUserInteractionEnabled = enabled
        self.fieldsContainer.isUserInteractionEnabled = enabled
        self.bottomContainer.isUserInteractionEnabled = enabled
    }
    
    func setState(active: Bool) {
        self.setCleanButtonState(active: active)
        self.setFindButtonState(active: active)
    }
    
    func setCleanButtonState(active: Bool) {
        guard self.isViewLoaded else { return }
        self.cleanButton.alpha = active ? 1.0 : 0.3
        self.cleanButton.isEnabled = active
    }
    
    func setFindButtonState(active: Bool) {
        guard self.isViewLoaded else { return }
        self.findButton.isEnabled = active
        let backColor = active ? Colors.blackLight : Colors.black_8opacity
        self.findButton.backgroundColor = backColor
        let titleColor = active ? Colors.white : Colors.black_40opacity
        self.findButton.setTitleColor(titleColor, for: .normal)
    }
    
    func moveMainContainerToCenter() {
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
            self.mainContainer.transform = CGAffineTransform(translationX: 0.0, y: -(self.keyboardHeight/2.2) )
        }, completion: nil)
    }
}
