#include <inttypes.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

void InitPort(void) {
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x00, 0x41); //PWM clock divider = 0x0f41 => frequency = 50 Hz
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x01, 0x0f);
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x02, 0xb3); //PWM duty cycle = 70%
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x03, 0x01); //PWM polarity = 1
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x05, 0x01); //PWM output control = 1
}

int main(void) {

	InitPort();

	while(1) {} //infinite loop

	return 1;
}
