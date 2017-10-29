//
//  LSHelpScreens.swift
//  Swatch
//
//  Created by 1 1 on 10.11.16.
//  Copyright © 2016 1. All rights reserved.
//

import Foundation
import UIKit

class TutorialScreen:UIViewController, UIScrollViewDelegate
{
    
    var scrollView:UIScrollView!
    var pageControl:UIPageControl!
    
    var completionBlock: (()->Void)?
    
    var tappedNumberOfPage = 0
    
    var backButton:UIImageButton!
    
    var isAnimating = false
    
    override func viewDidLoad() {
        
        
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        //scrollView.canCancelContentTouches=YES;
        var i = 0
        let imgs = ["How to use_screen_v3-01.png", "How to use_screen_v3-02.png", "How to use_screen_v3-03.png", "How to use_screen_v3-04.png", "How to use_screen_v3-05.png"]
        scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(imgs.count + 1), height: view.frame.size.height)

        for img in imgs
        {
            let view = UIImageView(frame: CGRect(x: ((scrollView.frame.size.width) * CGFloat(i)), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
            view.backgroundColor = UIColor.black
            view.contentMode = .scaleAspectFit
            view.image = UIImage(named: img)!
            scrollView.addSubview(view)
            i += 1
        }
        
        scrollView.delegate = self
        /*
        pageControl = UIPageControl()
        pageControl.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        pageControl.center = CGPoint(x:self.view.frame.width/2,y:self.view.frame.height - 130)
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        view.addSubview(pageControl)
        */
        
        let button = UIImageButton(frame: CGRect(x: view.frame.width - 16, y: view.frame.height - 60, width: 56, height: 44))
        button.image = #imageLiteral(resourceName: "How to use_arrow.png")
        button.frame = CGRect(x: view.frame.width - 65, y: view.frame.height - 60, width: 56, height: 46)
        button.addTarget(self, action: #selector(nextTapped), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
        
        backButton = UIImageButton(frame: CGRect(x: view.frame.width - 16, y: view.frame.height - 60, width: 56, height: 44))
        backButton.image = #imageLiteral(resourceName: "How to use_arrow_back.png")
        backButton.frame = CGRect(x: 9, y: view.frame.height - 60, width: 56, height: 46)
        backButton.addTarget(self, action: #selector(backTapped), for: UIControlEvents.touchUpInside)
        backButton.isHidden = true
        self.view.addSubview(backButton)

    }
    
    
    func nextTapped()
    {
        
        if isAnimating
        {
            return
        }
            
        tappedNumberOfPage += 1
        if tappedNumberOfPage >= 5
        {
            hide()
            return
        }

        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x + self.view.bounds.width,y:0), animated: true)
        backButton.isHidden = false
        isAnimating = true
    }
    
    func backTapped()
    {
        if isAnimating
        {
            return
        }
        
        tappedNumberOfPage -= 1
        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x - self.view.bounds.width,y:0), animated: true)
        isAnimating = true
        
        if tappedNumberOfPage <= 0
        {
            backButton.isHidden = true
            return
        }
        


    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isAnimating = false
    }
    
    func hide()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        if completionBlock != nil
        {
            completionBlock!()
        }

    }
}
