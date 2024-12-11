extern void uart_init();
extern void uart_puts(char *s);

void start_kernel(void)
{
	uart_init();
	uart_puts("666\r \n");
	while (1) {
		
	};
}

