//
//  NSView+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/23.
//

import Cocoa
import SwiftUI

extension NSView {
    func addSwiftUIView<T: View>(_ swiftUIView: T) -> NSHostingView<T> {
        let hv = NSHostingView(rootView: swiftUIView)
        self.addSubview(hv)
        hv.setFrameSize(bounds.size)
                
        return hv
    }
    
    func makeSubviewsTheSameFrameAsMe() {
        for subview in subviews {
            subview.frame = CGRect(origin: .zero, size: bounds.size)
        }
    }
    
    func makeLayerAndItsSublayersTheSameFrameAsMe() {
        if layer == nil { return }
        layer!.frame = frame
        
        if layer!.sublayers == nil { return }
        for sublayer in layer!.sublayers! {
            sublayer.frame = CGRect(origin: .zero, size: layer!.bounds.size)
        }
    }
    
    func getSubView<T: NSView>(checkClass: T, searchRecrusively: Bool = false) -> T? {
        //子のViewを取得
        for subView in self.subviews {
            //その子のViewが引数のクラスだったらそのオブジェクトを返す
            if type(of: subView) == type(of: checkClass) {
                return subView as! T?
            } else if searchRecrusively {
                //違ったら下のViewを再起的にチェックし、見つかったらそのViewを返す
                if let view = subView.getSubView(checkClass : checkClass ) {
                    return view
                }
            }
        }
        return nil
    }
    
    @IBInspectable var backgroundColor: NSColor? {
        get {
            guard let backgroundColor = layer?.backgroundColor else {
                return nil
            }
            return NSColor(cgColor: backgroundColor)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
   }
}
