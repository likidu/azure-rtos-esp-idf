/**************************************************************************/
/*   Copyright (c) Cadence Design Systems, Inc.                           */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

/**************************************************************************/
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    Xtensa interrupt handling data and assembly routines.               */
/*    Also see xtensa_intr.c.                                             */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  12-31-2020     Cadence Design Systems   Initial Version 6.1.3         */
/*                                                                        */
/**************************************************************************/


#include <xtensa/hal.h>
#include <xtensa/config/core.h>

#include "tx_port.h"
#include "xtensa_context.h"

#if XCHAL_HAVE_INTERRUPTS

/*
-------------------------------------------------------------------------------
  INTENABLE virtualization information.
-------------------------------------------------------------------------------
*/

#if XCHAL_HAVE_XEA2

    .data
    .global _xt_intdata
    .align  8
_xt_intdata:
    .global _xt_intenable
    .type   _xt_intenable,@object
    .size   _xt_intenable,4
    .global _xt_vpri_mask
    .type   _xt_vpri_mask,@object
    .size   _xt_vpri_mask,4

_xt_intenable:     .word   0             /* Virtual INTENABLE     */
_xt_vpri_mask:     .word   0xFFFFFFFF    /* Virtual priority mask */

#endif

/*
-------------------------------------------------------------------------------
  System interrupt stack.
-------------------------------------------------------------------------------
*/

#if (XCHAL_HAVE_XEA2 || XCHAL_HAVE_ISB)
    .data
#else
    .section    .intr.top, "aw"
#endif

    .global _xt_interrupt_stack
    .global _xt_interrupt_stack_top
    .align  16

_xt_interrupt_stack:
    .space  TX_SYSTEM_STACK_SIZE
_xt_interrupt_stack_top:


/*
-------------------------------------------------------------------------------
  Table of C-callable interrupt handlers for each interrupt. For XEA2 configs,
  not all slots can be filled, because interrupts at level > EXCM_LEVEL will
  not be dispatched to a C handler by default.
-------------------------------------------------------------------------------
*/

#if (XCHAL_HAVE_XEA2 || XCHAL_HAVE_ISB)
    .data
#else
    .section    .intr.data, "aw"
#endif

    .global _xt_interrupt_table
    .align  16

_xt_interrupt_table:

/*
-------------------------------------------------------------------------------
  If using the interrupt wrapper, make the first entry in the interrupt table
  point to the wrapper (XEA3) or leave it empty (XEA2).
-------------------------------------------------------------------------------
*/
#if XCHAL_HAVE_XEA3
    .word   xt_interrupt_wrapper
    .word   0
#elif XT_USE_INT_WRAPPER
    .word   0
    .word   0
#endif

    .set    i, 0
    .rept   XCHAL_NUM_INTERRUPTS
    .word   xt_unhandled_interrupt      /* handler address               */
    .word   i                           /* handler arg (default: intnum) */
    .set    i, i+1
    .endr

#endif /* XCHAL_HAVE_INTERRUPTS */


#if XCHAL_HAVE_EXCEPTIONS

/*
-------------------------------------------------------------------------------
  Table of C-callable exception handlers for each exception. Note that not all
  slots will be active, because some exceptions (e.g. coprocessor exceptions)
  are always handled by the OS and cannot be hooked by user handlers.
-------------------------------------------------------------------------------
*/

    .data
    .global _xt_exception_table
    .align  4

_xt_exception_table:
    .rept   XCHAL_EXCCAUSE_NUM
    .word   xt_unhandled_exception    /* handler address */
    .endr

#endif

/*
Liki: copied from ESP-IDF xtensa component definitions
 */

/*
-------------------------------------------------------------------------------
  unsigned int xt_ints_on ( unsigned int mask )

  Enables a set of interrupts. Does not simply set INTENABLE directly, but
  computes it as a function of the current virtual priority if XT_USE_SWPRI is
  enabled.
  Can be called from interrupt handlers.
-------------------------------------------------------------------------------
*/

    .text
    .align  4
    .global xt_ints_on
    .type   xt_ints_on,@function

xt_ints_on:

    ENTRY0

#if XCHAL_HAVE_INTERRUPTS
#if XT_USE_SWPRI
    movi    a3, 0
    movi    a4, _xt_intdata
    xsr     a3, INTENABLE        /* Disables all interrupts   */
    rsync
    l32i    a3, a4, 0            /* a3 = _xt_intenable        */
    l32i    a6, a4, 4            /* a6 = _xt_vpri_mask        */
    or      a5, a3, a2           /* a5 = _xt_intenable | mask */
    s32i    a5, a4, 0            /* _xt_intenable |= mask     */
    and     a5, a5, a6           /* a5 = _xt_intenable & _xt_vpri_mask */
    wsr     a5, INTENABLE        /* Reenable interrupts       */
    mov     a2, a3               /* Previous mask             */
#else
    movi    a3, 0
    xsr     a3, INTENABLE        /* Disables all interrupts   */
    rsync
    or      a2, a3, a2           /* set bits in mask */
    wsr     a2, INTENABLE        /* Re-enable ints */
    rsync
    mov     a2, a3               /* return prev mask */
#endif
#else
    movi    a2, 0                /* Return zero */
#endif
    RET0

    .size   xt_ints_on, . - xt_ints_on


/*
-------------------------------------------------------------------------------
  unsigned int xt_ints_off ( unsigned int mask )

  Disables a set of interrupts. Does not simply set INTENABLE directly,
  but computes it as a function of the current virtual priority if XT_USE_SWPRI is
  enabled.
  Can be called from interrupt handlers.
-------------------------------------------------------------------------------
*/

    .text
    .align  4
    .global xt_ints_off
    .type   xt_ints_off,@function

xt_ints_off:

    ENTRY0
#if XCHAL_HAVE_INTERRUPTS
#if XT_USE_SWPRI
    movi    a3, 0
    movi    a4, _xt_intdata
    xsr     a3, INTENABLE        /* Disables all interrupts    */
    rsync
    l32i    a3, a4, 0            /* a3 = _xt_intenable         */
    l32i    a6, a4, 4            /* a6 = _xt_vpri_mask         */
    or      a5, a3, a2           /* a5 = _xt_intenable | mask  */
    xor     a5, a5, a2           /* a5 = _xt_intenable & ~mask */
    s32i    a5, a4, 0            /* _xt_intenable &= ~mask     */
    and     a5, a5, a6           /* a5 = _xt_intenable & _xt_vpri_mask */
    wsr     a5, INTENABLE        /* Reenable interrupts        */
    mov     a2, a3               /* Previous mask              */
#else
    movi    a4, 0
    xsr     a4, INTENABLE        /* Disables all interrupts   */
    rsync
    or      a3, a4, a2           /* set bits in mask */
    xor     a3, a3, a2           /* invert bits in mask set in mask, essentially clearing them */
    wsr     a3, INTENABLE        /* Re-enable ints */
    rsync
    mov     a2, a4               /* return prev mask */
#endif
#else
    movi    a2, 0                /* return zero */
#endif
    RET0

    .size   xt_ints_off, . - xt_ints_off


