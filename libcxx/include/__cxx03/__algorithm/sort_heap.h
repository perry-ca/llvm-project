//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___CXX03___ALGORITHM_SORT_HEAP_H
#define _LIBCPP___CXX03___ALGORITHM_SORT_HEAP_H

#include <__cxx03/__algorithm/comp.h>
#include <__cxx03/__algorithm/comp_ref_type.h>
#include <__cxx03/__algorithm/iterator_operations.h>
#include <__cxx03/__algorithm/pop_heap.h>
#include <__cxx03/__config>
#include <__cxx03/__debug_utils/strict_weak_ordering_check.h>
#include <__cxx03/__iterator/iterator_traits.h>
#include <__cxx03/__type_traits/is_assignable.h>
#include <__cxx03/__type_traits/is_constructible.h>
#include <__cxx03/__utility/move.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_PUSH_MACROS
#include <__cxx03/__undef_macros>

_LIBCPP_BEGIN_NAMESPACE_STD

template <class _AlgPolicy, class _Compare, class _RandomAccessIterator>
inline _LIBCPP_HIDE_FROM_ABI void
__sort_heap(_RandomAccessIterator __first, _RandomAccessIterator __last, _Compare&& __comp) {
  _RandomAccessIterator __saved_last   = __last;
  __comp_ref_type<_Compare> __comp_ref = __comp;

  using difference_type = typename iterator_traits<_RandomAccessIterator>::difference_type;
  for (difference_type __n = __last - __first; __n > 1; --__last, (void)--__n)
    std::__pop_heap<_AlgPolicy>(__first, __last, __comp_ref, __n);
  std::__check_strict_weak_ordering_sorted(__first, __saved_last, __comp_ref);
}

template <class _RandomAccessIterator, class _Compare>
inline _LIBCPP_HIDE_FROM_ABI void
sort_heap(_RandomAccessIterator __first, _RandomAccessIterator __last, _Compare __comp) {
  static_assert(std::is_copy_constructible<_RandomAccessIterator>::value, "Iterators must be copy constructible.");
  static_assert(std::is_copy_assignable<_RandomAccessIterator>::value, "Iterators must be copy assignable.");

  std::__sort_heap<_ClassicAlgPolicy>(std::move(__first), std::move(__last), __comp);
}

template <class _RandomAccessIterator>
inline _LIBCPP_HIDE_FROM_ABI void sort_heap(_RandomAccessIterator __first, _RandomAccessIterator __last) {
  std::sort_heap(std::move(__first), std::move(__last), __less<>());
}

_LIBCPP_END_NAMESPACE_STD

_LIBCPP_POP_MACROS

#endif // _LIBCPP___CXX03___ALGORITHM_SORT_HEAP_H
