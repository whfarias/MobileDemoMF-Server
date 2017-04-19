/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  CouponAnnotationView.swift
//  MyCoupons
//
//  Created by Ishai Borovoy on 14/08/2016.
//

import UIKit
import HDAugmentedReality
import IBMMobileFirstPlatformFoundation
import AudioToolbox.AudioServices

open class CouponAnnotationView: ARAnnotationView, UIGestureRecognizerDelegate
{
    var couponImageView : UIImageView?
    open var titleLabel: UILabel?
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.couponImageView == nil {
            self.loadUi()
        }
    }

    
    func loadUi() {
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        self.couponImageView?.removeFromSuperview()
        let coupon : CouponARAnnotation = self.annotation as! CouponARAnnotation
        let image = coupon.imageURL!.contains("/") ? Utils.getUIImage(coupon.imageURL!) : UIImage(named: coupon.imageURL!)
        let imageView = UIImageView(image: image!)
        self.addSubview(imageView)
        self.couponImageView = imageView
        
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CouponAnnotationView.couponTapped))
        self.addGestureRecognizer(tapGesture)
        
        // Other
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.layer.cornerRadius = 5
        
        if self.annotation != nil {
            self.bindUi()
        }
    }
    
    func layoutUi() {
        let calculatedSize = CGFloat(50000 / (self.annotation as! CouponARAnnotation).distanceFromUser)
        let size: CGFloat = calculatedSize < 80 ? 80 : calculatedSize > 250 ? 250 : calculatedSize
        self.couponImageView?.frame = CGRect(x: 20, y: 20, width: size, height: size)
        self.titleLabel?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 17);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi() {
        if let annotation = self.annotation{
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            self.titleLabel?.text = distance
            print (distance)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    open func couponTapped() {
        if let annotation = self.annotation as? CouponARAnnotation  {
            
            if annotation.distanceFromUser > Double(annotation.enabledRadius!) {
                let alertView = UIAlertView(title: annotation.title, message: "Coupon is too far, you need to get closer", delegate: nil, cancelButtonTitle: "OK")
                AudioServicesPlaySystemSound(1306)
                 (self.annotation as! CouponARAnnotation).isPicked = false
                alertView.show()
            } else if !annotation.isPicked{
                AudioServicesPlaySystemSound(1109)
                (self.annotation as! CouponARAnnotation).imageURL = "check.png"
                (self.annotation as! CouponARAnnotation).isPicked = true
                loadUi()
            }
            WLAnalytics.sharedInstance().log("picked-coupon", withMetadata: annotation.asMetaData());
            WLAnalytics.sharedInstance().send();
        }
    }
}
