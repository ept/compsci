Output ascii characters as binary numbers (LSB first)

>,
[
  >++++++[<<++++++++>>-]<   Initialize binary digit (ascii '0')
  [-                        First decrement of divide by two loop
    [->>+>+<<<]>>[-<<+>>]   Copy to a place 3 regs to the right
    +>                      Leave a 1 in a flag register
    [<-<<->+>>[-]]          If the loop value is nonzero then clear flag; finish divide by two loop
    <[<<<+>>>-]             If the flag is still there then increment the binary digit to 1
    <<                      End of divide by two loop
  ]
  >[-<+>]                   The new loop value (divided by two)
  <<.[-]>                   Output binary digit
]

++++++++++.                 Newline character

