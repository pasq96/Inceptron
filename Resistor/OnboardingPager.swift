//
//  OnboardingPager.swift
//  onboardingWithUIPageViewController
//
//  Created by Pasquale Coppola on 11/03/18.
//  Copyright © 2018 Thorn Technologies. All rights reserved.
//

import UIKit

class OnboardingPager : UIPageViewController {
	

	
	func getStepZero() -> StepZero{
		return storyboard!.instantiateViewController(withIdentifier: "StepZero") as! StepZero
	}
	
	func getStepOne() -> StepOne{
		return storyboard!.instantiateViewController(withIdentifier: "StepOne") as! StepOne
	}
	
	func getStepTwo() -> StepTwo{
		return storyboard!.instantiateViewController(withIdentifier: "StepTwo") as! StepTwo
	}
	
	override func viewDidLoad() {
		view.backgroundColor = .gray
		dataSource = self
		
		setViewControllers([getStepZero()], direction: .forward, animated: false, completion: nil)
	}
	
}

extension OnboardingPager : UIPageViewControllerDataSource {
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
			if viewController.isKind(of: StepTwo.self) {
				return getStepOne()
			} else if viewController.isKind(of: StepOne.self) {
				return getStepZero()
			} else {
				return nil
			}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		// Returns the view controller before the given view controller.
			if viewController.isKind(of: StepZero.self) {
				return getStepOne()
			} else if viewController.isKind(of:StepOne.self) {
				return getStepTwo()
			} else {
				return nil
			}
	}
	
//	func presentationCountForPageViewController (pageViewController: UIPageViewController) -> Int {
//		return 3
//	}
//
//	func presentationIndexForPageViewController (pageViewController: UIPageViewController) -> Int {
//		return 0
//	}
	private func setupPageControl() {
		let appearance = UIPageControl.appearance()
		appearance.currentPageIndicatorTintColor = UIColor.white
		appearance.backgroundColor = UIColor.darkGray
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		setupPageControl()
		return 3
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}
}

