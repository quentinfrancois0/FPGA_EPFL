#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>

int main() {
	double i;
	IOWR_8DIRECT(PIO_0_BASE, 0x04, 0x0f);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x01);
	for (i=0; i<10000; i++){}
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x02);
	return 0;
}
