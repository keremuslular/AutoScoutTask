//
//  ImageCarouselView.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 28.02.2023.
//

import UIKit

class ImageCarouselView: UIView {
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.isDirectionalLockEnabled = true
        scroll.backgroundColor = .black.withAlphaComponent(0.1)
        scroll.contentInsetAdjustmentBehavior = .never
        return scroll
    }()
    
    let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        return page
    }()
    
    private var imageViews = [UIImageView]()
    private var currentPage = 0
    
    var images: [UIImage] = [] {
        didSet {
            imageViews.forEach { $0.removeFromSuperview() }
            imageViews = []

            for image in images {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                scrollView.addSubview(imageView)
                imageViews.append(imageView)
            }
            imageViews.forEach(scrollView.addSubview)
            pageControl.numberOfPages = imageViews.count
            
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [scrollView, pageControl].forEach(addSubview)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: CGFloat(imageViews.count) * bounds.width, height: bounds.height)
        
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame = CGRect(x: CGFloat(index) * bounds.width, y: 0, width: bounds.width, height: bounds.height)
        }
        
        let pageControlSize = pageControl.size(forNumberOfPages: pageControl.numberOfPages)
        let pageControlOrigin = CGPoint(x: (bounds.width - pageControlSize.width) / 2, y: bounds.height - pageControlSize.height)
        pageControl.frame = CGRect(origin: pageControlOrigin, size: pageControlSize)
    }
}

extension ImageCarouselView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update the current page based on the scroll position
        currentPage = Int(scrollView.contentOffset.x / bounds.width)
        pageControl.currentPage = currentPage
    }
}
