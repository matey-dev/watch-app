//
//  AddLotCoordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

final class AddLotCoordinator {
    private var images: [AddLotStepItem: UIImage] = [:] {
        didSet {
            self.fillLotFormData.images = imagesArray
        }
    }
    private var imagesArray: [UIImage] {
        var array: [UIImage] = []
        AddLotStepItem.allCases.forEach { step in
            self.images[step].map { image in array.append(image) }
        }
        return array
    }
    private var brands: [Brand] = [] {
        didSet {
            self.fillLotFormData.brands = brands
        }
    }
    
    var fillLotFormData = FillLotFormData()
    
    let navigationController: AppNavigationController
    let addLotService: AddLotAPIService
    let filterService = FilterAPIService()
    let coordinatorObservables: CoordinatorObservables
    
    init(navigationController: AppNavigationController,
         addLotService: AddLotAPIService,
         coordinatorObservables: CoordinatorObservables) {
        
        self.navigationController = navigationController
        self.addLotService = addLotService
        self.coordinatorObservables = coordinatorObservables
        
        self.navigationController.isNavigationBarHidden = true
        
        self.filterService.getBrands { result in
            switch result {
            case .success(let success):
                self.brands = success.brands
            default: ()
            }
        }
    }
}

extension AddLotCoordinator: Coordinator {
    func start() {
        self.startAddLot()
    }
}

private extension AddLotCoordinator {
    func startAddLot() {
//        AddLotStep.firstStep.map { self.showSelectPhotoViewWith(step: $0) }
        showAddLotStepView()
    }
    
//    func backFrom(_ step: AddLotStepItem) {
//        step.prevStep
//            .map { _ in
//                self.popView(animated: true)
//            } ?? {
//                self.coordinatorObservables.switchTabObservable.notify(TabBarMessage.showFirstImmediately)
//            }()
//    }
    
    func backFrom() {
        self.coordinatorObservables.switchTabObservable.notify(TabBarMessage.showFirstImmediately)
    }
    
//    func showSelectPhotoViewWith(step: AddLotStep) {
//        let view = SelectPhotoView.storyboardInstance()
//        view.setStep(step)
//        if step == .front {
//            self.set(rootView: view)
//        } else {
//            self.push(view: view)
//        }
//        view.onAction { [weak self] action in
//            switch action {
//            case .back:
//                self?.backFrom(step)
//            case .next(let image, let step):
//                self?.images[step] = image
//                self?.showPreviewImageWith(step: step,
//                                           image: image)
//            }
//        }
//    }
    
    func showAddLotStepView() {
        self.images = [:]
        let view = AddLotStepVC()
//        self.set(rootView: view)
        self.push(view: view)
        view.onAction { action in
            switch action {
            case .back:
//                self?.navigationController.dismiss(animated: true, completion: nil)
                view.navigationController?.dismiss(animated: true, completion: nil)
//                self?.popView(animated: true)
            case .next(let images):
                self.images = images
                self.showLotDescriptionView()
            }
        }
    }
    
//    func showPreviewImageWith(step: AddLotStep,
//                              image: UIImage) {
//        let view = PreviewPhotoView.storyboardInstance()
//        view.setStep(step)
//        view.setPreviewImage(image)
//        self.push(view: view)
//        view.onAction { [weak self] action in
//            switch action {
//            case .back:
//                self?.popView(animated: true)
//            case .next(let image):
//                self?.images[step] = image
//                step.nextStep.map { nextStep in
//                    if nextStep == .description {
//                        self?.showLotDescriptionView()
//                    } else {
//                        self?.showSelectPhotoViewWith(step: nextStep)
//                    }
//                }
//            }
//        }
//
//    }
    
    func showLotDescriptionView() {
        let view = FillLotDescriptionVC()
        view.hidesBottomBarWhenPushed = true
//        view.setImages(self.imagesArray)
//        view.setBrands(self.brands)
        view.fillLotFormData = fillLotFormData
        self.push(view: view)
        view.onAction { [weak self] action in
            switch action {
            case .next(let formData):
                self?.showSummary(formData: formData)
            case .back:
                self?.popView(animated: true)
            case .cancel:
                self?.images = [:]
//                self?.popToRootView(animated: true)
                view.navigationController?.dismiss(animated: true, completion: nil)
//                self?.coordinatorObservables.switchTabObservable.notify(TabBarMessage.showFirstWithDealyAndRefresh)
            }
        }
    }
    
    func showSummary(formData: FillLotFormData) {
        let view = LotSummaryVC(formData: formData)
        view.hidesBottomBarWhenPushed = true
        view.setImages(formData.images)
        view.setBrands(formData.brands)
        self.push(view: view)
        view.onAction { [weak self] action in
            switch action {
            case .back:
                self?.popView(animated: true)
            case .cancel:
                self?.images = [:]
                self?.popToRootView(animated: true)
                self?.coordinatorObservables.switchTabObservable.notify(TabBarMessage.showFirstWithDealyAndRefresh)
            case .submitSuccess:
                self?.images = [:]
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                self?.coordinatorObservables.switchTabObservable.notify(TabBarMessage.showFirstWithDealyAndRefresh)
            }
        }
    }
}
