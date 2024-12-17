#include "os.h"

// 由于CPU是通过定时器中断来进行任务调度的，关闭中断就相当于停止任务调度，间接的维护了临界区的互斥性
int spin_lock()
{
	w_mstatus(r_mstatus() & ~MSTATUS_MIE);
	return 0;
}

int spin_unlock()
{
	w_mstatus(r_mstatus() | MSTATUS_MIE);
	return 0;
}
