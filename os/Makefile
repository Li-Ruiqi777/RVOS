include ./common.mk

ifeq (${SYSCALL}, y)
DEFS += -DCONFIG_SYSCALL
endif

USE_LINKER_SCRIPT = true

SRCS_ASM = \
	start.S \
	mem.S \

SRCS_C = \
	kernel.c \
	uart.c \
	page.c \
	printf.c \

MKDIR = mkdir -p
RM = rm -rf

OUTPUT_PATH = out

# 将.c、.S文件编译成.o文件，并放入输出目录
OBJS_ASM := $(addprefix ${OUTPUT_PATH}/, $(patsubst %.S, %.o, ${SRCS_ASM}))
OBJS_C   := $(addprefix $(OUTPUT_PATH)/, $(patsubst %.c, %.o, ${SRCS_C}))
OBJS = ${OBJS_ASM} ${OBJS_C}

ELF = ${OUTPUT_PATH}/os.elf
BIN = ${OUTPUT_PATH}/os.bin

# 是否使用用户自定义连接脚本
# gcc -T :指定链接脚本
USE_LINKER_SCRIPT ?= true
ifeq (${USE_LINKER_SCRIPT}, true)
LDFLAGS = -T ${OUTPUT_PATH}/os.ld.generated
else
LDFLAGS = -Ttext=0x80000000
endif

.DEFAULT_GOAL := all
all: ${OUTPUT_PATH} ${ELF}

${OUTPUT_PATH}:
	@${MKDIR} $@

# start.o must be the first in dependency!
#
# 如果 USE_LINKER_SCRIPT == true, 为链接脚本进行预处理，生成 os.ld.generated 文件
# -E : GCC仅进行预处理
# -P : 防止预处理生成 linemarkers (#line directives)
# -x c : 告诉GCC像处理c文件一样处理链接脚本
${ELF}: ${OBJS}
ifeq (${USE_LINKER_SCRIPT}, true)
	${CC} -E -P -x c ${DEFS} ${CFLAGS} os.ld > ${OUTPUT_PATH}/os.ld.generated
endif
	${CC} ${CFLAGS} ${LDFLAGS} -o ${ELF} $^
	${OBJCOPY} -O binary ${ELF} ${BIN}

${OUTPUT_PATH}/%.o : %.c
	${CC} ${DEFS} ${CFLAGS} -c -o $@ $<

${OUTPUT_PATH}/%.o : %.S
	${CC} ${DEFS} ${CFLAGS} -c -o $@ $<

run: all
	@${QEMU} -M ? | grep virt >/dev/null || exit
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo "------------------------------------"
	@${QEMU} ${QFLAGS} -kernel ${ELF}

.PHONY : debug
debug: all
	@echo "Press Ctrl-C and then input 'quit' to exit GDB and QEMU"
	@echo "-------------------------------------------------------"
	@${QEMU} ${QFLAGS} -kernel ${ELF} -s -S &
	@${GDB} ${ELF} -q -x ./gdbinit

.PHONY : code
code: all
	@${OBJDUMP} -S ${ELF} | less

.PHONY : clean
clean:
	@${RM} ${OUTPUT_PATH}
