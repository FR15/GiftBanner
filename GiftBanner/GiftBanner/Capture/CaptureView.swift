//
//  CaptureView.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/22.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import MetalKit


let standardImageVertices:[Float] = [
  -1.0, -1.0,
   1.0, -1.0,
  -1.0,  1.0,
   1.0,  1.0
]


class CaptureView: MTKView {
  
  var renderPipelineState: MTLRenderPipelineState!
  var commandQueue: MTLCommandQueue!
  var currentTexture: MTLTexture!
  
  
  public override init(frame frameRect: CGRect, device: MTLDevice?) {
    super.init(frame: frameRect, device: device)
    commonInit()
  }
  
  public required init(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  func commonInit() {
    framebufferOnly = false
    autoResizeDrawable = true
    enableSetNeedsDisplay = false
    isPaused = true
    
    guard let device = device else {
      fatalError("device none.............")
    }
    guard let defaultLibrary = device.makeDefaultLibrary() else {
      fatalError("defaultLibrary none.............")
    }
    guard let vertextFunc = defaultLibrary.makeFunction(name: "")  else {
      fatalError("vertextFunc none.............")
    }
    guard let fragmentFunc = defaultLibrary.makeFunction(name: "")  else {
      fatalError("fragmentFunc none.............")
    }
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
    descriptor.rasterSampleCount = 1
    descriptor.vertexFunction = vertextFunc
    descriptor.fragmentFunction = fragmentFunc
    do {
      renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
    } catch _ {
      fatalError("renderPipelineState none.............")
    }
    
    guard let commandQueue_ = device.makeCommandQueue() else { fatalError("command queue none..............") }
    commandQueue = commandQueue_
  }
  
  func newTextureAvailable(_ texture: MTLTexture) {
    self.drawableSize = CGSize(width: texture.width, height: texture.height)
    currentTexture = texture
    self.draw()
  }
  
  override func draw(_ rect: CGRect) {
    if let currentDrawable = currentDrawable {
      let commandBuffer = commandQueue.makeCommandBuffer()
      
      
    }
  }
  
  func renderQuad() {
    
    guard let device = device else {
      fatalError("device none.............")
    }
    
    guard let vertexBuffer = device.makeBuffer(bytes: standardImageVertices, length: standardImageVertices.count * MemoryLayout<Float>.size, options: []) else {
      fatalError("device none.............")
      
    }
    vertexBuffer.label = "Vertices"
    
    let renderPass = MTLRenderPassDescriptor()
    renderPass.colorAttachments[0].texture     = outputTexture.texture
    renderPass.colorAttachments[0].clearColor  = MTLClearColorMake(1, 0, 0, 1)
    renderPass.colorAttachments[0].storeAction = .store
    renderPass.colorAttachments[0].loadAction  = .clear
    
    guard let renderEncoder =  else {
      <#statements#>
    }
    
    
    
    
  }
}

extension MTLCommandBuffer {

  func renderQuad(pipelineState: MTLRenderPipelineState, outputTexture: MTLTexture, inputTexture: MTLTexture, device: MTLDevice) {
    
    // 顶点数据 buffer
    let vertexBuffer = device.makeBuffer(bytes: standardImageVertices, length: standardImageVertices.count * MemoryLayout<Float>.size, options: [])!
    vertexBuffer.label = "Vertices"
    
    // 目的是用来创建 MTLRenderCommandEncoder
    let renderPass = MTLRenderPassDescriptor()
    renderPass.colorAttachments[0].texture     = outputTexture
    renderPass.colorAttachments[0].clearColor  = MTLClearColorMake(1, 0, 0, 1)
    renderPass.colorAttachments[0].storeAction = .store
    renderPass.colorAttachments[0].loadAction  = .clear
    
    guard let renderEncoder = self.makeRenderCommandEncoder(descriptor: renderPass) else {
      fatalError("Could not create render encoder")
    }
    renderEncoder.setFrontFacing(.counterClockwise)
    renderEncoder.setRenderPipelineState(pipelineState)
    // 将顶点坐标传入顶点着色器
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    // 纹理坐标
    let inputTextureCoordinates: [Float] = []
    // 纹理坐标 buffer
    let textureBuffer = device.makeBuffer(bytes: inputTextureCoordinates,length: inputTextureCoordinates.count * MemoryLayout<Float>.size,options: [])!
    textureBuffer.label = "Texture Coordinates"
    
    // 将纹理坐标传入顶点着色器
    renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 1 + textureIndex)
    // 设置片元着色器
    renderEncoder.setFragmentTexture(inputTexture, index: textureIndex)
    //
    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    renderEncoder.endEncoding()
  }
}
