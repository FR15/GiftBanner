//
//  CaptureViewController.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/21.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import AVFoundation
import CoreVideo

class CaptureViewController: UIViewController {
  
  let captureSession = AVCaptureSession()
  var inputDevice: AVCaptureDevice!
  var input: AVCaptureDeviceInput!
  var output: AVCaptureVideoDataOutput!
  
  let cameraProcessingQueue = DispatchQueue.global()
  let frameRenderingSemaphore = DispatchSemaphore(value: 1)
  let cameraFrameProcessingQueue = DispatchQueue(label: "cameraFrameProcessingQueue", attributes: [])
  
  
  var mtkView: CaptureView!
  var device: MTLDevice!
  var commandQueue: MTLCommandQueue!
  var shaderLibrary: MTLLibrary!
  var videoTextureCache: CVMetalTextureCache?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let device_ = MTLCreateSystemDefaultDevice() else { fatalError("device none..............") }
    device = device_
    guard let commandQueue_ = device.makeCommandQueue() else { fatalError("command queue none..............") }
    commandQueue = commandQueue_
    
    mtkView.device = device
    
    
    captureSession.beginConfiguration()
    inputDevice = AVCaptureDevice.default(for: .video)
    do {
      input = try AVCaptureDeviceInput(device: inputDevice)
    } catch {
      print(error.localizedDescription)
    }
    if captureSession.canAddInput(input) {
      captureSession.addInput(input)
    }
    
    output = AVCaptureVideoDataOutput()
    output.alwaysDiscardsLateVideoFrames = false
    output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:NSNumber(value:Int32(kCVPixelFormatType_32BGRA))]
    if captureSession.canAddOutput(output) {
      captureSession.addOutput(output)
    }
    captureSession.commitConfiguration()
    
    output.setSampleBufferDelegate(self, queue: cameraProcessingQueue)
    
    
    
    
    
    
    
    
  }
  
  func startCapture() {
    if !captureSession.isRunning {
      captureSession.startRunning()
    }
  }
  
  func stopCapture() {
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
  }
}
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard frameRenderingSemaphore.wait(timeout: .now()) == .success else { return }
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)  else { return }
    let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
    let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
    
    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    
    cameraFrameProcessingQueue.async {
      CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
      var textureRef: CVMetalTexture? = nil
      
      // 通过 CVImageBuffer 生成 CVMetalTexture
      // 将一帧转换成纹理
      CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                self.videoTextureCache!,
                                                pixelBuffer,
                                                nil,
                                                .bgra8Unorm,
                                                bufferWidth,
                                                bufferHeight,
                                                0,
                                                &textureRef)
      
      if let textureRef = textureRef,
        let cameraTexture = CVMetalTextureGetTexture(textureRef) {
        
        // 处理纹理
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: bufferWidth, height: bufferHeight, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        guard let newTexture = device.makeTexture(descriptor: textureDescriptor) else { fatalError("texture none..........") }
        
      }
      self.frameRenderingSemaphore.signal()
    }
  }
}

// Metal 渲染流程
// MTKView -> MTLDevice -> MTLCommandQueue
// -> MTLCommandBuffer

// MTLTextureDescriptor


// CVPixelBuffer
// an image buffer holds pixels
// a raw image format
