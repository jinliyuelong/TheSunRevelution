//
//  SunRevolutionViewController.swift
//  TheSunRevelution
//
//  Created by Liyanjun on 2017/9/12.
//  Copyright © 2017年 liyanjun. All rights reserved.
//

import UIKit
//引入ARkit所需的包
import ARKit
import SceneKit


class SunRevolutionViewController: UIViewController,ARSCNViewDelegate {
    
    //需要arscenview、ARSession、ARConfiguration ar必备的三个
    
    let arSCNView = ARSCNView()
    let arSession = ARSession()
    let arConfiguration = ARWorldTrackingConfiguration()
    
    //添加太阳、地球、月亮节点
    let sunNode = SCNNode()
    let moonNode = SCNNode()
    let earthNode = SCNNode()
    let moonRotationNode = SCNNode()//月球围绕地球转动的节点
    let earthGroupNode =  SCNNode()//地球和月球当做一个整体的节点 围绕太阳公转需要
    
    let sunHaloNode = SCNNode()//太阳光晕
    
    
    
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSession.pause()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arConfiguration.isLightEstimationEnabled = true//自适应灯光（室內到室外的話 畫面會比較柔和）
        
        arSession.run(arConfiguration, options: [.removeExistingAnchors,.resetTracking])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //设置arSCNView属性
        arSCNView.frame = self.view.frame
        
        arSCNView.session = arSession
        arSCNView.automaticallyUpdatesLighting = true//自动调节亮度
        
        self.view.addSubview(arSCNView)
        
        arSCNView.delegate = self
        
        self.initNode()
        
        self.sunRotation()
        
        self.earthTurn()
        
        self.sunTurn()
        
        self.addLight()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:初始化节点信息
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
    }
    
    //MARK：设置太阳自转
    func sunRotation()  {
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 10.0//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        sunNode.addAnimation(animation, forKey: "sun-texture")
        
        
        
    }
    //MARK:设置地球自转和月亮围绕地球转
    /**
     月球如何围绕地球转呢
     可以把月球放到地球上，让地球自转月球就会跟着地球，但是月球的转动周期和地球的自转周期是不一样的，所以创建一个月球围绕地球节点（与地球节点位置相同），让月球放到地月节点上，让这个节点自转，设置转动速度即可
     */
    
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
    
    
    //MARK：设置地球公转
    func sunTurn()  {
        
        let animation = CABasicAnimation(keyPath: "rotation")
        
        animation.duration = 10//速度
        
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))//围绕自己的y轴转动
        
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        earthGroupNode.addAnimation(animation, forKey: "earth rotation around sun")//月球自转
        
    }
    
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
    
    
}
