//
//  XibFilesOwnerView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/22.
//

import Cocoa

class XibFilesOwnerView: NSView {
    class var nibName: String {
        return String(describing: self)
    }
        
    // xibの File's Owner にクラスを指定したViewをコードで生成
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiateView()
    }
    
    // xibの File's Owner にクラスを指定したViewを @IBOutlet で生成
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiateView()
    }
  
    private func instantiateView() {
        let nib = NSNib(nibNamed: type(of: self).nibName, bundle: .main)!
        var topLevelArray: NSArray? = NSArray()
        guard
            nib.instantiate(withOwner: self, topLevelObjects: &topLevelArray), // IBOutlet / IBAction を self と接続
            let results = topLevelArray as? [Any],
            let item = results.last(where: { $0 is NSView }),
            let view = item as? NSView
        else { // failed to load
            return
        }
        
        self.addSubview(view)
        
//        // 制約を追加
//        view.translatesAutoresizingMaskIntoConstraints = false // AutoresizingMaskをAutoLayoutの制約に置き換える場合falseに設定
//        view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
//        view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
//        view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        view.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
