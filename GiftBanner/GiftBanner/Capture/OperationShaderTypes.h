//
//  OperationShaderTypes.h
//  GiftBanner
//
//  Created by Frank_s on 2018/11/23.
//  Copyright © 2018 Frank_s. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef OperationShaderTypes_h
#define OperationShaderTypes_h

struct SingleInputVertexIO
{
  float4 position [[position]];
  float2 textureCoordinate [[user(texturecoord)]];
};

#endif /* OperationShaderTypes_h */
