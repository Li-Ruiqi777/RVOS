# RVOS
在Qemu模拟的RISC-V架构SoC上开发的一个简易RTOS



## 项目结构

- docker：环境搭建相关脚本
- os：RTOS的源码目录
- docs：个人笔记

## features
- 虽然qemu的risc-v virt板子支持8核,但RVOS只用到了1个核,其他7个核被挂起(`start.S`实现)
- 系统入口的设置：通过链接脚本文件的`ENTRY()`函数设置程序启动时第一个跳转到的位置
- 内存管理：没实现page_table，虚拟内存之类的。对物理内存的heap区实现page的管理(分配和释放)
- trap处理：risc-v的trap处理通常分为以下步骤
  - 初始化：设置`mtvec`寄存器的地址
  - trap上半部：发生trap时，硬件自动将PC指针跳转到`mtvec`寄存器的地址，并且将原先PC（或PC+4）的值保存到mepc
  - trap下半部：指的是用户自己实现的`trap_handler`，一般会先保存上下文，然后跳转到C进行trap处理，最后再通过mepc返回发生trap前的指令继续执行

- 系统调度
  - 协作式多任务：协作指的是OS不会打断一个执行流，除非它自己放弃`yeild()`（用软中断）
  - 抢占式多任务：使用时间片轮转算法，在硬件定时器中打断当前任务，并切换到FIFO中的下个任务
- `spin lock`：实现自旋锁的时候，要使用原子操作（CAS）来读取锁当前的状态并上锁。在RVOS中由于是单核且通过中断调度的，所以采用关闭中断的方式来实现对临界区的并发控制
- 单次软件定时器：使用全局的`ticks`来实现，在硬件定时器中断上下文中对当前`ticks`进行判断，来看软件定时器是否超时
- CPU的特权等级：RVOS中仅涉及到机器模式和用户模式
  - 刚上电的时候处于机器模式，在`mret`时会根据`mstatus.MPP`发生特权等级的变化


## 参考链接

- [plctlab/riscv-operating-system-mooc: 《从头写一个RISC-V OS》课程配套的资源 (github.com)](https://github.com/plctlab/riscv-operating-system-mooc/tree/main)
- [cccriscv/mini-riscv-os: Build a minimal multi-tasking OS kernel for RISC-V from scratch (github.com)](https://github.com/cccriscv/mini-riscv-os)
- [yanglianoo/rvos: 基于risv-v的操作系统](https://github.com/yanglianoo/rvos)
