.text
	ori $t1,$0,8
	ori $t2,$0,10
	beq $t1,$t2,label1
	ori $t3,$0,1
	j end
	label1:
	ori $t3,$0,2
	end:
