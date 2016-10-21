#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

int main() {
	uint32_t pio_data = IORD_8DIRECT(__ALTERA_AVALON_PIO, 0x00)

	return 0;
}
