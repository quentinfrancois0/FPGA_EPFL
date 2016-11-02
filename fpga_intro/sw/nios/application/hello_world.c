#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>

int main() {
	IOWR_8DIRECT(PIO_0_BASE, 0x04, 0x0f);

	while (1) {
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x01);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x02);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x04);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x08);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x10);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x20);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x40);
	usleep(500000);
	IOWR_8DIRECT(PIO_0_BASE, 0x00, 0x80);
	usleep(500000);
	}

	return 0;
}
