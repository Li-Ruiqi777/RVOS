#include "os.h"

#define DELAY 1000
extern void trap_test();

void user_task0(void)
{
	uart_puts("Task 0: Created!\n");
	task_yield();
	uart_puts("Task 0: 孩子们我回来了!\n");
	while (1) {
		spin_lock();
		for(int i=0;i<5;++i){
			uart_puts("Task 0: Running...\n");
			task_delay(DELAY);
		}
		uart_puts("Task 0: End!\n");
		spin_unlock();
	}
}

void user_task1(void)
{
	uart_puts("Task 1: Created!\n");
	while (1) {
		spin_lock();
		for(int i=0;i<5;++i){
			uart_puts("Task 1: Running...\n");
			task_delay(DELAY);
		}
		uart_puts("Task 1: End!\n");
		spin_unlock();
	}
}

/* NOTICE: DON'T LOOP INFINITELY IN main() */
void os_main(void)
{
	task_create(user_task0);
	task_create(user_task1);
}