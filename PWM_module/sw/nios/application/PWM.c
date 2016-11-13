#include <inttypes.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

void InitPWM(void) {
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x00, 0x41); //PWM clock divider = 0x0f41 => frequency = 50 Hz => period = 20 ms
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x01, 0x0f);
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x02, 0x80); //PWM duty cycle = 50% => t_on = 10 ms
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x03, 0x01); //PWM polarity = 1
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x05, 0x00); //PWM output control = 0
}

void ConfigDutyCycle(int duty_cycle) {
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x02, duty_cycle); //Modify the value of the duty cycle register
}

void EnablePWM(void) {
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x05, 0x01); //PWM output control = 1
}

void DisablePWM(void) {
	IOWR_8DIRECT(PWM_MODULE_0_BASE, 0x05, 0x00); //PWM output control = 0
}

int main(void) {

	InitPWM(); //Initialization of the PWM module
	ConfigDutyCycle(0x13); //PWM duty cycle = 7.5% => t_on = 1.50 ms
	EnablePWM(); //Enable the PWM
	
	while(1) { //Infinite loop
	
	usleep(1000*1000); //Wait for 1 s

	ConfigDutyCycle(0x16); //PWM duty cycle = 8.5% => t_on = 1.70 ms
	usleep(1000*1000); //Wait for 1 s
	
	ConfigDutyCycle(0x19); //PWM duty cycle = 9.75% => t_on = 1.95 ms
	usleep(1000*1000); //Wait for 1 s
	
	ConfigDutyCycle(0x0d); //PWM duty cycle = 5.25% => t_on = 1.05 ms
	usleep(1000*1000); //Wait for 1 s
	
	ConfigDutyCycle(0x11); //PWM duty cycle = 6.5% => t_on = 1.30 ms
	usleep(1000*1000); //Wait for 1 s
	
	ConfigDutyCycle(0x13); //PWM duty cycle = 7.5% => t_on = 1.50 ms

	}

	return 1;
}
