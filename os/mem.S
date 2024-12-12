#define SIZE_PTR .word

# 指定接下来的代码将在 .rodata(read-only data) 节中
.section .rodata

# 定义链接脚本中的变量, 用于存放各段的起始地址和大小
.global HEAP_START
HEAP_START: SIZE_PTR _heap_start

.global HEAP_SIZE
HEAP_SIZE: SIZE_PTR _heap_size

.global TEXT_START
TEXT_START: SIZE_PTR _text_start

.global TEXT_END
TEXT_END: SIZE_PTR _text_end

.global DATA_START
DATA_START: SIZE_PTR _data_start

.global DATA_END
DATA_END: SIZE_PTR _data_end

.global RODATA_START
RODATA_START: SIZE_PTR _rodata_start

.global RODATA_END
RODATA_END: SIZE_PTR _rodata_end

.global BSS_START
BSS_START: SIZE_PTR _bss_start

.global BSS_END
BSS_END: SIZE_PTR _bss_end
