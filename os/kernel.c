#include "os.h"

// 这些函数只应该在这里被调用一次，所以只声明一次，不包含在文件 os.h 中
extern void uart_init(void);
extern void page_init(void);
extern void sched_init(void);
extern void schedule(void);
extern void os_main(void);
extern void trap_init();

void start_kernel(void)
{
	uart_init();
	uart_puts("Hello, RVOS!\n");

	page_init();
	trap_init();

	sched_init();

	os_main();

	schedule();

	uart_puts("Would not go here!\n");
	while (1)
	{
	};
}
