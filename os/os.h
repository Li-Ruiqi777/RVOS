#ifndef __OS_H__
#define __OS_H__

#include "riscv.h"
#include "types.h"
#include "platform.h"

#include <stddef.h>
#include <stdarg.h>

/* uart */
int uart_putc(char ch);
void uart_puts(char *s);
void uart_echo();

/* printf */
int  printf(const char* s, ...);
void panic(char *s);

/* memory management */
void *page_alloc(int npages);
void page_free(void *p);

/* task management */
// 32个通用寄存器
struct context {
	/* ignore x0 */
	reg_t ra;
	reg_t sp;
	reg_t gp;
	reg_t tp;
	reg_t t0;
	reg_t t1;
	reg_t t2;
	reg_t s0;
	reg_t s1;
	reg_t a0;
	reg_t a1;
	reg_t a2;
	reg_t a3;
	reg_t a4;
	reg_t a5;
	reg_t a6;
	reg_t a7;
	reg_t s2;
	reg_t s3;
	reg_t s4;
	reg_t s5;
	reg_t s6;
	reg_t s7;
	reg_t s8;
	reg_t s9;
	reg_t s10;
	reg_t s11;
	reg_t t3;
	reg_t t4;
	reg_t t5;
	reg_t t6;

	// save the pc to run in next schedule cycle
	reg_t mepc; // offset: 31 * sizeof(reg_t)
};

extern int  task_create(void (*task)(void));
extern void task_delay(volatile int count);
extern void task_yield();

/* plic */
extern int plic_claim(void);
extern void plic_complete(int irq);

#endif /* __OS_H__ */
