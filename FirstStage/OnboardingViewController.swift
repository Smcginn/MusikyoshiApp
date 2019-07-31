//
//  OnboardingViewController.swift
//  PlayTunes-debug
//
//  Created by turtle on 7/16/19.
//  Copyright © 2019 Musikyoshi. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [OnboardingSlideView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        self.slides = createOnboardingSlides()
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "shownOnboarding") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NavController")
            self.present(controller, animated: false, completion: nil)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupSlideScrollView(slides: slides)
    }
    
    func createOnboardingSlides() -> [OnboardingSlideView] {
        
        let slide1: OnboardingSlideView = Bundle.main.loadNibNamed("OnboardingSlideView", owner: self, options: nil)?.first as! OnboardingSlideView
        slide1.imageView.image = UIImage(named: "slide1")
        slide1.titleLabel.text = "Welcome"
        slide1.descriptionLabel.text = "Get started with the most accessible, beginner-friendly music learning platform."
        
        let slide2: OnboardingSlideView = Bundle.main.loadNibNamed("OnboardingSlideView", owner: self, options: nil)?.first as! OnboardingSlideView
        slide2.imageView.image = UIImage(named: "slide2")
        slide2.titleLabel.text = "Structured Exercises"
        slide2.descriptionLabel.text = "Explore the hand-crafted content nested within levels of daily exercises."
        
        let slide3: OnboardingSlideView = Bundle.main.loadNibNamed("OnboardingSlideView", owner: self, options: nil)?.first as! OnboardingSlideView
        slide3.imageView.image = UIImage(named: "slide3")
        slide3.titleLabel.text = "Audio Analysis"
        slide3.descriptionLabel.text = "Take advantage of the most advanced technology in sound processing."
        
        let slide4: OnboardingSlideView = Bundle.main.loadNibNamed("OnboardingSlideView", owner: self, options: nil)?.first as! OnboardingSlideView
        slide4.imageView.image = UIImage(named: "slide4")
        slide4.titleLabel.text = "Video Guidance"
        slide4.descriptionLabel.text = "Watch personalized instructional videos designed to help you improve."
        slide4.startButton.isHidden = false
        slide4.addTarget(target: self, action: #selector(OnboardingViewController.presentNavController), forControlEvents: .touchUpInside)
        
        return [slide1, slide2, slide3, slide4]
        
    }
    
    @objc func presentNavController() {
        
        UserDefaults.standard.set(true, forKey: "shownOnboarding")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NavController")
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func setupSlideScrollView(slides: [OnboardingSlideView]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0..<slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }

}

extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        
        // Scale images
        
        let interval = 1.0 / CGFloat(slides.count - 1)

        for i in 0..<(slides.count - 1) {

            if (percentageHorizontalOffset > CGFloat(i) * interval) && (percentageHorizontalOffset <= CGFloat(i + 1) * interval) {

                let k = CGFloat(i + 1) * interval

                slides[i].imageView.transform = CGAffineTransform(scaleX: (k - percentageHorizontalOffset) / interval, y: (k - percentageHorizontalOffset) / interval)
                slides[i + 1].imageView.transform = CGAffineTransform(scaleX: percentageHorizontalOffset / k, y: percentageHorizontalOffset / k)
                
                break

            }

        }
        
    }
    
}
