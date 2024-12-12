# RVOS
在Qemu模拟的RISC-V架构SoC上开发的一个简易RTOS



## 项目结构

- docker：环境搭建相关脚本
- os：RTOS的源码目录
- docs：个人笔记

## features
- 虽然qemu的risc-v virt板子支持8核,但RVOS只用到了1个核,其他7个核被挂起(start.S实现)
- 内存管理：没实现page_table，虚拟内存之类的。对物理内存的heap区实现page的管理(分配和释放)

## 参考链接

- [plctlab/riscv-operating-system-mooc: 《从头写一个RISC-V OS》课程配套的资源 (github.com)](https://github.com/plctlab/riscv-operating-system-mooc/tree/main)
- [cccriscv/mini-riscv-os: Build a minimal multi-tasking OS kernel for RISC-V from scratch (github.com)](https://github.com/cccriscv/mini-riscv-os)
- [yanglianoo/rvos: 基于risv-v的操作系统](https://github.com/yanglianoo/rvos)
