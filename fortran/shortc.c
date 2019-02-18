#include <stdio.h>

int main(void) {

  unsigned int mask, MASK_A, MASK_B;

  MASK_A = 0x1;
  MASK_B = 0x2;

  printf("%d\n", MASK_A);
  printf("%d\n", MASK_B);

  printf("%d\n", MASK_A | MASK_B);

  mask = MASK_A | MASK_B ;

  printf("%d\n", (mask & MASK_B) == MASK_B);
  printf("%d\n", mask & MASK_B);

  return 0;
}
