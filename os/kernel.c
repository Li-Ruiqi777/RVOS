#include "os.h"

// 这些函数只应该在这里被调用一次，所以只声明一次，不包含在文件 os.h 中
extern void uart_init(void);
extern void page_init(void);
extern void page_test(void);

void start_kernel(void)
{
	uart_init();
	uart_puts("Hello RVOS! \r \n");

	page_init();
	page_test();

	uart_echo();
	while (1)
	{
	};
}
