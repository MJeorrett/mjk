#include <stdint.h>

#define PERIPHERAL_BASE 0x3F000000UL                    // Base address of the peripheral block.

#define GPFSEL1 (PERIPHERAL_BASE + 0x00200004UL)        // GPIO Function Select 1 Register. Used to define the role of a group of GPIO pins.

#define UART0_BASE (PERIPHERAL_BASE + 0x00201000UL)     // UART0 is the high quality hardware implemented UART we will use for serial communication.

#define UART0_DR   (UART0_BASE + 0x00)                  // Data Register.
#define UART0_FR   (UART0_BASE + 0x18)                  // Flag Register. - Indicates the status of the UART.
#define UART0_IBRD (UART0_BASE + 0x24)                  // Integer Baud Rate Divisor Register.
#define UART0_FBRD (UART0_BASE + 0x28)                  // Fractional Baud Rate Divisor Register.
#define UART0_LCRH (UART0_BASE + 0x2C)                  // Line Control Register High. Set word length, FIFO enable (16 bit hardware queue) and number of stop bits.
#define UART0_CR   (UART0_BASE + 0x30)                  // Control Register. Enable/disable the UART.
#define UART0_ICR  (UART0_BASE + 0x44)                  // Interrupt Clear Register.

static inline void mmio_write(uintptr_t reg, uint32_t val)
{
    *(volatile uint32_t *)reg = val;
}

static inline uint32_t mmio_read(uintptr_t reg)
{
    return *(volatile uint32_t *)reg;
}

static void uart_init(void)
{
    uint32_t ra; // register alias

	/* Set the GPIO pins 14 and 15 to be UART0. */
	ra = mmio_read(GPFSEL1);
	ra &= ~(7u << 12);
	ra |= (4u << 12);
	ra &= ~(7u << 15);
	ra |= (4u << 15);
	mmio_write(GPFSEL1, ra);

	mmio_write(UART0_CR, 0); // Disable the UART while configuring.

	mmio_write(UART0_ICR, 0x7FF); // Clear any pending interrupts.

	/* 48 MHz UART clock → 115200 baud: divisor ≈ 26.042 */
	mmio_write(UART0_IBRD, 26);
	mmio_write(UART0_FBRD, 3);
    
	mmio_write(UART0_LCRH, 0x70); // FIFO, 8N1 (8 data bits, no parity, 1 stop bit)
	mmio_write(UART0_CR, 0x301);  // Re-enble the UART.
}

static void uart0_putc(int c)
{
    while (mmio_read(UART0_FR) & (1u << 5)); // Wait until the UART is ready to transmit.

    mmio_write(UART0_DR, c);
}

static void uart0_puts(const char *s)
{
    while (*s)
    {
        uart0_putc(*s);
        s++;
    }
}

void kernel_main(void)
{
    uart_init();
    uart0_puts("mjk running...\n");

	for (;;)
	{
		__asm__ volatile("wfe");
	}
}