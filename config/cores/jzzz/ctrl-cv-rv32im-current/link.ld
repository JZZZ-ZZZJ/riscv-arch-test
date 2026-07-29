OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
  /*
   * ACT4仿真使用SoC地址图中预留的完整窗口。
   * 板级Vivado IP仍然是16 KiB IROM和256 KiB DRAM。
   */
  IROM (rx) : ORIGIN = 0x80000000, LENGTH = 1M
  DRAM (rw) : ORIGIN = 0x80100000, LENGTH = 1M
}

TEST_BASE = ORIGIN(IROM);
NUM_HARTS = 1;
STACK_SIZE = 0x4000; /* 16 KiB */

PROVIDE(__num_harts = NUM_HARTS);
PROVIDE(__stack_size = STACK_SIZE);

SECTIONS
{
  /*
   * CPU复位地址为0x80000000。
   * 所有可执行内容都必须位于IROM。
   */
  .text.init :
  {
    . = ALIGN(4);
    *(.text.init)
  } > IROM

  .text.rvtest :
  {
    . = ALIGN(4);
    *(.text.rvtest)
    *(.text.rvtest.*)
  } > IROM

  /*
   * CtrlCV的数据总线不能读取IROM，
   * 因此只读常量也必须放入DRAM。
   */
  .rodata :
  {
    . = ALIGN(16);
    *(.rodata)
    *(.rodata.*)
    *(.srodata)
    *(.srodata.*)
  } > DRAM

  .data :
  {
    . = ALIGN(16);
    *(.data)
    *(.data.*)
    *(.sdata)
    *(.sdata.*)
    *(.tohost)
  } > DRAM

  .bss (NOLOAD) :
  {
    . = ALIGN(16);
    __bss_start = .;

    *(.sbss)
    *(.sbss.*)
    *(.bss)
    *(.bss.*)
    *(COMMON)

    . = ALIGN(16);
    __bss_end = .;
  } > DRAM

  __dram_used_end = .;

  /*
   * ACT4要求该节在链接描述中位于.data之后；
   * 但它包含可执行代码，所以物理地址仍分配在IROM。
   */
  .text.rvmodel :
  {
    . = ALIGN(16);
    *(.text.rvmodel)
    *(.text.rvmodel.*)
    *(.text)
    *(.text.*)
  } > IROM

  /*
   * 栈从DRAM最高地址向下使用。
   */
  __stack_top = ORIGIN(DRAM) + LENGTH(DRAM);
  __stack_bottom =
      __stack_top - (__stack_size * __num_harts);

  PROVIDE(_end = __dram_used_end);

  ASSERT(
    __dram_used_end <= __stack_bottom,
    "ACT4 test data overlaps the DRAM stack"
  )
}
