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
import AVFoundationn
import CoreVideo

class CaptureViewController: UIViewController {
  
  let captureSession = AVCaptureSession()
  var inputDevice: AVCaptureDevice!
  var input: AVCaptureDeviceInput!
  var output: AVCaptureVideoDataOutput!
  
  let cameraProcessingQueue = DispatchQueue.global()
  let frameRenderingSemaphore = DispatchSemaphore(value: 1)
  let cameraFrameProcessingQueue = DispatchQueue(label: "cameraFrameProcessingQueue", attributes: [])
  
  
  @IBOutlet weak var mtkView: CaptureView!
  var videoTextureCache: CVMetalTextureCache?
  
  var pixelBufferPool: CVPixelBufferPool!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, mtkView.device!, nil, &videoTextureCache)
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
  
  @IBAction func open(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    if sender.isSelected {
      startCapture()
    } else {
      stopCapture()
    }
  }
  
  func encode(_ texture: MTLTexture) {
    
    var processedPixelBuffer: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &processedPixelBuffer)
    guard let processedPixelBuffer_ = processedPixelBuffer else {
      return;
    }
    CVPixelBufferLockBaseAddress(processedPixelBuffer_, CVPixelBufferLockFlags(rawValue: 0))
    let outputTexture = texture
    let region = MTLRegionMake2D(0, 0, 720, 1280)
    let buffer = CVPixelBufferGetBaseAddress(processedPixelBuffer_)
    let bytesPerRow = 4 * region.size.width
    outputTexture.getBytes(buffer!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
    // ........
    CVPixelBufferUnlockBaseAddress(processedPixelBuffer_, CVPixelBufferLockFlags(rawValue: 0))
  }
}
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard frameRenderingSemaphore.wait(timeout: .now()) == .success else { return }
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)  else { return }
    let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
    let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
    
    
    // You must call the function before accessing pixel data with the CPU
    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    
    cameraFrameProcessingQueue.async {
      CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
      var textureRef: CVMetalTexture? = nil
      
      // 通过 CVImageBuffer 生成 CVMetalTexture
      // 将一帧转换成纹理
      if self.videoTextureCache == nil {
        fatalError("videoTextureCache none................")
      }
      CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                self.videoTextureCache!,
                                                pixelBuffer,
                                                nil,
                                                .bgra8Unorm,
                                                bufferWidth,
                                                bufferHeight,
                                                0,
                                                &textureRef)
      
      if let textureRef = textureRef, let cameraTexture = CVMetalTextureGetTexture(textureRef) {
        
        self.mtkView.newTextureAvailable(cameraTexture)
        
        //
        
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
