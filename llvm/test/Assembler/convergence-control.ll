; RUN: llvm-as < %s -disable-output 2>&1 | FileCheck %s -allow-empty

; RUN: llvm-as < %s | llvm-dis > %t1.ll
; RUN: llvm-as %t1.ll -o - | llvm-dis > %t2.ll
; RUN: diff %t1.ll %t2.ll

; RUN: llvm-as < %t1.ll -disable-output 2>&1 | FileCheck %s -allow-empty

; CHECK-NOT: error
; CHECK-NOT: warning

define void @mixed1() {
  call void @g() ; not convergent
  call void @f() ; uncontrolled convergent
  call void @g() ; not convergent
  ret void
}

define void @mixed2() {
  call void @g() ; not convergent
  %t1_tok1 = call token @llvm.experimental.convergence.anchor()
  call void @f() [ "convergencectrl"(token %t1_tok1) ]
  call void @g() ; not convergent
  ret void
}

; convergence control token can be used on non-convergent calls,
; but it has no effect.
define void @mixed3() {
  %t05_tok1 = call token @llvm.experimental.convergence.anchor()
  call void @g() [ "convergencectrl"(token %t05_tok1) ]
  ret void
}

define void @region_nesting1(i1 %arg) convergent {
A:
  %tok1 = call token @llvm.experimental.convergence.entry()
  %tok2 = call token @llvm.experimental.convergence.anchor()
  br label %B

B:
  br i1 %arg, label %C, label %D

C:
  call void @f() [ "convergencectrl"(token %tok1) ]
  ret void

D:
  call void @f() [ "convergencectrl"(token %tok2) ]
  ret void
}

; Mirror image of @region_nesting1
define void @region_nesting2(i1 %arg) {
A:
  %tok1 = call token @llvm.experimental.convergence.anchor()
  %tok2 = call token @llvm.experimental.convergence.anchor()
  br label %B

B:
  br i1 %arg, label %C, label %D

C:
  call void @f() [ "convergencectrl"(token %tok2) ]
  ret void

D:
  call void @f() [ "convergencectrl"(token %tok1) ]
  ret void
}

define void @loop_nesting(i1 %arg) convergent {
A:
  %a = call token @llvm.experimental.convergence.entry()
  br label %B

B:
  %b = call token @llvm.experimental.convergence.anchor()
  br i1 %arg, label %C, label %D

C:
  %c = call token @llvm.experimental.convergence.loop() [ "convergencectrl"(token %b) ]
  call void @f() [ "convergencectrl"(token %c) ]
  br label %B

D:
  call void @f() [ "convergencectrl"(token %b) ]
  br i1 %arg, label %B, label %E

E:
  ret void
}
declare void @f() convergent
declare void @g()

declare token @llvm.experimental.convergence.entry()
declare token @llvm.experimental.convergence.anchor()
declare token @llvm.experimental.convergence.loop()
