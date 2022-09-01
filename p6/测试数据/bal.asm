ori $1,1
ori $2,2
sub $3,$1,$2
beq $1,$3,lable1
addi $4,$31,4
ori $5,5
lable1:
addi $6,$31,6