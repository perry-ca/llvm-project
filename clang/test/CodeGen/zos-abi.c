// RUN: %clang_cc1 -triple s390x-ibm-zos \
// RUN:   -emit-llvm -no-enable-noundef-analysis -o - %s | FileCheck %s


// z/OS has two different implementations for variable argument handling.
// Functions ending with _e test the extended variant of vararg functions

// (__builtin_va_start, __builtin_va_arg, __builtin_va_end). The type of
// va_list is __builtin_va_list.
// Functions ending with _s test the standard variant of vararg functions
// (__builtin_zos_va_start, __builtin_va_arg, __builtin_zos_va_end). The type of
// va_list is __builtin_va_list.

int dofmt_e(const char *fmt, ...) {
  __builtin_va_list va;

  __builtin_va_start(va, fmt);
  int v = __builtin_va_arg(va, int);
  __builtin_va_end(va);

  return v;
}
// CHECK-LABEL: define signext i32 @dofmt_e(ptr %{{.*}}, ...)
// CHECK: [[FMT_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: [[VA:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: [[V:%[._a-z0-9]+]] = alloca i32, align 4
// CHECK: store ptr %{{.*}}, ptr [[FMT_ADDR]], align 8
// CHECK: call void @llvm.va_start.p0(ptr [[VA]])
// CHECK: [[ARGP_CURR:%[._a-z0-9]+]] = load ptr, ptr [[VA]], align 8
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_CURR]], i64 8
// CHECK: store ptr [[ARGP_NEXT]], ptr [[VA]], align 8
// CHECK: [[V_ADDR:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_CURR]], i64 4
// CHECK: [[VAL:%[._a-z0-9]+]] = load i32, ptr [[V_ADDR]], align 4
// CHECK: store i32 [[VAL]], ptr [[V]], align 4
// CHECK: call void @llvm.va_end.p0(ptr [[VA]])
// CHECK: [[VAL2:%[._a-z0-9]+]] = load i32, ptr [[V]], align 4
// CHECK: ret i32 [[VAL2]]

int dofmt_s(const char *fmt, ...) {
  __builtin_zos_va_list va;

  __builtin_zos_va_start(va, fmt);
  int v = __builtin_va_arg(va, int);
  __builtin_zos_va_end(va);

  return v;
}
// CHECK-LABEL: define signext i32 @dofmt_s(ptr %{{.*}}, ...)
// CHECK: [[FMT_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: [[VA:%[._a-z0-9]+]] = alloca [2 x ptr], align 8
// CHECK: [[V:%[._a-z0-9]+]] = alloca i32, align 4
// CHECK: store ptr %{{.*}}, ptr [[FMT_ADDR]], align 8
// CHECK: [[DECAY1:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VA]], i64 0, i64 0
// CHECK: [[VALIST_CURR1:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[DECAY1]], i64 0, i64 0
// CHECK: store ptr null, ptr [[VALIST_CURR1]], align 8
// CHECK: [[VALIST_NEXT1:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[DECAY1]], i64 0, i64 1
// CHECK: call void @llvm.va_start.p0(ptr [[VALIST_NEXT1]])
// CHECK: [[DECAY2:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VA]], i64 0, i64 0
// CHECK: [[VALIST_CURR2:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[DECAY2]], i64 0, i64 0
// CHECK: [[VALIST_NEXT2:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[DECAY2]], i64 0, i64 1
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = load ptr, ptr [[VALIST_NEXT2]], align 8
// CHECK: %0 = getelementptr inbounds i8, ptr [[ARGP_NEXT]], i32 7
// CHECK: [[ARGP_NEXT_ALIGNED:%[._a-z0-9]+]] = call ptr @llvm.ptrmask.p0.i64(ptr %0, i64 -8)
// CHECK: store ptr [[ARGP_NEXT_ALIGNED]], ptr [[VALIST_CURR2]], align 8
// CHECK: [[ARGP_NEXT_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_NEXT_ALIGNED]], i64 4
// CHECK: store ptr [[ARGP_NEXT_NEXT]], ptr [[VALIST_NEXT2]], align 8
// CHECK: [[V_ADDR:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_NEXT_ALIGNED]], i64 4
// CHECK: [[VAL:%[._a-z0-9]+]] = load i32, ptr [[V_ADDR]], align 4
// CHECK: store i32 [[VAL]], ptr [[V]], align 4
// CHECK: [[DECAY3:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VA]], i64 0, i64 0
// CHECK: [[VALIST_CURR3:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[DECAY3]], i64 0, i64 0
// CHECK: store ptr null, ptr [[VALIST_CURR3]], align 8
// CHECK: [[VALIST_NEXT3:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[DECAY3]], i64 0, i64 1
// CHECK: call void @llvm.va_end.p0(ptr [[VALIST_NEXT3]])
// CHECK: [[VAL2:%[._a-z0-9]+]] = load i32, ptr [[V]], align 4
// CHECK: ret i32 [[VAL2]]

int va_int_e(__builtin_va_list l) { return __builtin_va_arg(l, int); }
// CHECK-LABEL: define signext i32 @va_int_e(ptr %{{.*}})
// CHECK: [[L_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: store ptr %{{.*}}, ptr [[L_ADDR]], align 8
// CHECK: [[ARGP_CURR:%[._a-z0-9]+]] = load ptr, ptr [[L_ADDR]], align 8
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_CURR]], i64 8
// CHECK: store ptr [[ARGP_NEXT]], ptr [[L_ADDR]], align 8
// CHECK: [[V_ADDR:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_CURR]], i64 4
// CHECK: [[VAL:%[._a-z0-9]+]] = load i32, ptr [[V_ADDR]], align 4
// CHECK: ret i32 [[VAL]]

int va_int_s(__builtin_zos_va_list l) { return __builtin_va_arg(l, int); }
// CHECK-LABEL: define signext i32 @va_int_s(ptr %{{.*}})
// CHECK: [[L_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: store ptr %{{.*}}, ptr [[L_ADDR]], align 8
// CHECK: [[VALIST:%[._a-z0-9]+]] = load ptr, ptr [[L_ADDR]], align 8
// CHECK: [[VALIST_CURR:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VALIST]], i64 0, i64 0
// CHECK: [[VALIST_NEXT:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VALIST]], i64 0, i64 1
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = load ptr, ptr [[VALIST_NEXT]], align 8
// CHECK: %1 = getelementptr inbounds i8, ptr %arg.next, i32 7
// CHECK: [[ARGP_NEXT_ALIGNED]] = call ptr @llvm.ptrmask.p0.i64(ptr %1, i64 -8)
// CHECK: store ptr [[ARGP_NEXT_ALIGNED]], ptr [[VALIST_CURR]], align 8
// CHECK: [[ARGP_NEXT_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_NEXT_ALIGNED]], i64 4
// CHECK: store ptr [[ARGP_NEXT_NEXT]], ptr [[VALIST_NEXT]], align 8
// CHECK: [[V_ADDR:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_NEXT_ALIGNED]], i64 4
// CHECK: [[VAL:%[._a-z0-9]+]] = load i32, ptr [[V_ADDR]], align 4
// CHECK: ret i32 [[VAL]]

long va_long_e(__builtin_va_list l) { return __builtin_va_arg(l, long); }
// CHECK-LABEL: define i64 @va_long_e(ptr %{{.*}})
// CHECK: [[L_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: store ptr %{{.*}}, ptr [[L_ADDR]], align 8
// CHECK: [[ARGP_CURR:%[._a-z0-9]+]] = load ptr, ptr [[L_ADDR]], align 8
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_CURR]], i64 8
// CHECK: store ptr [[ARGP_NEXT]], ptr [[L_ADDR]], align 8
// CHECK: [[VAL:%[._a-z0-9]+]] = load i64, ptr [[ARGP_CURR]], align 8
// CHECK: ret i64 [[VAL]]

long va_long_s(__builtin_zos_va_list l) { return __builtin_va_arg(l, long); }
// CHECK-LABEL: define i64 @va_long_s(ptr %{{.*}})
// CHECK: [[L_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: store ptr %{{.*}}, ptr [[L_ADDR]], align 8
// CHECK: [[VALIST:%[._a-z0-9]+]] = load ptr, ptr [[L_ADDR]], align 8
// CHECK: [[VALIST_CURR:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VALIST]], i64 0, i64 0
// CHECK: [[VALIST_NEXT:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VALIST]], i64 0, i64 1
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = load ptr, ptr [[VALIST_NEXT]], align 8
// CHECK: %1 = getelementptr inbounds i8, ptr %arg.next, i32 7
// CHECK: %arg.next.aligned = call ptr @llvm.ptrmask.p0.i64(ptr %1, i64 -8)
// CHECK: store ptr [[ARGP_NEXT_ALIGNED]], ptr [[VALIST_CURR]], align 8
// CHECK: [[ARGP_NEXT_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_NEXT_ALIGNED]], i64 8
// CHECK: store ptr [[ARGP_NEXT_NEXT]], ptr [[VALIST_NEXT]], align 8
// CHECK: [[VAL:%[._a-z0-9]+]] = load i64, ptr [[ARGP_NEXT_ALIGNED]], align 8
// CHECK: ret i64 [[VAL]]

struct agg_threedouble {
  double a, b, c;
};
struct agg_threedouble va_3double_s(__builtin_zos_va_list l) {
  return __builtin_va_arg(l, struct agg_threedouble);
}
// CHECK-LABEL: define inreg [3 x i64] @va_3double_s(ptr %{{.*}})
// CHECK: [[RETVAL:%[._a-z0-9]+]] = alloca %struct.agg_threedouble, align 8
// CHECK: [[L_ADDR:%[._a-z0-9]+]] = alloca ptr, align 8
// CHECK: store ptr %{{.*}}, ptr [[L_ADDR]], align 8
// CHECK: [[VALIST:%[._a-z0-9]+]] = load ptr, ptr [[L_ADDR]], align 8
// CHECK: [[VALIST_CURR:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VALIST]], i64 0, i64 0
// CHECK: [[VALIST_NEXT:%[._a-z0-9]+]] = getelementptr inbounds [2 x ptr], ptr [[VALIST]], i64 0, i64 1
// CHECK: [[ARGP_NEXT:%[._a-z0-9]+]] = load ptr, ptr [[VALIST_NEXT]], align 8
// CHECK: %1 = getelementptr inbounds i8, ptr %arg.next, i32 7
// CHECK: [[ARGP_NEXT_ALIGNED]] = call ptr @llvm.ptrmask.p0.i64(ptr %1, i64 -8)
// CHECK: store ptr [[ARGP_NEXT_ALIGNED]], ptr [[VALIST_CURR]], align 8
// CHECK: [[ARGP_NEXT_NEXT:%[._a-z0-9]+]] = getelementptr inbounds i8, ptr [[ARGP_NEXT_ALIGNED]], i64 24
// CHECK: store ptr [[ARGP_NEXT_NEXT]], ptr [[VALIST_NEXT]], align 8
// CHECK: call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[RETVAL]], ptr align 8 [[ARGP_NEXT_ALIGNED]], i64 24, i1 false)
// CHECK: [[RETVAL2:%[._a-z0-9]+]] = load [3 x i64], ptr [[RETVAL]], align 8
// CHECK: ret [3 x i64] [[RETVAL2]]
