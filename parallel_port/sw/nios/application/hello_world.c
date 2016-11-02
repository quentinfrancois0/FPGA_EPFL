#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>

void InitPort(void) {
	IOWR_8DIRECT(PARALLEL_PORT0_0_BASE, 0x00, 0x00); //ParPort 0
	IOWR_8DIRECT(PARALLEL_PORT0_1_BASE, 0x00, 0xff); //ParPort 1
}

int main(void) {

	InitPort();

	while(1) {
		int data = IORD_8DIRECT(PARALLEL_PORT0_0_BASE, 0x01);
		IOWR_8DIRECT(PARALLEL_PORT0_1_BASE, 0x02, data);
	}

	return 1;
}
