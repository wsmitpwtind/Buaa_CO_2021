ori $s0, $0, 0x7

label_3:
ori $s1, $0, 0x7
jal label_1
ori $s1, $0, 0xf

j label_2
label_1: 
bne $s0, $s1, label_3
ori $s2, $0, 0xf
ori $s4, $0, 0x1

jr $ra
label_2: 
