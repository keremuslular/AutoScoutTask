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
        scroll.backgroundColor = .black.withAlphaComponent(0.1)
        return scroll
    }()
    
    let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.hidesForSinglePage = true
        return page
    }()
    
    private var imageViews = [UIImageView]()
    private var currentPage = 0
    
    var images: [CarImage]? = [] {
        didSet {
            if let images = images, images.count > 0 {
                // Remove any existing image views in case of a reload/reuse
                imageViews.forEach { $0.removeFromSuperview() }
                imageViews = []
                
                for image in images {
                    let imageView = UIImageView()
                    let activityIndicatorView = UIActivityIndicatorView(style: .medium)
                    activityIndicatorView.hidesWhenStopped = true
                    
                    [imageView, activityIndicatorView].forEach(scrollView.addSubview)
                    activityIndicatorView.snp.makeConstraints { make in
                        make.center.equalTo(imageView)
                    }
                    
                    activityIndicatorView.startAnimating()
                    imageView.loadImage(from: image.url, contentMode: .scaleAspectFit) {
                        activityIndicatorView.stopAnimating()
                    }
                    imageViews.append(imageView)
                }
                
                pageControl.numberOfPages = images.count
            } else {
                let placeholderImageView = UIImageView(image: UIImage(named: "carPlaceholder"))
                placeholderImageView.isOpaque = true
                placeholderImageView.contentMode = .scaleAspectFit
                
                scrollView.addSubview(placeholderImageView)
                imageViews = [placeholderImageView]
            }
            
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
