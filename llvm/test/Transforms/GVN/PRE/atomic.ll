; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt -S -passes=gvn < %s | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"

@x = common global i32 0, align 4
@y = common global i32 0, align 4

; GVN across unordered store (allowed)
define i32 @test1() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test1
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr @y, align 4
; CHECK-NEXT:    store atomic i32 [[X]], ptr @x unordered, align 4
; CHECK-NEXT:    [[Z:%.*]] = add i32 [[X]], [[X]]
; CHECK-NEXT:    ret i32 [[Z]]
;
entry:
  %x = load i32, ptr @y
  store atomic i32 %x, ptr @x unordered, align 4
  %y = load i32, ptr @y
  %z = add i32 %x, %y
  ret i32 %z
}

; GVN across unordered load (allowed)
define i32 @test3() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test3
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr @y, align 4
; CHECK-NEXT:    [[Y:%.*]] = load atomic i32, ptr @x unordered, align 4
; CHECK-NEXT:    [[A:%.*]] = add i32 [[X]], [[X]]
; CHECK-NEXT:    [[B:%.*]] = add i32 [[Y]], [[A]]
; CHECK-NEXT:    ret i32 [[B]]
;
entry:
  %x = load i32, ptr @y
  %y = load atomic i32, ptr @x unordered, align 4
  %z = load i32, ptr @y
  %a = add i32 %x, %z
  %b = add i32 %y, %a
  ret i32 %b
}

; GVN load to unordered load (allowed)
define i32 @test5() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test5
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load atomic i32, ptr @x unordered, align 4
; CHECK-NEXT:    [[Z:%.*]] = add i32 [[X]], [[X]]
; CHECK-NEXT:    ret i32 [[Z]]
;
entry:
  %x = load atomic i32, ptr @x unordered, align 4
  %y = load i32, ptr @x
  %z = add i32 %x, %y
  ret i32 %z
}

; GVN unordered load to load (unordered load must not be removed)
define i32 @test6() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test6
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr @x, align 4
; CHECK-NEXT:    [[X2:%.*]] = load atomic i32, ptr @x unordered, align 4
; CHECK-NEXT:    [[X3:%.*]] = add i32 [[X]], [[X2]]
; CHECK-NEXT:    ret i32 [[X3]]
;
entry:
  %x = load i32, ptr @x
  %x2 = load atomic i32, ptr @x unordered, align 4
  %x3 = add i32 %x, %x2
  ret i32 %x3
}

; GVN across release-acquire pair (forbidden)
define i32 @test7() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test7
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr @y, align 4
; CHECK-NEXT:    store atomic i32 [[X]], ptr @x release, align 4
; CHECK-NEXT:    [[W:%.*]] = load atomic i32, ptr @x acquire, align 4
; CHECK-NEXT:    [[Y:%.*]] = load i32, ptr @y, align 4
; CHECK-NEXT:    [[Z:%.*]] = add i32 [[X]], [[Y]]
; CHECK-NEXT:    ret i32 [[Z]]
;
entry:
  %x = load i32, ptr @y
  store atomic i32 %x, ptr @x release, align 4
  %w = load atomic i32, ptr @x acquire, align 4
  %y = load i32, ptr @y
  %z = add i32 %x, %y
  ret i32 %z
}

; GVN across monotonic store (allowed)
define i32 @test9() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test9
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr @y, align 4
; CHECK-NEXT:    store atomic i32 [[X]], ptr @x monotonic, align 4
; CHECK-NEXT:    [[Z:%.*]] = add i32 [[X]], [[X]]
; CHECK-NEXT:    ret i32 [[Z]]
;
entry:
  %x = load i32, ptr @y
  store atomic i32 %x, ptr @x monotonic, align 4
  %y = load i32, ptr @y
  %z = add i32 %x, %y
  ret i32 %z
}

; GVN of an unordered across monotonic load (not allowed)
define i32 @test10() nounwind uwtable ssp {
; CHECK-LABEL: define i32 @test10
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load atomic i32, ptr @y unordered, align 4
; CHECK-NEXT:    [[CLOBBER:%.*]] = load atomic i32, ptr @x monotonic, align 4
; CHECK-NEXT:    [[Y:%.*]] = load atomic i32, ptr @y monotonic, align 4
; CHECK-NEXT:    [[Z:%.*]] = add i32 [[X]], [[Y]]
; CHECK-NEXT:    ret i32 [[Z]]
;
entry:
  %x = load atomic i32, ptr @y unordered, align 4
  %clobber = load atomic i32, ptr @x monotonic, align 4
  %y = load atomic i32, ptr @y monotonic, align 4
  %z = add i32 %x, %y
  ret i32 %z
}

define i32 @PR22708(i1 %flag) {
; CHECK-LABEL: define i32 @PR22708
; CHECK-SAME: (i1 [[FLAG:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[FLAG]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    store i32 43, ptr @y, align 4
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[TMP0:%.*]] = load atomic i32, ptr @x acquire, align 4
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, ptr @y, align 4
; CHECK-NEXT:    ret i32 [[LOAD]]
;
entry:
  br i1 %flag, label %if.then, label %if.end

if.then:
  store i32 43, ptr @y, align 4
  br label %if.end

if.end:
  load atomic i32, ptr @x acquire, align 4
  %load = load i32, ptr @y, align 4
  ret i32 %load
}

; Can't remove a load over a ordering barrier
define i32 @test12(i1 %B, ptr %P1, ptr %P2) {
; CHECK-LABEL: define i32 @test12
; CHECK-SAME: (i1 [[B:%.*]], ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[LOAD0:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i32, ptr [[P2]] seq_cst, align 4
; CHECK-NEXT:    [[LOAD1:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[B]], i32 [[LOAD0]], i32 [[LOAD1]]
; CHECK-NEXT:    ret i32 [[SEL]]
;
  %load0 = load i32, ptr %P1
  %1 = load atomic i32, ptr %P2 seq_cst, align 4
  %load1 = load i32, ptr %P1
  %sel = select i1 %B, i32 %load0, i32 %load1
  ret i32 %sel
}

; atomic to non-atomic forwarding is legal
define i32 @test13(ptr %P1) {
; CHECK-LABEL: define i32 @test13
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    ret i32 0
;
  %a = load atomic i32, ptr %P1 seq_cst, align 4
  %b = load i32, ptr %P1
  %res = sub i32 %a, %b
  ret i32 %res
}

define i32 @test13b(ptr %P1) {
; CHECK-LABEL: define i32 @test13b
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    store atomic i32 0, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    ret i32 0
;
  store  atomic i32 0, ptr %P1 unordered, align 4
  %b = load i32, ptr %P1
  ret i32 %b
}

; atomic to unordered atomic forwarding is legal
define i32 @test14(ptr %P1) {
; CHECK-LABEL: define i32 @test14
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    ret i32 0
;
  %a = load atomic i32, ptr %P1 seq_cst, align 4
  %b = load atomic i32, ptr %P1 unordered, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

; implementation restriction: can't forward to stonger
; than unordered
define i32 @test15(ptr %P1, ptr %P2) {
; CHECK-LABEL: define i32 @test15
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    [[RES:%.*]] = sub i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %a = load atomic i32, ptr %P1 seq_cst, align 4
  %b = load atomic i32, ptr %P1 seq_cst, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

; forwarding non-atomic to atomic is wrong! (However,
; it would be legal to use the later value in place of the
; former in this particular example.  We just don't
; do that right now.)
define i32 @test16(ptr %P1, ptr %P2) {
; CHECK-LABEL: define i32 @test16
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[RES:%.*]] = sub i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %a = load i32, ptr %P1, align 4
  %b = load atomic i32, ptr %P1 unordered, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

define i32 @test16b(ptr %P1) {
; CHECK-LABEL: define i32 @test16b
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    ret i32 [[B]]
;
  store i32 0, ptr %P1
  %b = load atomic i32, ptr %P1 unordered, align 4
  ret i32 %b
}

; Can't DSE across a full fence
define void @fence_seq_cst_store(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @fence_seq_cst_store
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    store atomic i32 0, ptr [[P2]] seq_cst, align 4
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, ptr %P1, align 4
  store atomic i32 0, ptr %P2 seq_cst, align 4
  store i32 0, ptr %P1, align 4
  ret void
}

; Can't DSE across a full fence
define void @fence_seq_cst(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @fence_seq_cst
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    fence seq_cst
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, ptr %P1, align 4
  fence seq_cst
  store i32 0, ptr %P1, align 4
  ret void
}

; Can't DSE across a full syncscope("singlethread") fence
define void @fence_seq_cst_st(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @fence_seq_cst_st
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    fence syncscope("singlethread") seq_cst
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, ptr %P1, align 4
  fence syncscope("singlethread") seq_cst
  store i32 0, ptr %P1, align 4
  ret void
}

; Can't DSE across a full fence
define void @fence_asm_sideeffect(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @fence_asm_sideeffect
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    call void asm sideeffect "", ""()
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, ptr %P1, align 4
  call void asm sideeffect "", ""()
  store i32 0, ptr %P1, align 4
  ret void
}

; Can't DSE across a full fence
define void @fence_asm_memory(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @fence_asm_memory
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    call void asm "", "~{memory}"()
; CHECK-NEXT:    store i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, ptr %P1, align 4
  call void asm "", "~{memory}"()
  store i32 0, ptr %P1, align 4
  ret void
}

; Can't remove a volatile load
define i32 @volatile_load(ptr %P1, ptr %P2) {
; CHECK-LABEL: define i32 @volatile_load
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[B:%.*]] = load volatile i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[RES:%.*]] = sub i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %a = load i32, ptr %P1, align 4
  %b = load volatile i32, ptr %P1, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

; Can't remove redundant volatile loads
define i32 @redundant_volatile_load(ptr %P1, ptr %P2) {
; CHECK-LABEL: define i32 @redundant_volatile_load
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load volatile i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[B:%.*]] = load volatile i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[RES:%.*]] = sub i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %a = load volatile i32, ptr %P1, align 4
  %b = load volatile i32, ptr %P1, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

; Can't DSE a volatile store
define void @volatile_store(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @volatile_store
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store volatile i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    store i32 3, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store volatile i32 0, ptr %P1, align 4
  store i32 3, ptr %P1, align 4
  ret void
}

; Can't DSE a redundant volatile store
define void @redundant_volatile_store(ptr %P1, ptr %P2) {
; CHECK-LABEL: define void @redundant_volatile_store
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    store volatile i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    store volatile i32 0, ptr [[P1]], align 4
; CHECK-NEXT:    ret void
;
  store volatile i32 0, ptr %P1, align 4
  store volatile i32 0, ptr %P1, align 4
  ret void
}

; Can value forward from volatiles
define i32 @test20(ptr %P1, ptr %P2) {
; CHECK-LABEL: define i32 @test20
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load volatile i32, ptr [[P1]], align 4
; CHECK-NEXT:    ret i32 0
;
  %a = load volatile i32, ptr %P1, align 4
  %b = load i32, ptr %P1, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

; We're currently conservative about widening
define i64 @widen1(ptr %P1) {
; CHECK-LABEL: define i64 @widen1
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[B:%.*]] = load atomic i64, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[A64:%.*]] = sext i32 [[A]] to i64
; CHECK-NEXT:    [[RES:%.*]] = sub i64 [[A64]], [[B]]
; CHECK-NEXT:    ret i64 [[RES]]
;
  %a = load atomic i32, ptr %P1 unordered, align 4
  %b = load atomic i64, ptr %P1 unordered, align 4
  %a64 = sext i32 %a to i64
  %res = sub i64 %a64, %b
  ret i64 %res
}

; narrowing does work
define i64 @narrow(ptr %P1) {
; CHECK-LABEL: define i64 @narrow
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A64:%.*]] = load atomic i64, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 [[A64]] to i32
; CHECK-NEXT:    [[B64:%.*]] = sext i32 [[TMP1]] to i64
; CHECK-NEXT:    [[RES:%.*]] = sub i64 [[A64]], [[B64]]
; CHECK-NEXT:    ret i64 [[RES]]
;
  %a64 = load atomic i64, ptr %P1 unordered, align 4
  %b = load atomic i32, ptr %P1 unordered, align 4
  %b64 = sext i32 %b to i64
  %res = sub i64 %a64, %b64
  ret i64 %res
}

; Missed optimization, we don't yet optimize ordered loads
define i64 @narrow2(ptr %P1) {
; CHECK-LABEL: define i64 @narrow2
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A64:%.*]] = load atomic i64, ptr [[P1]] acquire, align 4
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] acquire, align 4
; CHECK-NEXT:    [[B64:%.*]] = sext i32 [[B]] to i64
; CHECK-NEXT:    [[RES:%.*]] = sub i64 [[A64]], [[B64]]
; CHECK-NEXT:    ret i64 [[RES]]
;
  %a64 = load atomic i64, ptr %P1 acquire, align 4
  %b = load atomic i32, ptr %P1 acquire, align 4
  %b64 = sext i32 %b to i64
  %res = sub i64 %a64, %b64
  ret i64 %res
}

; Note: The cross block FRE testing is deliberately light.  All of the tricky
; bits of legality are shared code with the block-local FRE above.  These
; are here only to show that we haven't obviously broken anything.

; unordered atomic to unordered atomic
define i32 @non_local_fre(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_fre
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    ret i32 0
; CHECK:       next:
; CHECK-NEXT:    ret i32 0
;
  %a = load atomic i32, ptr %P1 unordered, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  ret i32 %a
next:
  %b = load atomic i32, ptr %P1 unordered, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

; unordered atomic to non-atomic
define i32 @non_local_fre2(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_fre2
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    ret i32 0
; CHECK:       next:
; CHECK-NEXT:    ret i32 0
;
  %a = load atomic i32, ptr %P1 unordered, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  ret i32 %a
next:
  %b = load i32, ptr %P1
  %res = sub i32 %a, %b
  ret i32 %res
}

; Can't forward ordered atomics.
define i32 @non_local_fre3(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_fre3
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] acquire, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    ret i32 0
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] acquire, align 4
; CHECK-NEXT:    [[RES:%.*]] = sub i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %a = load atomic i32, ptr %P1 acquire, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  ret i32 %a
next:
  %b = load atomic i32, ptr %P1 acquire, align 4
  %res = sub i32 %a, %b
  ret i32 %res
}

declare void @clobber()

; unordered atomic to unordered atomic
define i32 @non_local_pre(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_pre
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[B_PRE:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ [[B_PRE]], [[EARLY]] ], [ [[A]], [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = load atomic i32, ptr %P1 unordered, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  call void @clobber()
  br label %next
next:
  %b = load atomic i32, ptr %P1 unordered, align 4
  ret i32 %b
}

; unordered atomic to non-atomic
define i32 @non_local_pre2(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_pre2
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[B_PRE:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ [[B_PRE]], [[EARLY]] ], [ [[A]], [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = load atomic i32, ptr %P1 unordered, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  call void @clobber()
  br label %next
next:
  %b = load i32, ptr %P1
  ret i32 %b
}

; non-atomic to unordered atomic - can't forward!
define i32 @non_local_pre3(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_pre3
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load i32, ptr [[P1]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = load i32, ptr %P1
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  call void @clobber()
  br label %next
next:
  %b = load atomic i32, ptr %P1 unordered, align 4
  ret i32 %b
}

; ordered atomic to ordered atomic - can't forward
define i32 @non_local_pre4(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_pre4
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = load atomic i32, ptr %P1 seq_cst, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  call void @clobber()
  br label %next
next:
  %b = load atomic i32, ptr %P1 seq_cst, align 4
  ret i32 %b
}

; can't remove volatile on any path
define i32 @non_local_pre5(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_pre5
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = load volatile i32, ptr [[P1]], align 4
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = load atomic i32, ptr %P1 seq_cst, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  call void @clobber()
  br label %next
next:
  %b = load volatile i32, ptr %P1
  ret i32 %b
}


; ordered atomic to unordered atomic
define i32 @non_local_pre6(ptr %P1) {
; CHECK-LABEL: define i32 @non_local_pre6
; CHECK-SAME: (ptr [[P1:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load atomic i32, ptr [[P1]] seq_cst, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[A]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[EARLY:%.*]], label [[NEXT:%.*]]
; CHECK:       early:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[B_PRE:%.*]] = load atomic i32, ptr [[P1]] unordered, align 4
; CHECK-NEXT:    br label [[NEXT]]
; CHECK:       next:
; CHECK-NEXT:    [[B:%.*]] = phi i32 [ [[B_PRE]], [[EARLY]] ], [ [[A]], [[TMP0:%.*]] ]
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = load atomic i32, ptr %P1 seq_cst, align 4
  %cmp = icmp eq i32 %a, 0
  br i1 %cmp, label %early, label %next
early:
  call void @clobber()
  br label %next
next:
  %b = load atomic i32, ptr %P1 unordered, align 4
  ret i32 %b
}

