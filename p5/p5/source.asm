# jal DEM jieduan
ori $t0 $t0 8
jal label1
addu $ra $ra $t0
nop
label1:
addu $ra $ra $ra
lui $t1 0x1234
#lui DEM jieduan
lui $t0 0x1234
beq $t1 $t0 label2
lui $s1 1
lui $s1 2
label2:
addu $t0 $t0 $t0
nop