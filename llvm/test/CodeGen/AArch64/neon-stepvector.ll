; RUN: llc -mtriple=aarch64-linux-gnu -mattr=+neon < %s | FileCheck %s --check-prefixes=CHECK

; LEGAL INTEGER TYPES

define <2 x i64> @stepvector_v2i64() {
; CHECK-LABEL: .LCPI0_0:
; CHECK-NEXT:    .xword 0
; CHECK-NEXT:    .xword 1
; CHECK-LABEL: stepvector_v2i64:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI0_0
; CHECK-NEXT:    ldr q0, [x8, :lo12:.LCPI0_0]
; CHECK-NEXT:    ret
entry:
  %0 = call <2 x i64> @llvm.stepvector.v2i64()
  ret <2 x i64> %0
}

define <4 x i32> @stepvector_v4i32() {
; CHECK-LABEL: .LCPI1_0:
; CHECK-NEXT:    .word 0
; CHECK-NEXT:    .word 1
; CHECK-NEXT:    .word 2
; CHECK-NEXT:    .word 3
; CHECK-LABEL: stepvector_v4i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI1_0
; CHECK-NEXT:    ldr q0, [x8, :lo12:.LCPI1_0]
; CHECK-NEXT:    ret
entry:
  %0 = call <4 x i32> @llvm.stepvector.v4i32()
  ret <4 x i32> %0
}

define <8 x i16> @stepvector_v8i16() {
; CHECK-LABEL: .LCPI2_0:
; CHECK-NEXT:    .hword 0
; CHECK-NEXT:    .hword 1
; CHECK-NEXT:    .hword 2
; CHECK-NEXT:    .hword 3
; CHECK-NEXT:    .hword 4
; CHECK-NEXT:    .hword 5
; CHECK-NEXT:    .hword 6
; CHECK-NEXT:    .hword 7
; CHECK-LABEL: stepvector_v8i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI2_0
; CHECK-NEXT:    ldr q0, [x8, :lo12:.LCPI2_0]
; CHECK-NEXT:    ret
entry:
  %0 = call <8 x i16> @llvm.stepvector.v8i16()
  ret <8 x i16> %0
}

define <16 x i8> @stepvector_v16i8() {
; CHECK-LABEL: .LCPI3_0:
; CHECK-NEXT:    .byte 0
; CHECK-NEXT:    .byte 1
; CHECK-NEXT:    .byte 2
; CHECK-NEXT:    .byte 3
; CHECK-NEXT:    .byte 4
; CHECK-NEXT:    .byte 5
; CHECK-NEXT:    .byte 6
; CHECK-NEXT:    .byte 7
; CHECK-NEXT:    .byte 8
; CHECK-NEXT:    .byte 9
; CHECK-NEXT:    .byte 10
; CHECK-NEXT:    .byte 11
; CHECK-NEXT:    .byte 12
; CHECK-NEXT:    .byte 13
; CHECK-NEXT:    .byte 14
; CHECK-NEXT:    .byte 15
; CHECK-LABEL: stepvector_v16i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI3_0
; CHECK-NEXT:    ldr q0, [x8, :lo12:.LCPI3_0]
; CHECK-NEXT:    ret
entry:
  %0 = call <16 x i8> @llvm.stepvector.v16i8()
  ret <16 x i8> %0
}

; ILLEGAL INTEGER TYPES

define <4 x i64> @stepvector_v4i64() {
; CHECK-LABEL: .LCPI4_0:
; CHECK-NEXT:    .xword 0
; CHECK-NEXT:    .xword 1
; CHECK-LABEL: .LCPI4_1:
; CHECK-NEXT:    .xword 2
; CHECK-NEXT:    .xword 3
; CHECK-LABEL: stepvector_v4i64:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI4_0
; CHECK-NEXT:    adrp x9, .LCPI4_1
; CHECK-NEXT:    ldr q0, [x8, :lo12:.LCPI4_0]
; CHECK-NEXT:    ldr q1, [x9, :lo12:.LCPI4_1]
; CHECK-NEXT:    ret
entry:
  %0 = call <4 x i64> @llvm.stepvector.v4i64()
  ret <4 x i64> %0
}

define <16 x i32> @stepvector_v16i32() {
; CHECK-LABEL: .LCPI5_0:
; CHECK-NEXT:    .word 0
; CHECK-NEXT:    .word 1
; CHECK-NEXT:    .word 2
; CHECK-NEXT:    .word 3
; CHECK-LABEL: .LCPI5_1:
; CHECK-NEXT:    .word 4
; CHECK-NEXT:    .word 5
; CHECK-NEXT:    .word 6
; CHECK-NEXT:    .word 7
; CHECK-LABEL: .LCPI5_2:
; CHECK-NEXT:    .word 8
; CHECK-NEXT:    .word 9
; CHECK-NEXT:    .word 10
; CHECK-NEXT:    .word 11
; CHECK-LABEL: .LCPI5_3:
; CHECK-NEXT:    .word 12
; CHECK-NEXT:    .word 13
; CHECK-NEXT:    .word 14
; CHECK-NEXT:    .word 15
; CHECK-LABEL: stepvector_v16i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI5_0
; CHECK-NEXT:    adrp x9, .LCPI5_1
; CHECK-NEXT:    adrp x10, .LCPI5_2
; CHECK-NEXT:    adrp x11, .LCPI5_3
; CHECK-NEXT:    ldr q0, [x8, :lo12:.LCPI5_0]
; CHECK-NEXT:    ldr q1, [x9, :lo12:.LCPI5_1]
; CHECK-NEXT:    ldr q2, [x10, :lo12:.LCPI5_2]
; CHECK-NEXT:    ldr q3, [x11, :lo12:.LCPI5_3]
; CHECK-NEXT:    ret
entry:
  %0 = call <16 x i32> @llvm.stepvector.v16i32()
  ret <16 x i32> %0
}

define <2 x i32> @stepvector_v2i32() {
; CHECK-LABEL: .LCPI6_0:
; CHECK-NEXT:    .word 0
; CHECK-NEXT:    .word 1
; CHECK-LABEL: stepvector_v2i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI6_0
; CHECK-NEXT:    ldr d0, [x8, :lo12:.LCPI6_0]
; CHECK-NEXT:    ret
entry:
  %0 = call <2 x i32> @llvm.stepvector.v2i32()
  ret <2 x i32> %0
}

define <4 x i16> @stepvector_v4i16() {
; CHECK-LABEL: .LCPI7_0:
; CHECK-NEXT:    .hword 0
; CHECK-NEXT:    .hword 1
; CHECK-NEXT:    .hword 2
; CHECK-NEXT:    .hword 3
; CHECK-LABEL: stepvector_v4i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    adrp x8, .LCPI7_0
; CHECK-NEXT:    ldr d0, [x8, :lo12:.LCPI7_0]
; CHECK-NEXT:    ret
entry:
  %0 = call <4 x i16> @llvm.stepvector.v4i16()
  ret <4 x i16> %0
}


declare <2 x i64> @llvm.stepvector.v2i64()
declare <4 x i32> @llvm.stepvector.v4i32()
declare <8 x i16> @llvm.stepvector.v8i16()
declare <16 x i8> @llvm.stepvector.v16i8()

declare <4 x i64> @llvm.stepvector.v4i64()
declare <16 x i32> @llvm.stepvector.v16i32()
declare <2 x i32> @llvm.stepvector.v2i32()
declare <4 x i16> @llvm.stepvector.v4i16()
