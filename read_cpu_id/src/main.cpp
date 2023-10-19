#include <Arduino.h>

const uint32_t ADDRESS = 0x1FFF7A10;
const uint8_t NUM_BYTES = 12;
uint8_t buffer[NUM_BYTES];

void setup()
{
  Serial1.setRx(PA10);
  Serial1.setTx(PA9);
  Serial1.begin(9600);

  // Read the bytes from the specified address into the buffer
  memcpy(buffer, (void *)ADDRESS, NUM_BYTES);
}

void loop()
{
  // Print the bytes to the terminal
  for (int i = 0; i < NUM_BYTES; i++)
  {
    Serial1.print(buffer[i], HEX);
    Serial1.print(" ");
  }
  Serial1.println();

  // Wait for a second before printing again
  delay(1000);
}
