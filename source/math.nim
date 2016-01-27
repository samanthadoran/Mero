proc log2*(x: int): int =
  asm """
  bsr %1, %0
  : "=r"(`result`)
  : "r"(`x`)
  """

proc pow*(base: int, power: int): int =
  if power == 0:
    if base == 0:
      asm """
      int $19
      """
    result = 1
  else:
    result = base
    for i in 2..power:
      result = base * result
