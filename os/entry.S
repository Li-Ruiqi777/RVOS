#define LOAD		lw
#define STORE		sw
#define SIZE_REG	4

# Save all General-Purpose(GP) registers to context.
# struct context *base = &ctx_task;
# base->ra = ra;
# ......
# These GP registers to be saved don't include gp
# and tp, because they are not caller-saved or
# callee-saved. These two registers are often used
# for special purpose. For example, in RVOS, 'tp'
# (aka "thread pointer") is used to store hartid,
# which is a global value and would not be changed
# during context-switch.

# 将寄存器保存到上下文内存中
# base: 上下文内存的基地址
.macro reg_save base
	STORE ra,   0*SIZE_REG(\base)
	STORE sp,   1*SIZE_REG(\base)
	STORE t0,   4*SIZE_REG(\base)
	STORE t1,   5*SIZE_REG(\base)
	STORE t2,   6*SIZE_REG(\base)
	STORE s0,   7*SIZE_REG(\base)
	STORE s1,   8*SIZE_REG(\base)
	STORE a0,   9*SIZE_REG(\base)
	STORE a1,  10*SIZE_REG(\base)
	STORE a2,  11*SIZE_REG(\base)
	STORE a3,  12*SIZE_REG(\base)
	STORE a4,  13*SIZE_REG(\base)
	STORE a5,  14*SIZE_REG(\base)
	STORE a6,  15*SIZE_REG(\base)
	STORE a7,  16*SIZE_REG(\base)
	STORE s2,  17*SIZE_REG(\base)
	STORE s3,  18*SIZE_REG(\base)
	STORE s4,  19*SIZE_REG(\base)
	STORE s5,  20*SIZE_REG(\base)
	STORE s6,  21*SIZE_REG(\base)
	STORE s7,  22*SIZE_REG(\base)
	STORE s8,  23*SIZE_REG(\base)
	STORE s9,  24*SIZE_REG(\base)
	STORE s10, 25*SIZE_REG(\base)
	STORE s11, 26*SIZE_REG(\base)
	STORE t3,  27*SIZE_REG(\base)
	STORE t4,  28*SIZE_REG(\base)
	STORE t5,  29*SIZE_REG(\base)
	# we don't save t6 here, due to we have used
	# it as base, we have to save t6 in an extra step
	# outside of reg_save
.endm

# restore all General-Purpose(GP) registers from the context
# except gp & tp.
# struct context *base = &ctx_task;
# ra = base->ra;
# ......

# 从上下文内存中恢复寄存器
# base: 上下文内存的基地址
.macro reg_restore base
	LOAD ra,   0*SIZE_REG(\base)
	LOAD sp,   1*SIZE_REG(\base)
	LOAD t0,   4*SIZE_REG(\base)
	LOAD t1,   5*SIZE_REG(\base)
	LOAD t2,   6*SIZE_REG(\base)
	LOAD s0,   7*SIZE_REG(\base)
	LOAD s1,   8*SIZE_REG(\base)
	LOAD a0,   9*SIZE_REG(\base)
	LOAD a1,  10*SIZE_REG(\base)
	LOAD a2,  11*SIZE_REG(\base)
	LOAD a3,  12*SIZE_REG(\base)
	LOAD a4,  13*SIZE_REG(\base)
	LOAD a5,  14*SIZE_REG(\base)
	LOAD a6,  15*SIZE_REG(\base)
	LOAD a7,  16*SIZE_REG(\base)
	LOAD s2,  17*SIZE_REG(\base)
	LOAD s3,  18*SIZE_REG(\base)
	LOAD s4,  19*SIZE_REG(\base)
	LOAD s5,  20*SIZE_REG(\base)
	LOAD s6,  21*SIZE_REG(\base)
	LOAD s7,  22*SIZE_REG(\base)
	LOAD s8,  23*SIZE_REG(\base)
	LOAD s9,  24*SIZE_REG(\base)
	LOAD s10, 25*SIZE_REG(\base)
	LOAD s11, 26*SIZE_REG(\base)
	LOAD t3,  27*SIZE_REG(\base)
	LOAD t4,  28*SIZE_REG(\base)
	LOAD t5,  29*SIZE_REG(\base)
	LOAD t6,  30*SIZE_REG(\base)
.endm

# Something to note about save/restore:
# - We use mscratch to hold a pointer to context of current task
# - We use t6 as the 'base' for reg_save/reg_restore, because it is the
#   very bottom register (x31) and would not be overwritten during loading.
#   Note: CSRs(mscratch) can not be used as 'base' due to load/restore
#   instruction only accept general purpose registers.

.text

# 常用指令
# csrr rd, csr : 从csr寄存器中读取值并写入rd寄存器
# csrw csr, rs1 : 将rs1的值写入csr寄存器
# mv rd, rs1: move rs1 to rd
# STORE rd, offset(base): 将rd寄存器的值存入base+offset处的内存

.globl switch_to
.balign 4

# 首先保存当前任务的寄存器到上下文内存中,接着从下一个任务的上下文内存恢复寄存器,从而切换到下一个任务
# void switch_to(struct context *next);
# a0: 指向下个任务的上下文内存
switch_to:
	csrw	mscratch, a0	# 让 mscratch 指向新任务的上下文内存
	
	LOAD	a1, 31*SIZE_REG(a0)
	csrw	mepc, a1		# 从上下文内存恢复新任务的mepc
	
	mv	t6, a0				# 让t6作为上下文内存的基地址
	reg_restore t6			# 从上下文内存恢复新任务的通用寄存器

	# Notice this will enable global interrupt
	mret					# 进行实际的任务调度,将PC设为mepc的值

; switch_to_old:
; # mscratch: 保存当前任务的上下文内存指针
; # t6: 临时寄存器, 作为上下文内存的基地址

; 	# 1.保存当前任务上下文
; 	csrrw	t6, mscratch, t6	# 读取当前任务上下文内存地址到t6
; 	beqz	t6, 1f				# 如果第一次调度，t6为0，则跳过当前任务寄存器的保存
; 	# Note: the first time switch_to() is called, mscratch is initialized as zero
; 	# (in sched_init()), which makes t6 zero,
; 	# and that's the special case we have to
; 	# handle with t6

; 	reg_save t6			# 保存当前任务的寄存器(t6以外)到上下文内存中

; 	# 保存t6寄存器的原始内容(被swap到mscratch中了)到上下文内存中
; 	mv	t5, t6					# 以t5作为临时寄存器
; 	csrr	t6, mscratch		# 从mscratch读回t6
; 	STORE	t6, 30*SIZE_REG(t5)	# 保存t6寄存器的原始内容到上下文内存中

; 	# 2.恢复下个任务上下文
; 1:
; 	# 将下个任务的上下文内存地址读到mscratch
; 	csrw	mscratch, a0

; 	# 将下个任务的上下文内存地址读到mscratch
; 	mv	t6, a0
; 	# 从下个任务的上下文内存恢复寄存器内容
; 	reg_restore t6

; 	# 返回,此时ra被改变了,所以会返回到下个任务
; 	ret

.global trap_vector
.balign 4
# 异常处理,此时hart自动被切换到了Machine模式
trap_vector:
	# 1.保存当前任务的上下文
	csrrw	t6, mscratch, t6	# 读取当前任务上下文内存地址到t6
	reg_save t6					# 保存当前任务的寄存器(t6以外)到上下文内存中

	# 保存t6寄存器的原始内容(被swap到mscratch中了)到上下文内存中
	mv	t5, t6					# 以t5作为临时寄存器
	csrr	t6, mscratch		# 从mscratch读回t6
	STORE	t6, 30*SIZE_REG(t5)	# 保存t6寄存器的原始内容到上下文内存中

	# 保存mepc寄存器到上下文内存中
	csrr	a0, mepc			# 用a0暂存mepc寄存器的值
	STORE	a0, 31*SIZE_REG(t5)
	
	csrw	mscratch, t5		# 将当前任务的上下文内存地址写回mscratch

	# 2.跳转到.c中的中断处理函数
	# 给trap_handler准备形参
	csrr	a0, mepc			# 从mepc寄存器中读取 异常结束时应该返回的地址(由硬件自动设置),作为函数形参1
	csrr	a1, mcause			# 从mcause寄存器中读取异常原因,作为函数形参2
	csrr	a2, mscratch		# 从mscratch寄存器中读取上下文内存地址,作为函数形参3
	call	trap_handler		# 跳转到C语言的中断处理函数,保存返回地址到ra
	#  如果trap是定时器中断,则不会执行下面的代码了

	# 3.根据中断处理函数的返回值,决定trap结束时返回地址
	csrw 	mepc, a0

	# 4.恢复中断前的寄存器并返回
	csrr    t6, mscratch		# 从mscratch读上下文内存的地址到t6
	reg_restore t6				# 恢复中断前的寄存器
	mret						# 1.将CPU的模式切换回trap前的模式 2.根据mepc寄存器中的返回地址返回(跳转)

.end

