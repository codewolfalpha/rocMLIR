// RUN: rocmlir-opt --rock-sugar-to-loops %s | FileCheck %s

module {
// CHECK-LABEL: func.func @load_scalar_in_bounds
// CHECK-SAME: (%[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @load_scalar_in_bounds(%mem: memref<1x2x3x4x8xf32>) -> f32 {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: %[[ret:.*]] = amdgpu.raw_buffer_load {boundsCheck = false} %[[mem]]
    %ret = rock.buffer_load %mem[%c0, %c0, %c0, %c0, %c0] if %true
        : memref<1x2x3x4x8xf32>, index, index, index, index, index -> f32
    // CHECK: return %[[ret]]
    return %ret : f32
}

// CHECK-LABEL: func.func @load_scalar_in_bounds_force_oob
// CHECK-SAME: (%[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @load_scalar_in_bounds_force_oob(%mem: memref<1x2x3x4x8xf32>) -> f32 {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: %[[ret:.*]] = amdgpu.raw_buffer_load %[[mem]]
    %ret = rock.buffer_load %mem[%c0, %c0, %c0, %c0, %c0] if %true
        {oobIsOverflow}
        : memref<1x2x3x4x8xf32>, index, index, index, index, index -> f32
    // CHECK: return %[[ret]]
    return %ret : f32
}


// CHECK-LABEL: func.func @load_vector_in_bounds
// CHECK-SAME: (%[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @load_vector_in_bounds(%mem: memref<1x2x3x4x8xf32>) -> vector<4xf32> {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: %[[ret:.*]] = amdgpu.raw_buffer_load {boundsCheck = false} %[[mem]]
    %ret = rock.buffer_load %mem[%c0, %c0, %c0, %c0, %c0] if %true
        : memref<1x2x3x4x8xf32>, index, index, index, index, index -> vector<4xf32>
    // CHECK: return %[[ret]]
    return %ret : vector<4xf32>
}

// CHECK-LABEL: func.func @load_vector_in_bounds_offset
// CHECK-SAME: (%[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @load_vector_in_bounds_offset(%mem: memref<1x2x3x4x8xf32>) -> vector<4xf32> {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: %[[ret:.*]] = amdgpu.raw_buffer_load {boundsCheck = false, indexOffset = 4 : i32} %[[mem]]
    %ret = rock.buffer_load %mem[%c0, %c0, %c0, %c0, %c0] if %true
        {offset = 4 : index}
        : memref<1x2x3x4x8xf32>, index, index, index, index, index -> vector<4xf32>
    // CHECK: return %[[ret]]
    return %ret : vector<4xf32>
}

// CHECK-LABEL: func.func @load_vector_oob
// CHECK-SAME: (%[[mem:.*]]: memref<1x2x3x4x8xf32>, %[[idx:.*]]: index, %[[valid:.*]]: i1)
func.func @load_vector_oob(%mem: memref<1x2x3x4x8xf32>, %idx: index, %valid: i1) -> vector<4xf32> {
    %c0 = arith.constant 0 : index
    // CHECK: %[[c192:.*]] = arith.constant 192
    // CHECK: arith.select %[[valid]], %[[idx]], %[[c192]]
    %ret = rock.buffer_load %mem[%c0, %c0, %c0, %c0, %idx] if %valid
        : memref<1x2x3x4x8xf32>, index, index, index, index, index -> vector<4xf32>
    return %ret : vector<4xf32>
}

// CHECK-LABEL: func.func @load_scalar
// CHECK-SAME: (%[[mem:.*]]: memref<f32>, %[[idx:.*]]: index, %[[valid:.*]]: i1)
func.func @load_scalar(%mem: memref<f32>, %idx: index, %valid: i1) -> f32 {
    %c0 = arith.constant 0 : index
    // CHECK: %[[ret:.*]] = amdgpu.raw_buffer_load {boundsCheck = false} %[[mem]][] : memref<f32> -> f32
    %ret = rock.buffer_load %mem[] if %valid
        : memref<f32> -> f32
    return %ret : f32
}

// CHECK-LABEL: func.func @store_scalar_in_bounds
// CHECK-SAME: (%[[val:.*]]: f32, %[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @store_scalar_in_bounds(%val: f32, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: amdgpu.raw_buffer_store {boundsCheck = false} %[[val]] -> %[[mem]]
    rock.buffer_store set %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        : f32 -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @store_vector_in_bounds
// CHECK-SAME: (%[[val:.*]]: vector<4xf32>, %[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @store_vector_in_bounds(%val: vector<4xf32>, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: amdgpu.raw_buffer_store %[[val]] -> %[[mem]]
    rock.buffer_store set %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        {oobIsOverflow}
        : vector<4xf32> -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @store_vector_in_bounds_offset
// CHECK-SAME: (%[[val:.*]]: vector<4xf32>, %[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @store_vector_in_bounds_offset(%val: vector<4xf32>, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: amdgpu.raw_buffer_store {boundsCheck = false, indexOffset = 4 : i32} %[[val]] -> %[[mem]]
    rock.buffer_store set %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        {offset = 4 : index}
        : vector<4xf32> -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @store_vector_oob
// CHECK-SAME: (%[[val:.*]]: vector<4xf32>, %[[mem:.*]]: memref<1x2x3x4x8xf32>, %[[idx:.*]]: index, %[[valid:.*]]: i1)
func.func @store_vector_oob(%val: vector<4xf32>, %mem: memref<1x2x3x4x8xf32>, %idx: index, %valid: i1) {
    %c0 = arith.constant 0 : index
    // CHECK-DAG: %[[c192:.*]] = arith.constant 192
    // CHECK: arith.select %[[valid]], %[[idx]], %[[c192]]
    // CHECK: amdgpu.raw_buffer_store %[[val]] -> %[[mem]]
    rock.buffer_store set %val -> %mem[%c0, %c0, %c0, %c0, %idx] if %valid features = dot
        : vector<4xf32> -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @store_scalar_in_scalar
// CHECK-SAME: (%[[val:.*]]: f32, %[[mem:.*]]: memref<f32>, %[[idx:.*]]: index, %[[valid:.*]]: i1)
func.func @store_scalar_in_scalar(%val: f32, %mem: memref<f32>, %idx: index, %valid: i1) {
    %c0 = arith.constant 0 : index
    // CHECK: amdgpu.raw_buffer_store {boundsCheck = false} %[[val]] -> %[[mem]][] : f32 -> memref<f32>
    rock.buffer_store set %val -> %mem[] if %valid features = dot : f32 -> memref<f32>
    return
}

// CHECK-LABEL: func.func @add_scalar_in_bounds
// CHECK-SAME: (%[[val:.*]]: f32, %[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @add_scalar_in_bounds(%val: f32, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: amdgpu.raw_buffer_atomic_fadd {boundsCheck = false} %[[val]] -> %[[mem]]
    rock.buffer_store atomic_add %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        : f32 -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @add_vector_in_bounds
func.func @add_vector_in_bounds(%val: vector<4xf32>, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK-4: amdgpu.raw_buffer_atomic_fadd
    rock.buffer_store atomic_add %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        : vector<4xf32> -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @fmax_scalar_float_atomics
// CHECK-SAME: (%[[val:.*]]: f32, %[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @fmax_scalar_float_atomics(%val: f32, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: amdgpu.raw_buffer_atomic_fmax {boundsCheck = false} %[[val]] -> %[[mem]]
    rock.buffer_store atomic_max %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot|atomic_fmax_f32
        : f32 -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @fmax_vector_float_atomics
func.func @fmax_vector_float_atomics(%val: vector<4xf32>, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK-4: amdgpu.raw_buffer_atomic_fmax
    rock.buffer_store atomic_max %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot|atomic_fmax_f32
        : vector<4xf32> -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @fmax_scalar_integer_atomics
// CHECK-SAME: (%[[val:.*]]: f32, %[[mem:.*]]: memref<1x2x3x4x8xf32>)
func.func @fmax_scalar_integer_atomics(%val: f32, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK-DAG:  %[[C0:.*]] = arith.constant 0 : i32
    // CHECK-DAG:  %[[VAL_I32:.*]] = llvm.bitcast %[[val]] : f32 to i32
    // CHECK-DAG:  %[[MSB_BITMASK:.*]] = arith.constant -2147483648 : i32
    // CHECK-DAG:  %[[MSB:.*]] = arith.andi %[[VAL_I32]], %[[MSB_BITMASK]] : i32
    // CHECK-DAG:  %[[IS_POSITIVE:.*]] = arith.cmpi eq, %[[MSB]], %[[C0]] : i32
    // CHECK: scf.if %[[IS_POSITIVE]]
    // CHECK: amdgpu.raw_buffer_atomic_smax {boundsCheck = false} %[[VAL_I32]] -> %[[mem]]
    // CHECK: else
    // CHECK: amdgpu.raw_buffer_atomic_umin {boundsCheck = false} %[[VAL_I32]] -> %[[mem]]
    rock.buffer_store atomic_max %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        : f32 -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

// CHECK-LABEL: func.func @fmax_vector_integer_atomics
func.func @fmax_vector_integer_atomics(%val: vector<4xf32>, %mem: memref<1x2x3x4x8xf32>) {
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    // CHECK: scf.if
    // CHECK: amdgpu.raw_buffer_atomic_smax
    // CHECK: else
    // CHECK: amdgpu.raw_buffer_atomic_umin
    // CHECK: scf.if
    // CHECK: amdgpu.raw_buffer_atomic_smax
    // CHECK: else
    // CHECK: amdgpu.raw_buffer_atomic_umin
    // CHECK: scf.if
    // CHECK: amdgpu.raw_buffer_atomic_smax
    // CHECK: else
    // CHECK: amdgpu.raw_buffer_atomic_umin
    // CHECK: scf.if
    // CHECK: amdgpu.raw_buffer_atomic_smax
    // CHECK: else
    // CHECK: amdgpu.raw_buffer_atomic_umin
    rock.buffer_store atomic_max %val -> %mem[%c0, %c0, %c0, %c0, %c0] if %true features = dot
        : vector<4xf32> -> memref<1x2x3x4x8xf32>, index, index, index, index, index
    return
}

}
