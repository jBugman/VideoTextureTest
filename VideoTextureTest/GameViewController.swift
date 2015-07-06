//
//  GameViewController.swift
//  VideoTextureTest
//
//  Created by Sergey Parshukov on 02.07.15.
//  Copyright (c) 2015 Sergey Parshukov. All rights reserved.
//

import UIKit
import Metal
import QuartzCore


let vertexData:[Float] = [
    -1, 1, 0,
    1, 1, 0,
    -1, -1, 0,
    1, -1, 0
]

class GameViewController: UIViewController {
    
    let device = MTLCreateSystemDefaultDevice()
    let metalLayer = CAMetalLayer()
    
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var vertexBuffer: MTLBuffer! = nil

    var texture: MTLTexture! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)

        texture = loadTexture("texture.png")

        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: nil)

        view.opaque = true

        let defaultLibrary = device.newDefaultLibrary()
        let vertexProgram = defaultLibrary?.newFunctionWithName("texturedQuadVertex")
        let fragmentProgram = defaultLibrary?.newFunctionWithName("texturedQuadFragment")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        var pipelineError : NSError?
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
        if (pipelineState == nil) {
            println("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.newCommandQueue()

        timer = CADisplayLink(target: self, selector: Selector("renderLoop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
   
    deinit {
        timer.invalidate()
    }
    
    func renderLoop() {
        autoreleasepool {
            self.render()
        }
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        let commandBuffer = commandQueue.commandBuffer()

        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        if let renderEncoder = renderEncoderOpt {
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            renderEncoder.setFragmentTexture(texture, atIndex: 0)
            renderEncoder.drawPrimitives(.TriangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
            renderEncoder.endEncoding()
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
}