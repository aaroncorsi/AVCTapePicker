//
//  AVCTapePicker.swift
//  Lifty
//
//  Created by Aaron Corsi on 12/12/16.
//  Copyright © 2016 Aaron Corsi. All rights reserved.
//

import UIKit

protocol AVCTapePickerDelegate {
    func tapePicker(picker: AVCTapePicker, didSelect newValue: Double)
}

class AVCTapePicker: UIView {
    // Delegate
    var delegate: AVCTapePickerDelegate?
    
    // Data Source
    var tickerValues = [Double]() {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var tickViews = [UIView]()
    var selectedTick: UIView?
    var selectedIndex: Int?
    var selectedValue: Double {
        get {
            return self.tickerValues[self.selectedIndex!]
        }
    }
    
    // Haptic
    var feedbackGenerator = UISelectionFeedbackGenerator()
    
    // UI Configuration
    var significantTickInterval = 10.0 {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var significantTickHeight = 30 {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var medianTickHeight = 20 {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var insignificantTickHeight = 10 {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var tickSpacing = 20 {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var tickWidth = 1 {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var tickColor = UIColor.white.withAlphaComponent(0.5) {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var significantTickColor = UIColor.white {
        didSet {
            self.updateTickViewsWithCurrentValues()
            if self.selectedIndex != nil {
                self.setSelectedTickIndex(index: self.selectedIndex!, animated: false)
            }
        }
    }
    var unitString = ""
    var selectionIndicatorColor = UIColor.black
    
    // UI Elements
    var scrollView: UIScrollView!
    var titleView: UIView!
    var titleViewTopConstraint: NSLayoutConstraint!
    var selectionLabel: UILabel!
    var selectionUnitLabel: UILabel!
    var selectionIndicatorImageView: UIImageView!
    var shadowImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //print("Loaded view with subviews: \(self.subviews)")
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //print("Loaded view with subviews: \(self.subviews)")
        self.setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: self.frame.width * 0.5, bottom: 0, right: self.frame.width * 0.5)
        if self.selectedIndex != nil {
            self.scrollToTickIndex(index: 0, animated: false)
            self.scrollToTickIndex(index: self.selectedIndex!, animated: false)
        } else {
            self.scrollToTickIndex(index: 0, animated: false)
        }
    }
    
    func setupViews() {
        self.clipsToBounds = true
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.backgroundColor = UIColor.black
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
        
        let appTintColor: UIColor = UIView.appearance().tintColor ?? UIColor.blue

        self.titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.15, alpha: 1)
        self.titleView.layer.borderColor = appTintColor.cgColor
        self.titleView.layer.borderWidth = 1
        self.addSubview(titleView)
        self.selectionLabel = UILabel()
        self.selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.selectionLabel.textAlignment = NSTextAlignment.center
        self.selectionLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        self.selectionLabel.textColor = UIColor.white
        titleView.addSubview(self.selectionLabel)
        self.selectionUnitLabel = UILabel()
        self.selectionUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        self.selectionUnitLabel.textAlignment = NSTextAlignment.left
        self.selectionUnitLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
        self.selectionUnitLabel.textColor = self.selectionLabel.textColor
        titleView.addSubview(self.selectionUnitLabel)
        self.selectionIndicatorImageView = UIImageView(image: #imageLiteral(resourceName: "SelectionIndicator"))
        self.selectionIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        self.selectionIndicatorImageView.tintColor = UIView.appearance().tintColor
        titleView.addSubview(self.selectionIndicatorImageView)
        
        var allConstraints = [NSLayoutConstraint]()
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollView]-0-|", options: [], metrics: nil, views: ["scrollView": self.scrollView])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[titleView(44)]-0-[scrollView]-0-|", options: [], metrics: nil, views: ["scrollView": self.scrollView, "titleView": self.titleView])
        self.titleViewTopConstraint = NSLayoutConstraint(item: self.titleView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        allConstraints.append(self.titleViewTopConstraint)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-1)-[titleView]-(-1)-|", options: [], metrics: nil, views: ["titleView": self.titleView])
        allConstraints.append(NSLayoutConstraint(item: self.selectionLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.titleView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        allConstraints.append(NSLayoutConstraint(item: self.selectionLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.titleView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        allConstraints.append(NSLayoutConstraint(item: self.selectionUnitLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.titleView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        allConstraints.append(NSLayoutConstraint(item: self.selectionUnitLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.selectionLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 8))
        allConstraints.append(NSLayoutConstraint(item: self.selectionIndicatorImageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.titleView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        allConstraints.append(NSLayoutConstraint(item: self.selectionIndicatorImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.titleView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        allConstraints.append(NSLayoutConstraint(item: self.selectionIndicatorImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: CGFloat(self.insignificantTickHeight)))
        allConstraints.append(NSLayoutConstraint(item: self.selectionIndicatorImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: CGFloat(self.insignificantTickHeight)))
        NSLayoutConstraint.activate(allConstraints)
        
        // Set default values for ticker content
        var defaultTickerValues = [Double]()
        for i in 0...100 {
            defaultTickerValues.append(Double(i))
        }
        self.tickerValues = defaultTickerValues
    }
    
    func updateTickViewsWithCurrentValues() {
        var newTickViews = [UIView]()
        // Remove old tick views
        if self.tickViews.count > 0 {
            for view in self.tickViews {
                view.removeFromSuperview()
            }
        }
        var offset = 0
        var index: Double = 0
        while index.isLess(than: Double(self.tickerValues.count)) {
            var tickViewRect: CGRect?
            if index == -1 {
                tickViewRect = CGRect(x: 0, y: 0, width: self.scrollView.frame.width * 0.5, height: self.scrollView.frame.height)
                let tickView = UIView(frame: tickViewRect!)
                tickView.backgroundColor = self.significantTickColor
                self.scrollView.addSubview(tickView)
                offset += Int(tickView.frame.width)
            } else if index.truncatingRemainder(dividingBy: significantTickInterval) == 0 {
                // Value represents a significant tick
                // Setup Tick View
                tickViewRect = CGRect(x: offset, y: 0, width: self.tickWidth, height: self.significantTickHeight)
                let tickView = UIView(frame: tickViewRect!)
                tickView.backgroundColor = self.tickColor
                newTickViews.append(tickView)
                self.scrollView.addSubview(tickView)
                // Setup tick label
                let tickLabel = UILabel()
                tickLabel.translatesAutoresizingMaskIntoConstraints = false
                tickLabel.tag = 10
                tickView.backgroundColor = self.significantTickColor
                tickLabel.textColor = self.significantTickColor
                tickLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.thin)
                let tickerValueAtIndex = self.tickerValues[Int(index)]
                if tickerValueAtIndex.truncatingRemainder(dividingBy: 1) == 0 {
                    tickLabel.text = "\(Int(tickerValueAtIndex))"
                } else {
                    tickLabel.text = "\(tickerValueAtIndex)"
                }
                
                tickView.addSubview(tickLabel)
                var tickLabelConstraints = [NSLayoutConstraint]()
                tickLabelConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-tickHeight-[tickLabel(20)]", options: [], metrics: ["tickHeight": (self.significantTickHeight + 4)], views: ["tickLabel": tickLabel])
                tickLabelConstraints.append(NSLayoutConstraint(item: tickLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: tickView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                NSLayoutConstraint.activate(tickLabelConstraints)
                offset += self.tickSpacing
            } else if index.truncatingRemainder(dividingBy: (significantTickInterval / 2)) == 0 {
                // Value is halfway between significant ticks
                // Setup tick view without label
                tickViewRect = CGRect(x: offset, y: 0, width: self.tickWidth, height: self.medianTickHeight)
                let tickView = UIView(frame: tickViewRect!)
                tickView.backgroundColor = self.tickColor
                newTickViews.append(tickView)
                self.scrollView.addSubview(tickView)
                offset += self.tickSpacing
            } else {
                // Value is not a significant tick
                // Setup tick view without label
                tickViewRect = CGRect(x: offset, y: 0, width: self.tickWidth, height: self.insignificantTickHeight)
                let tickView = UIView(frame: tickViewRect!)
                tickView.backgroundColor = self.tickColor
                newTickViews.append(tickView)
                self.scrollView.addSubview(tickView)
                offset += self.tickSpacing
            }
            index += 1
        }
        self.tickViews = newTickViews
        self.scrollView.contentSize = CGSize(width: CGFloat(offset), height: 0)
    }
    
    func setSelectedTickIndex(index: Int, animated: Bool) {
        self.selectedIndex = index
        self.updateSelectionWithViewIndex(viewIndex: index)
        if animated == true {
            self.scrollToTickIndex(index: index, animated: animated)
        } else {
            self.scrollView.setContentOffset(self.offsetFromIndex(index: index), animated: false)
        }
    }
    
    func scrollToTickIndex(index: Int, animated: Bool) {
        //print("Scrolling to offset: \(self.offsetFromIndex(index: index)) from index: \(index)")
        self.scrollView.setContentOffset(self.offsetFromIndex(index: index), animated: animated)
    }
    
    func offsetFromIndex(index: Int) -> CGPoint {
        let offset = CGPoint(x: Double((index * self.tickSpacing) - Int(self.scrollView.contentInset.left)) + 0.5, y: 0)
        return offset
    }
    
    func indexFromOffset(offset: CGFloat) -> Int {
        let compensated = offset + self.scrollView.contentInset.left
        let position = compensated / CGFloat(self.tickSpacing)
        var index: Int
        if position - floor(position) > 0.5 {
            index = Int(ceil(position))
        } else {
            index = Int(position)
        }
        if index < 0 {
            return 0
        } else if index > self.tickViews.count - 1 {
            return self.tickViews.count - 1
        } else {
            return index
        }
    }
    
    func updateSelectionWithViewIndex(viewIndex: Int) {
        if viewIndex >= 0 && viewIndex <= self.tickViews.count - 1 {
            self.selectionLabel.text = "\(viewIndex)"
            self.selectionUnitLabel.text = "\(self.unitString)"
            let viewAtIndex = self.tickViews[viewIndex]
            if viewAtIndex != self.selectedTick {
                self.feedbackGenerator.selectionChanged()
                self.feedbackGenerator.prepare()
                if self.selectedTick != nil {
                    var selectedTickIndex = self.tickViews.index(of: self.selectedTick!)!
                    let tickIndex = selectedTickIndex
                    if selectedTickIndex + 1 < viewIndex {
                        while viewIndex > selectedTickIndex {
                            let tick = self.tickViews[selectedTickIndex]
                            tick.backgroundColor = self.tintColor
                            UIView.animate(withDuration: 0.4, animations: {
                                if Double(selectedTickIndex).truncatingRemainder(dividingBy: self.significantTickInterval) == 0 {
                                    tick.backgroundColor = self.significantTickColor
                                } else {
                                    tick.backgroundColor = self.tickColor
                                }
                            }, completion: { finished in
                                
                            })
                            selectedTickIndex += 1
                        }
                    } else if selectedTickIndex - 1 > viewIndex {
                        while viewIndex < selectedTickIndex {
                            let tick = self.tickViews[selectedTickIndex]
                            tick.backgroundColor = self.tintColor
                            UIView.animate(withDuration: 0.4, animations: {
                                if Double(selectedTickIndex).truncatingRemainder(dividingBy: self.significantTickInterval) == 0 {
                                    tick.backgroundColor = self.significantTickColor
                                } else {
                                    tick.backgroundColor = self.tickColor
                                }
                            }, completion: { finished in
                                
                            })
                            selectedTickIndex -= 1
                        }
                    }
                    UIView.animate(withDuration: 0.4, animations: {
                        if Double(tickIndex).truncatingRemainder(dividingBy: self.significantTickInterval) == 0 {
                            self.selectedTick?.backgroundColor = self.significantTickColor
                        } else {
                            self.selectedTick?.backgroundColor = self.tickColor
                        }
                    }, completion: { finished in
                        
                    })
                }
                self.selectedTick = viewAtIndex
                self.selectedTick!.backgroundColor = self.tintColor
            }
            self.delegate?.tapePicker(picker: self, didSelect: self.tickerValues[viewIndex])
        }
    }
}

extension AVCTapePicker: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.feedbackGenerator.prepare()
        let viewIndex = indexFromOffset(offset: self.scrollView.contentOffset.x)
        self.updateSelectionWithViewIndex(viewIndex: viewIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let viewIndex = self.indexFromOffset(offset: self.scrollView.contentOffset.x)
            self.setSelectedTickIndex(index: viewIndex, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let viewIndex = self.indexFromOffset(offset: self.scrollView.contentOffset.x)
        self.setSelectedTickIndex(index: viewIndex, animated: true)
    }
}
