#  遇到的坑

## 加载字体
### 通过配置plist内置加载
1.首先是最简单也普遍的做法，打包内置字符库文件：

把字体库文件添加到工程，如font1.ttf添加到工程，然后在工程plist添加一项Fonts provided by application，这是个数组，然后添加key item1，value就是刚才说的font1.ttf
那么在工程里就可以直接使用这个字体，直接用

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize; 即可。

不过需要注意的是，这个fontName不是文件名，而是里面真正的字体名。如上面的font1.ttf里面的字体是MFQingShu_Noncommercial-Regular，那就直接用

UIFont *font = [UIFont fontWithName:@"MFQingShu_Noncommercial-Regular" size:12];就能去到正确的字体。

### 通过代码直接加载
[iOS使用自定义字体的方法:内置和任意下载ttf\otf\ttc字体文件](http://www.cnblogs.com/vicstudio/p/3961195.html)
1. swift代码
```swift
//MARK: 加载字体
func customFont(_ path:String, size:CGFloat) -> UIFont {
    let fontUrl = URL.init(fileURLWithPath: path)
    let fontDataProvider = CGDataProvider.init(url: fontUrl as CFURL)
    let fontRef = CGFont.init(fontDataProvider!)
    CTFontManagerRegisterGraphicsFont(fontRef!, nil)
    let fontName = fontRef?.postScriptName
    let font = UIFont.init(name: fontName! as String, size: size)
    return font!
}
```
2. objc代码
```objc
-(UIFont*)customFontWithPath:(NSString*)path size:(CGFloat)size
{
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}
```
### 开发局部视图插件
获取某控件相对于屏幕的坐标位置
```
let rect = ibExampleButton.convert(ibExampleButton.center, to: zhezView)
let x = tableView.frame.size.width/2 - 10
let y = rect.y
let tabrect = CGRect.init(origin: CGPoint.init(x: x, y: y), size: tableView.frame.size)
tableView.frame = tabrect
```
添加遮罩层屏蔽点击事件
```
let window = (UIApplication.shared.delegate?.window)!
zhezView = UIView.init(frame: (window?.bounds)!)
zhezView.isUserInteractionEnabled = true
let tap = UITapGestureRecognizer.init(target: self, action: #selector(IntelDescisionView.tapGestureAction(_:)))
tap.numberOfTapsRequired = 1
zhezView.addGestureRecognizer(tap)
```
### [swift中UIView从XIB加载(POP思想)](https://www.jianshu.com/p/8cbe0d767ba4)
1. 新建一个NibLoadable的swift文件.
```
protocol NibLoadable {
}
extension NibLoadable where Self : UIView {
    //在协议里面不允许定义class 只能定义static
    static func loadFromNib(_ nibname: String? = nil) -> Self {//Self (大写) 当前类对象
        //self(小写) 当前对象
        let loadName = nibname == nil ? "\(self)" : nibname!

        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}
```
2. 在需要使用XIB加载的页面实现该协议方法
```
class DemoView: UIView ,NibLoadable{
}
```
3. 使用方法
```
//3.1 xib文件与类名同名的情况
let demoView = DemoView.loadFromNib()
demoView.backgroundColor = UIColor.red
view.addSubview(demoView)

//3.2 xib文件与类名不相同的情况
let testV = TestView.loadFromNib("TestView0")
testV.backgroundColor = UIColor.green
view.addSubview(testV)
```

## 问题
基于Framework 无法获取Asset.cer图片资源
[让你的iOS库支持pod和carthage](https://www.jianshu.com/p/30246a000bc6)

解决：
新建bundle资源包，copy resource到framework目录下
Xcode创建bundle 在macOS项目分类中，创建之后需要把osx相关配置更改为iOS的，比较繁琐，图片为@2@3图片会合并为tiff格式。
建议手动创建一个目录，重命名成后缀为`.bundle`即可。这样png文件不会被转为tiff格式。
```
///借用了OHHTTPStubs方法，获取framework内部的bundle资源包
let bundles = OHResourceBundle("source", type(of: self))
iconImageView.image = UIImage.init(named: newValue.icon, in: bundles, compatibleWith: nil)
```

### jazzy配置
```
xcodebuild_arguments: [-project,"jinher.app.IntelDecision.xcodeproj", -scheme, 'jinher.app.IntelDecision',USE_SWIFT_RESPONSE_FILE=NO]
xcodebuild_arguments: [-workspace,'../../../../hexo.xcworkspace', -scheme, 'jinher.app.IntelDecision',USE_SWIFT_RESPONSE_FILE=NO]
```
