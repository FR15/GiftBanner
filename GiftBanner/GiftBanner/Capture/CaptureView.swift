//
//  CaptureView.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/22.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import MetalKit

// 顶点坐标
let standardImageVertices: [Float] = [
  -1.0, -1.0,
   1.0, -1.0,
  -1.0,  1.0,
   1.0,  1.0
]

// 顶点坐标和纹理坐标 y轴是反的
// 纹理坐标和UIKit坐标系一致
// 取纹理的上半部分其实传的是下半部分
let textureCoordinate: [Float] = [
  1.0, 1.0,
  1.0, 0.0,
  0.0, 1.0,
  0.0, 0.0
]

class CaptureView: MTKView {
  
  var renderPipelineState: MTLRenderPipelineState!
  var commandQueue: MTLCommandQueue! // gpu 任务队列
  var currentTexture: MTLTexture! // 记录当前帧映射的纹理
  var vertexBuffer:  MTLBuffer! // 顶点坐标
  var textureBuffer: MTLBuffer! // 纹理坐标
  
  
  public override init(frame frameRect: CGRect, device: MTLDevice?) {
    super.init(frame: frameRect, device: device)
    commonInit()
  }
  
  public required init(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  // device
  // library: vertextFunc + fragmentFunc
  // pipeline descriptor -> pipeline
  // command queue: make command buffer
  // command encoder
  //
  
  func commonInit() {
    framebufferOnly = false
    autoResizeDrawable = true
    enableSetNeedsDisplay = false
    isPaused = true
    
    // device
    guard let device_ = MTLCreateSystemDefaultDevice() else {
      fatalError("device none.............")
    }
    device = device_
    // library
    guard let defaultLibrary = device!.makeDefaultLibrary() else {
      fatalError("defaultLibrary none.............")
    }
    // 顶点着色器
    guard let vertextFunc = defaultLibrary.makeFunction(name: "oneInputVertex")  else {
      fatalError("vertextFunc none.............")
    }
    // 片元着色器
    guard let fragmentFunc = defaultLibrary.makeFunction(name: "passthroughFragment")  else {
      fatalError("fragmentFunc none.............")
    }
    
    // pipeline
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
    descriptor.rasterSampleCount = 1
    descriptor.vertexFunction = vertextFunc
    descriptor.fragmentFunction = fragmentFunc
    do {
      renderPipelineState = try device!.makeRenderPipelineState(descriptor: descriptor)
    } catch _ {
      fatalError("renderPipelineState none.............")
    }
    
    // command queue
    guard let commandQueue_ = device!.makeCommandQueue() else {
      fatalError("command queue none..............")
    }
    commandQueue = commandQueue_
    
    // 顶点坐标， 纹理坐标
    vertexBuffer = device!.makeBuffer(bytes: standardImageVertices, length: standardImageVertices.count * MemoryLayout<Float>.size, options: [])!
    vertexBuffer.label = "ding_dian_zuo_biao"
    
    textureBuffer = device!.makeBuffer(bytes: textureCoordinate, length: textureCoordinate.count * MemoryLayout<Float>.size, options: [])!
    textureBuffer.label = "wen_li_zuo_biao"
  }
  
  func newTextureAvailable(_ texture: MTLTexture) {
    self.drawableSize = CGSize(width: texture.width, height: texture.height)
    currentTexture = texture
    self.draw()
  }
  
  override func draw(_ rect: CGRect) {
    
    if currentDrawable == nil {
      fatalError("currentDrawable none..............")
    }
    
    // command
    let commandBuffer = commandQueue.makeCommandBuffer()
    if commandBuffer == nil {
      fatalError("commandBuffer none..............")
    }
    commandBuffer!.label = "Command"
    
    // command encoder descriptor
    let renderPass = MTLRenderPassDescriptor()
    renderPass.colorAttachments[0].texture     = currentDrawable!.texture // ???
    renderPass.colorAttachments[0].clearColor  = MTLClearColorMake(1, 0, 0, 1)
    renderPass.colorAttachments[0].storeAction = .store
    renderPass.colorAttachments[0].loadAction  = .clear
    
    // command encoder
    let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPass)
    if renderEncoder == nil {
      fatalError("renderEncoder none .............")
    }
    renderEncoder!.setFrontFacing(.counterClockwise)
    renderEncoder!.setRenderPipelineState(renderPipelineState)
    
    // 顶点坐标传入顶点着色器
    renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    // 纹理坐标传入顶点着色器
    renderEncoder!.setVertexBuffer(textureBuffer, offset: 0, index: 1)
    // 纹理传入片元着色器
    renderEncoder!.setFragmentTexture(currentTexture, index: 0)
    
    renderEncoder!.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    renderEncoder!.endEncoding()
    
//    encode(currentDrawable!.texture)
    
    commandBuffer!.present(currentDrawable!)
    commandBuffer!.commit()
  }
}

