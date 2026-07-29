# rvmodel_macros.h
# Ctrl-CV RV32IM current baseline
# SPDX-License-Identifier: Apache-2.0

#ifndef _RVMODEL_MACROS_H
#define _RVMODEL_MACROS_H

/*
 * Allocate the HTIF termination variables in DRAM.
 * link.ld places the .tohost section in DRAM.
 */
#define RVMODEL_DATA_SECTION                                \
  .pushsection .tohost, "aw", @progbits;                   \
  .balign 8;                                                \
  .global tohost;                                           \
tohost:                                                     \
  .dword 0;                                                 \
  .balign 8;                                                \
  .global fromhost;                                         \
fromhost:                                                   \
  .dword 0;                                                 \
  .popsection

/*
 * The core starts directly in M-mode.
 * Skip ACT4's generic privilege-mode boot sequence because the current
 * machine-mode CSR and exception implementation is not yet complete.
 */
#define RVMODEL_BOOT
#define RVMODEL_BOOT_TO_MMODE

/*
 * Write 1 to tohost for pass and then remain in a stable loop.
 */
#define RVMODEL_HALT_PASS                                   \
  li x1, 1;                                                 \
  la t0, tohost;                                            \
1:                                                          \
  sw x1, 0(t0);                                             \
  sw x0, 4(t0);                                             \
  j 1b

/*
 * Write 3 to tohost for fail and then remain in a stable loop.
 */
#define RVMODEL_HALT_FAIL                                   \
  li x1, 3;                                                 \
  la t0, tohost;                                            \
1:                                                          \
  sw x1, 0(t0);                                             \
  sw x0, 4(t0);                                             \
  j 1b

/*
 * The current baseline has no ACT4 console device.
 */
#define RVMODEL_IO_INIT(_R1, _R2, _R3)

#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR)

/*
 * No access-fault address, timer or interrupt-generator macros are
 * declared in current-v1. They will be added with the interrupt work.
 */

#endif
