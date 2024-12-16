#include "platform.h"

	# size of each hart's stack is 1024 bytes
	.equ	STACK_SIZE, 1024

	.global	_start

# 下面的代码放在.text段中,因为.text段是默认段,所以不用加.section指令
	.text
# 芯片启动运行的第一段代码 
_start:
	# park harts with id != 0
	csrr	t0, mhartid		# 读取当前 hart id
	mv		tp, t0			# 将hart id放到tp寄存器中
	bnez	t0, park		# 如果hart id不为0,则跳转到park函数

	# Set all bytes in the BSS section to zero.
	la	a0, _bss_start
	la	a1, _bss_end
	bgeu	a0, a1, 2f      # 跳转到2

1:
	sw	zero, (a0)
	addi	a0, a0, 4
	bltu	a0, a1, 1b

2:
	# 初始化stack,因为stack从底向上生长,所以将stack指针指向stack空间的最高地址
	slli	t0, t0, 10				# shift left the hart id by 1024
	la	sp, stacks + STACK_SIZE		# 初始化栈指针sp,指向第一个hart的栈空间的最高地址
	
	add	sp, sp, t0					# move the current hart stack pointer
									# to its place in the stack space

	# At the end of start_kernel, schedule() will call MRET to switch
	# to the first task, so we parepare the mstatus here.
	# 在mret中,会将特权等级设为mstatus.MPP, 会将mstatus.MIE设置为mstatus.MPIE
	# 设置 mstatus.MPP为3, 使得我们在MRET后仍处于Machine mode, 之前之所以崩溃就是没设MPP,导致mret后特权等级发生改变
	# 设置 mstatus.MPIE为1, 使得在MRET后维持之前的中断使能状态.
	li	t0, 3 << 11 | 1 << 7
	csrs	mstatus, t0

	j	start_kernel		# 跳转到C语言的函数中

# 相当于挂起此hart
park:
	wfi
	j	park

	# In the standard RISC-V calling convention, the stack pointer sp
	# is always 16-byte aligned.
.balign 16
stacks:
	.skip	STACK_SIZE * MAXNUM_CPU # allocate space for all the harts stacks

	.end				# End of file
