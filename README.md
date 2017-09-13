##前言
我们一般创建ar项目都是Augumented Reality App，系统会给我们生成一些代码。今天我们我们就从普通的Single View App一步步创建实现ar项目
##太阳公转ar小项目
###创建项目
这一部分是创建项目、然后创建从一个viewcontroller点击按钮present进入到我们的SunRevolutionViewController。这些比较简单，我就一笔带过
![这里写图片描述](http://img.blog.csdn.net/20170912171929595?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
>ps **由于用到相机，所以我们要添加相机权限**
```
 <key>NSCameraUsageDescription</key>
 <string>应用将要使用您的照相机</string>
```
###核心地带
####1. 初始化arview必须的类
- 初始化arview必须的类  
>ARSCNView（展示ar）
>ARSession （负责相机与模型的交互）
>ARWorldTrackingConfiguration（追踪设备方向的基本配置）
```
 let arSCNView = ARSCNView()
    let arSession = ARSession()
    let arConfiguration = ARWorldTrackingConfiguration()
   
```
- 重写viewviewapper，让ARWorldTrackingConfiguration追踪我们的配置
```
  override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
        arConfiguration.isLightEstimationEnabled = true//自适应灯光（室內到室外的話 畫面會比較柔和）
        
        arSession.run(arConfiguration)
    }
```
- 添加arview，并设置代理
```
class SunRevolutionViewController: UIViewController,ARSCNViewDelegate {
```
```
    //设置arSCNView属性
        arSCNView.frame = self.view.frame
        
        arSCNView.session = arSession
        arSCNView.automaticallyUpdatesLighting = true//自动调节亮度
        
        
        
        self.view.addSubview(arSCNView)
        
        arSCNView.delegate = self
```
此时的效果图

###2 添加太阳、地球、月亮节点
添加太阳、地球、月亮节点，让他们显示在我们的屏幕上

>我们让月亮节点放到地球节点上，地球节点放到太阳节点上

```
//初始化节点信息
    func initNode()  {
        
        //1.设置几何
        sunNode.geometry = SCNSphere(radius: 3)
        earthNode.geometry =  SCNSphere(radius: 1)
        moonNode.geometry =  SCNSphere(radius: 0.5)
        //2.渲染图
     // multiply： 把整张图拉伸，之后会变淡
     //diffuse:平均扩散到整个物体的表面，平切光泽透亮
   //   AMBIENT、DIFFUSE、SPECULAR属性。这三个属性与光源的三个对应属性类似，每一属性都由四个值组成。AMBIENT表示各种光线照射到该材质上，经过很多次反射后最终遗留在环境中的光线强度（颜色）。DIFFUSE表示光线照射到该材质上，经过漫反射后形成的光线强度（颜色）。SPECULAR表示光线照射到该材质上，经过镜面反射后形成的光线强度（颜色）。通常，AMBIENT和DIFFUSE都取相同的值，可以达到比较真实的效果。
//        EMISSION属性。该属性由四个值组成，表示一种颜色。OpenGL认为该材质本身就微微的向外发射光线，以至于眼睛感觉到它有这样的颜色，但这光线又比较微弱，以至于不会影响到其它物体的颜色。
//        SHININESS属性。该属性只有一个值，称为“镜面指数”，取值范围是0到128。该值越小，表示材质越粗糙，点光源发射的光线照射到上面，也可以产生较大的亮点。该值越大，表示材质越类似于镜面，光源照射到上面后，产生较小的亮点。
        
        sunNode.geometry?.firstMaterial?.multiply.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5 //強度
        sunNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        //  地球图
        
        earthNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/earth-diffuse-mini.jpg"
        //  地球夜光图
         earthNode.geometry?.firstMaterial?.emission.contents = "art.scnassets/earth/earth-emissive-mini.jpg";
         earthNode.geometry?.firstMaterial?.specular.contents = "art.scnassets/earth/earth-specular-mini.jpg";
        
        //    月球圖
        moonNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/moon.jpg";
        
        //3.设置位置
        
        sunNode.position = SCNVector3(0, 5, -20)
        
        earthNode.position = SCNVector3(10, 0, 0)
        
        moonNode.position = SCNVector3(3, 0, 0)
        
        //4.让rootnode为sun sun上添加earth earth添加moon
        
        sunNode.addChildNode(earthNode)
        
        earthNode.addChildNode(moonNode)
        
        
        self.arSCNView.scene.rootNode.addChildNode(sunNode)
    }
```
此时我们的三个节点显示出来了
![这里写图片描述](http://img.blog.csdn.net/20170912183950380?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

###3 设置转动
####设置太阳自转
```
 //MARK：设置太阳自转
    func sunRotation()  {
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 10.0//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        sunNode.addAnimation(animation, forKey: "sun-texture")
        
        
        
    }
```
![太阳自转](http://img.blog.csdn.net/20170913100946981?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
> 由于地球和月球都放到了太阳节点上，所以地球和月球会跟着太阳转动

####设置地球地球和月球之间的转动
```
  earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)), forKey: "earth-texture")//duration标识速度 数字越小数字速度越快
        //设置月球自转
```
![地球自转](http://img.blog.csdn.net/20170913101150053?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
>duration标识速度 数字越小数字速度越快 比如修改数字为0.1后的效果

![电动小月球](http://img.blog.csdn.net/20170913102102104?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> 由于月球公转和地球自转的周期不一致，所以月球不能放到地球节点上    
> 创建一个月球围绕地球节点（与地球节点位置相同），让月球放到地月节点上，让这个节点自转，设置转动速度即可

代码修改为
```
 let moonRotationNode = SCNNode()//月球围绕地球转动的节点
```

  
```
  earthNode.position = SCNVector3(3, 0, 0)

 moonRotationNode.position = earthNode.position //设置月球围绕地球转动的节点位置与地球的位置相同
    
```

```
func earthTurn()  {
       //苹果有一套自带的动画
        earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)), forKey: "earth-texture")//duration标识速度 数字越小数字速度越快
        //设置月球自转
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 1.5//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        moonNode.addAnimation(animation, forKey: "moon-rotation")//月球自转
        
        //设置月球公转
        let moonRotationAnimation = CABasicAnimation(keyPath: "rotation")
        
        moonRotationAnimation.duration = 5//速度
        
        moonRotationAnimation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        moonRotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        
        
        moonRotationNode.addAnimation(moonRotationAnimation, forKey: "moon rotation around earth")
       
        
    }
```

####设置公转

公转和月球围绕地球转动类似，创建一个地月节点，地月节点上防止地球节点和月球围绕地球节点，月球围绕地球节点放置月球节点，如图所示
![节点关系图](http://img.blog.csdn.net/20170913111001547?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

代码

```
 let earthGroupNode =  SCNNode()//地球和月球当做一个整体的节点 围绕太阳公转需要
   
```

```
   //3.设置位置
        
        sunNode.position = SCNVector3(0, 5, -20)
        
        
        earthGroupNode.position = SCNVector3(10,0,0)//地月节点距离太阳的10
        
        earthNode.position = SCNVector3(3, 0, 0)
        
        moonRotationNode.position = earthNode.position //设置月球围绕地球转动的节点位置与地球的位置相同
        
        
        moonNode.position = SCNVector3(3, 0, 0)//月球距离月球围绕地球转动距离3
        
        //4.让rootnode为sun sun上添加earth earth添加moon
        
//        sunNode.addChildNode(earthNode)
        
//        earthNode.addChildNode(moonNode)
        
        moonRotationNode.addChildNode(moonNode)
        
        earthGroupNode.addChildNode(earthNode)
        earthGroupNode.addChildNode(moonRotationNode)
        
        
        sunNode.addChildNode(earthGroupNode)
        
        
        self.arSCNView.scene.rootNode.addChildNode(sunNode)
```
最终效果图
![公转](http://img.blog.csdn.net/20170913105314513?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
###添加光的效果
```
 //MARK://设置太阳光晕和被光找到的地方
    func addLight() {
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.red //被光找到的地方颜色
        
        
        sunNode.addChildNode(lightNode)
        
        lightNode.light?.attenuationEndDistance = 20.0 //光照的亮度随着距离改变
        lightNode.light?.attenuationStartDistance = 1.0
        
        SCNTransaction.begin()
        
        
        SCNTransaction.animationDuration = 1
        
        
        
        lightNode.light?.color =  UIColor.white
        lightNode.opacity = 0.5 // make the halo stronger
        
        SCNTransaction.commit()
        
        sunHaloNode.geometry = SCNPlane.init(width: 25, height: 25)
        
        sunHaloNode.rotation = SCNVector4Make(1, 0, 0, Float(0 * Double.pi / 180.0))
        sunHaloNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun-halo.png"
        sunHaloNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant // no lighting
        sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false // 不要有厚度，看起来薄薄的一层
        sunHaloNode.opacity = 5
        
        sunHaloNode.addChildNode(sunHaloNode)
    }
    
```
![最终效果](http://img.blog.csdn.net/20170913121516195?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGl5YW5qdW4yMDE=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
123

>可以看到地球被光找到的地方会发亮，还有太阳周围有一层光晕