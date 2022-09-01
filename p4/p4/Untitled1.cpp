#include <bits/stdc++.h>
using namespace std;

mt19937 rng(time(0));

int rd(int l, int r)
{
    int len = r - l + 1;
    int t = l + (rng() % len + len) % len;
    return t;
}

int t[2], a[2], mem[100000], labcnt, pc = 12288;
//t[o..1]为寄存器编号，a[0..1]为寄存器的当前值，mem为存储器的值，labcnt为标签编号，pc初始值为0x3000

const int DM_size = 100, block_cnt = 20, func_size = 5, inil_size = 10;

FILE *out;

set<int> st;

void func(int op, int on, int bound)
{
	int r1, r2, r3, offset, imm;
	switch(op)
	{
		case 1:
			r1 = rd(0, 1), r2 = rd(0, 1), r3 = rd(0, 1);
			if(bound) r1 = r2 = r3 = 0;
			fprintf(out, "addu $%d, $%d, $%d\n", t[r1], t[r2], t[r3]);
			if(on) a[r1] = a[r2] + a[r3];
			break;
		case 2:
			r1 = rd(0, 1), r2 = rd(0, 1), imm = rd(0, 7);
			if(bound) r1 = r2 = r3 = 0;
			fprintf(out, "ori $%d, $%d, %d\n", t[r1], t[r2], imm);
			if(on) a[r1] = a[r2] | imm;
			break;
		case 3:
			r1 = rd(0, 1), r2 = rd(0, 1);
			if(bound) r1 = r2 = 0;
			offset = (rd(1, 3) + (a[r2]) / 4) * 4 - a[r2];
			fprintf(out, "lw $%d, %d($%d)\n", t[r1], offset, t[r2]);
			if(on) a[r1] = mem[a[r2] + offset];
			break;
		case 4:
			r1 = rd(0, 1), r2 = rd(0, 1);
			if(bound) r1 = r2 = 0;
			offset = (rd(1, 3) + (a[r2]) / 4) * 4 - a[r2];
			fprintf(out, "sw $%d, %d($%d)\n", t[r1], offset, t[r2]);
			if(on) {
				mem[a[r2] + offset] = a[r1];
				st.insert(a[r2] + offset);
			}
			break;
		case 5:
			r1 = rd(0, 1), r2 = rd(0, 1), imm = rd(0, 1);
			if(bound) r1 = r2 = r3 = 0;
			fprintf(out, "sra $%d, $%d, %d\n", t[r1], t[r2], imm);
			if(on) a[r1] = a[r2] >> imm;
			break;
	}
	pc += 4;
}


void BR()
{
	st.clear();
	int op, bound;
	
	t[0] = rd(1, 30), t[1] = rd(1, 30);
	a[0] = rd(0, inil_size), a[1] = rd(0, inil_size);
	fprintf(out, "ori $%d, $0, %d\n", t[0], a[0]);
	fprintf(out, "ori $%d, $0, %d\n", t[1], a[1]);
	pc += 8;
	if(t[0] == t[1]) a[0] = a[1], bound = 1;
	else bound = 0;
			
	for(int i = 1; i <= 6; i++) op = rd(1, func_size), func(op, 1, bound);
	
	int r1 = rd(0, 1), r2 = rd(0, 1), br, coin = rd(0, 1);
	if(bound) r1 = r2 = 0;
	
	
	if(coin == 0)
	{
		br = a[r1] == a[r2];
		fprintf(out, "beq $%d, $%d, label%d\n", t[r1], t[r2], ++labcnt); pc += 4;
	}
	else
	{
		br = a[r1] >= 0;
		fprintf(out, "bgez $%d, label%d\n", t[r1], ++labcnt); pc += 4;
	}
	
	op = rd(1, func_size); func(op, 1, bound);
	
	for(int i = 1; i <= 4; i++) op = rd(1, func_size), func(op, !br, bound);
	
	
	fprintf(out, "label%d: ", labcnt);
	
	for(int i = 1; i <= 2; i++)	op = rd(1, func_size), func(op, 1, bound);
	
	for(auto v: st)
	{
		mem[v] = rd(0, inil_size);
		fprintf(out, "ori $t0, $0, %d\n", mem[v]);
		fprintf(out, "sw $t0, %d($0)\n", v);	
		pc += 8;	
	}		
}

void JAL()
{
	int op, bound = 1;
	st.clear();
	
	t[0] = 31; a[0] = rd(0, inil_size);
	fprintf(out, "ori $%d, $0, %d\n", t[0], a[0]);
	pc += 4;
		
	for(int i = 1; i <= 6; i++)	op = rd(1, func_size), func(op, 1, bound);
	
	fprintf(out, "jal label%d\n", ++labcnt);
	a[0] = pc + 8;
	pc += 4;
	
	int tar = rd(0, inil_size);
	
	fprintf(out, "addi $31, $31, %d\n", tar - a[0]);
	a[0] = tar;
	pc += 4;
	
	fprintf(out, "label%d: ", labcnt);
	
	for(int i = 1; i <= 4; i++)	op = rd(1, func_size), func(op, 1, bound);

	fprintf(out, "addi $31, $31, %d\n", pc + 12 - a[0]);
	a[0] = pc + 12;
	pc += 4;
	
	fprintf(out, "jr $31\n"); pc += 4;
	
	tar = rd(0, inil_size);	
	fprintf(out, "addi $31, $31, %d\n", tar - a[0]);
	a[0] = tar;
	pc += 4;
	
	for(int i = 1; i <= 4; i++) op = rd(1, func_size), func(op, 1, bound);
	


	for(auto v: st)
	{
		mem[v] = rd(0, inil_size);
		fprintf(out, "ori $t0, $0, %d\n", mem[v]);
		fprintf(out, "sw $t0, %d($0)\n", v);	
		pc += 8;	
	}		
	
	fprintf(out, "jal label%d\n", ++labcnt);
	pc += 4;
	fprintf(out, "addi $31, $31, 4\n");
	pc += 4;
	fprintf(out, "label%d: ", labcnt);
	fprintf(out, "jr $31\n");
	pc += 4;
	fprintf(out, "nop\n");
	pc += 4;
	fprintf(out, "jal label%d\n", ++labcnt);
	pc += 4;
	fprintf(out, "addi $31, $31, 12\n");
	pc += 4;
	fprintf(out, "label%d: ", labcnt);
	int coin = rd(0, 1);
	if(coin == 0) fprintf(out, "beq $31, $31, label%d\n", ++labcnt);
	else fprintf(out, "bgez $31, label%d\n", ++labcnt);
	pc += 4;
	fprintf(out, "nop\n");
	pc += 4;
	fprintf(out, "label%d: ", labcnt);
	fprintf(out, "jr $31\n");
	pc += 4;
	fprintf(out, "nop\n");
	pc += 4;
}

void JALR()
{
	st.clear();
	t[0] = 31, t[1] = rd(1, 30), a[0] = rd(0, inil_size), a[1] = rd(0, inil_size);
	fprintf(out, "ori $%d, $0, %d\n", t[0], a[0]);
	fprintf(out, "ori $%d, $0, %d\n", t[1], a[1]);
	pc += 8;
	int bound = 0, tar, op;
	
	
	for(int i = 1; i <= 6; i++)	op = rd(1, func_size), func(op, 1, bound);
	
	
	fprintf(out, "addi $31, $31, %d\n", pc + 12 - a[0]);
	a[0] = pc + 12;
	pc += 4;
	
	fprintf(out, "jalr $%d, $31\n", t[1]);
	a[1] = pc + 8;
	pc += 4;
	
	tar = rd(0, inil_size);	
	fprintf(out, "addi $31, $31, %d\n", tar - a[0]);
	a[0] = tar;
	pc += 4;
	
	tar = rd(0, inil_size);	
	fprintf(out, "addi $%d, $%d, %d\n", t[1], t[1], tar - a[1]);
	a[1] = tar;
	pc += 4;
	
	for(int i = 1; i <= 4; i++)	op = rd(1, func_size), func(op, 1, bound);
	
	
	fprintf(out, "addi $%d, $%d, %d\n", t[1], t[1], pc + 12 - a[1]);
	a[1] = pc + 12;
	pc += 4;
	
	fprintf(out, "jr $%d\n", t[1]);
	pc += 4;
	
	tar = rd(0, inil_size);
	
	fprintf(out, "addi $%d, $%d, %d\n", t[1], t[1], tar - a[1]);
	a[1] = tar;
	pc += 4;
	
	for(int i = 1; i <= 4; i++) op = rd(1, func_size), func(op, 1, bound);	
	
	for(auto v: st)
	{
		mem[v] = rd(0, inil_size);
		fprintf(out, "ori $t0, $0, %d\n", mem[v]);
		fprintf(out, "sw $t0, %d($0)\n", v);	
		pc += 8;	
	}
}

int main()
{	
	out = fopen("mips.txt", "w");
	
	fprintf(out, "ori $28, $0, 0\n");
	fprintf(out, "ori $29, $0, 0\n");
	pc += 8;
	
	for(int i = 0; i < DM_size ; i++)
	{
		int x = rd(0, inil_size);
		fprintf(out, "ori $t0, $0, %d\n", x);
		fprintf(out, "sw $t0, %d($0)\n", i << 2);
		pc += 8;
		mem[i << 2] = x;
	}
	
	for(int T = 1; T <= block_cnt; T++)
	{
		int coin = rd(1, 4);
		
		if(coin == 1 || coin == 2)
		{
			BR();
		}
		else if(coin == 3)
		{
			JAL();
		}
		else if(coin == 4)
		{
			JALR();
		}

	}	
	return 0;
}
