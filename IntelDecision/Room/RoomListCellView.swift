//
//  RoomStatusView.swift
//  IntelDecision
//
//  Created by admin on 2018/10/23.
//  Copyright © 2018年 clcw. All rights reserved.
//

import UIKit
import OHHTTPStubs
/**
 自定义圆角label，设置背景色
 
 */
class StatusLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4
    }
    
}

/// 房间的数据模型
class RoomStatusModel {
    var name:String!
    var status:String!
    var statusColor:String!
    var cell:Array<DecisionModel> = []
    
    ///便利构造器，用于测试
    convenience init(test:Bool) {
        self.init()
        name = "房间1"
        status = "指标优"
        statusColor = "red"
        var i = 0
        while i<4 {
            let decision = DecisionModel.init(test: true)
            cell.append(decision)
            i = i + 1
        }
    }
}
/// 设备的数据模型
class DecisionModel {
    var icon:String!
    var value:String!
    
    /// 便利构造器，用于测试
    convenience init(test:Bool){
        self.init()
        icon = "光照iconcopy3"
        value = "12"
    }
}
/// 嵌套的设备cell
class DecisionCellView: UICollectionViewCell {
    
    @IBOutlet var iconImageView:UIImageView!
    @IBOutlet var statusLabel:UILabel!
    var newModel:DecisionModel!
    
    /**
     采用set方法，初始化UI数据
     
     -问题
         基于Framework 无法获取Asset.cer图片资源
         [让你的iOS库支持pod和carthage](https://www.jianshu.com/p/30246a000bc6)
     */
    var model:DecisionModel{
        set (newValue){
            newModel = newValue
            let bundles = OHResourceBundle("source", type(of: self))
            iconImageView.image = UIImage.init(named: newValue.icon, in: bundles, compatibleWith: nil)
            statusLabel.text = newValue.value
            let fontPath = bundles?.path(forResource: "DINCond-Medium", ofType: "otf")
            statusLabel.font = customFont(fontPath!, size: 15)
        }
        get{
            return newModel
        }
    }
    ///自适应宽度
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        do {
            let size = CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: 30)
            let text:NSString = self.statusLabel.text! as NSString
            var rect = try text.boundingRect(with: size, options: [.usesFontLeading,.usesLineFragmentOrigin], attributes: nil, context: nil)
            rect.size.width = rect.size.width + 100
            attributes.frame = rect
        } catch {
        }
        return attributes;
    }
    
    //MARK: 加载字体
    
    /// 加载otf字体文件，显示字体样式
    ///
    /// - Parameters:
    ///   - path: otf文件路径
    ///   - size: 字体大小
    /// - Returns: 返回font字体
    func customFont(_ path:String, size:CGFloat) -> UIFont {
        let fontUrl = URL.init(fileURLWithPath: path)
        let fontDataProvider = CGDataProvider.init(url: fontUrl as CFURL)
        let fontRef = CGFont.init(fontDataProvider!)
        CTFontManagerRegisterGraphicsFont(fontRef!, nil)
        let fontName = fontRef?.postScriptName
        let font = UIFont.init(name: fontName! as String, size: size)
        return font!
    }
}

/// 房间cell
class RoomListCellView: UICollectionViewCell {
    var decisionArry:Array<DecisionModel> = []
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: StatusLabel!
    @IBOutlet var collectionView:UICollectionView!
    var newModel:RoomStatusModel!
    var model:RoomStatusModel{
        set (newValue){
            newModel = newValue
            nameLabel.text = newValue.name
            statusLabel.text = newValue.status
            statusLabel.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            decisionArry = newValue.cell
        }
        get{
            return newModel
        }
    }
    ///画圆角
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        self.statusLabel.layer.cornerRadius = 5
        self.statusLabel.layer.masksToBounds = true
        ///宽度自适应设置
//        let layout:UICollectionViewFlowLayout = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.estimatedItemSize = CGSize.init(width:100, height: 50)
    }
    
    ///自适应宽度
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        if self.collectionView.contentSize.width > 0 {
            do {
                let size = CGSize.init(width: self.collectionView.contentSize.width, height: 100)
                let rect = CGRect.init(origin: self.collectionView.frame.origin, size: size)
                attributes.frame = rect
            } catch {
            }
        }
        return attributes;
    }
}

/// 设备列表代理实现
extension RoomListCellView:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.decisionArry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:DecisionCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "DecisionCellView", for: indexPath) as! DecisionCellView
        let model = self.decisionArry[indexPath.row]
        cell.model = model
        return cell
    }
}
