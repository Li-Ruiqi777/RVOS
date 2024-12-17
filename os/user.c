#include "os.h"

#define DELAY 5000
extern void trap_test();

struct userdata {
	int counter;
	char *str;
};

/* Jack must be global */
struct userdata person = {0, "Jack"};

void timer_func(void *arg)
{
	if (NULL == arg)
		return;

	struct userdata *param = (struct userdata *)arg;

	param->counter++;
	printf("======> TIMEOUT: %s: %d\n", param->str, param->counter);
}

void user_task0(void)
{
	uart_puts("Task 0: Created!\n");
	task_yield();
	uart_puts("Task 0: 孩子们我回来了!\n");
	timer_create(timer_func, &person, 1);
	timer_create(timer_func, &person, 2);
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
	timer_create(timer_func, &person, 3);
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