/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/zhangke/Desktop/CO/p1/vote.v";
static int ng1[] = {0, 0};
static int ng2[] = {32, 0};
static int ng3[] = {1, 0};
static unsigned int ng4[] = {4U, 0U};
static unsigned int ng5[] = {16U, 0U};
static unsigned int ng6[] = {1U, 0U};
static unsigned int ng7[] = {0U, 0U};



static void Initial_30_0(char *t0)
{
    char t5[8];
    char t17[8];
    char t23[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t24;

LAB0:    xsi_set_current_line(31, ng0);

LAB2:    xsi_set_current_line(32, ng0);
    xsi_set_current_line(32, ng0);
    t1 = ((char*)((ng1)));
    t2 = (t0 + 2088);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 32);

LAB3:    t1 = (t0 + 2088);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = ((char*)((ng2)));
    memset(t5, 0, 8);
    xsi_vlog_signed_less(t5, 32, t3, 32, t4, 32);
    t6 = (t5 + 4);
    t7 = *((unsigned int *)t6);
    t8 = (~(t7));
    t9 = *((unsigned int *)t5);
    t10 = (t9 & t8);
    t11 = (t10 != 0);
    if (t11 > 0)
        goto LAB4;

LAB5:
LAB1:    return;
LAB4:    xsi_set_current_line(33, ng0);

LAB6:    xsi_set_current_line(34, ng0);
    t12 = (t0 + 1928);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t0 + 1048U);
    t16 = *((char **)t15);
    t15 = (t0 + 1008U);
    t18 = (t15 + 72U);
    t19 = *((char **)t18);
    t20 = (t0 + 2088);
    t21 = (t20 + 56U);
    t22 = *((char **)t21);
    xsi_vlog_generic_get_index_select_value(t17, 32, t16, t19, 2, t22, 32, 1);
    memset(t23, 0, 8);
    xsi_vlog_unsigned_add(t23, 32, t14, 32, t17, 32);
    t24 = (t0 + 1928);
    xsi_vlogvar_assign_value(t24, t23, 0, 0, 32);
    xsi_set_current_line(32, ng0);
    t1 = (t0 + 2088);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = ((char*)((ng3)));
    memset(t5, 0, 8);
    xsi_vlog_signed_add(t5, 32, t3, 32, t4, 32);
    t6 = (t0 + 2088);
    xsi_vlogvar_assign_value(t6, t5, 0, 0, 32);
    goto LAB3;

}

static void Cont_37_1(char *t0)
{
    char t3[8];
    char t4[8];
    char t5[8];
    char t11[8];
    char t19[8];
    char t20[8];
    char t23[8];
    char t24[8];
    char t26[8];
    char *t1;
    char *t2;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    char *t10;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    char *t17;
    char *t18;
    char *t21;
    char *t22;
    char *t25;
    char *t27;
    char *t28;
    char *t29;
    char *t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    char *t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    char *t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    char *t46;
    char *t47;
    char *t48;
    char *t49;
    char *t50;
    char *t51;
    unsigned int t52;
    unsigned int t53;
    char *t54;
    unsigned int t55;
    unsigned int t56;
    char *t57;
    unsigned int t58;
    unsigned int t59;
    char *t60;

LAB0:    t1 = (t0 + 3256U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(37, ng0);
    t2 = (t0 + 1048U);
    t6 = *((char **)t2);
    memset(t5, 0, 8);
    t2 = (t6 + 4);
    t7 = *((unsigned int *)t6);
    t8 = *((unsigned int *)t2);
    t9 = (t7 | t8);
    if (t9 != 4294967295U)
        goto LAB5;

LAB4:    if (*((unsigned int *)t2) == 0)
        goto LAB6;

LAB7:    t10 = (t5 + 4);
    *((unsigned int *)t5) = 1;
    *((unsigned int *)t10) = 1;

LAB5:    t12 = (t0 + 1208U);
    t13 = *((char **)t12);
    memset(t11, 0, 8);
    t12 = (t13 + 4);
    t14 = *((unsigned int *)t13);
    t15 = *((unsigned int *)t12);
    t16 = (t14 | t15);
    if (t16 != 255U)
        goto LAB9;

LAB8:    if (*((unsigned int *)t12) == 0)
        goto LAB10;

LAB11:    t17 = (t11 + 4);
    *((unsigned int *)t11) = 1;
    *((unsigned int *)t17) = 1;

LAB9:    t18 = ((char*)((ng4)));
    memset(t19, 0, 8);
    xsi_vlog_unsigned_multiply(t19, 32, t11, 32, t18, 32);
    memset(t20, 0, 8);
    xsi_vlog_unsigned_add(t20, 32, t5, 32, t19, 32);
    t21 = (t0 + 1368U);
    t22 = *((char **)t21);
    t21 = ((char*)((ng5)));
    memset(t23, 0, 8);
    xsi_vlog_unsigned_multiply(t23, 32, t22, 1, t21, 32);
    memset(t24, 0, 8);
    xsi_vlog_unsigned_add(t24, 32, t20, 32, t23, 32);
    t25 = ((char*)((ng2)));
    memset(t26, 0, 8);
    t27 = (t24 + 4);
    if (*((unsigned int *)t27) != 0)
        goto LAB13;

LAB12:    t28 = (t25 + 4);
    if (*((unsigned int *)t28) != 0)
        goto LAB13;

LAB16:    if (*((unsigned int *)t24) < *((unsigned int *)t25))
        goto LAB15;

LAB14:    *((unsigned int *)t26) = 1;

LAB15:    memset(t4, 0, 8);
    t30 = (t26 + 4);
    t31 = *((unsigned int *)t30);
    t32 = (~(t31));
    t33 = *((unsigned int *)t26);
    t34 = (t33 & t32);
    t35 = (t34 & 1U);
    if (t35 != 0)
        goto LAB17;

LAB18:    if (*((unsigned int *)t30) != 0)
        goto LAB19;

LAB20:    t37 = (t4 + 4);
    t38 = *((unsigned int *)t4);
    t39 = *((unsigned int *)t37);
    t40 = (t38 || t39);
    if (t40 > 0)
        goto LAB21;

LAB22:    t42 = *((unsigned int *)t4);
    t43 = (~(t42));
    t44 = *((unsigned int *)t37);
    t45 = (t43 || t44);
    if (t45 > 0)
        goto LAB23;

LAB24:    if (*((unsigned int *)t37) > 0)
        goto LAB25;

LAB26:    if (*((unsigned int *)t4) > 0)
        goto LAB27;

LAB28:    memcpy(t3, t46, 8);

LAB29:    t47 = (t0 + 3656);
    t48 = (t47 + 56U);
    t49 = *((char **)t48);
    t50 = (t49 + 56U);
    t51 = *((char **)t50);
    memset(t51, 0, 8);
    t52 = 1U;
    t53 = t52;
    t54 = (t3 + 4);
    t55 = *((unsigned int *)t3);
    t52 = (t52 & t55);
    t56 = *((unsigned int *)t54);
    t53 = (t53 & t56);
    t57 = (t51 + 4);
    t58 = *((unsigned int *)t51);
    *((unsigned int *)t51) = (t58 | t52);
    t59 = *((unsigned int *)t57);
    *((unsigned int *)t57) = (t59 | t53);
    xsi_driver_vfirst_trans(t47, 0, 0);
    t60 = (t0 + 3576);
    *((int *)t60) = 1;

LAB1:    return;
LAB6:    *((unsigned int *)t5) = 1;
    goto LAB5;

LAB10:    *((unsigned int *)t11) = 1;
    goto LAB9;

LAB13:    t29 = (t26 + 4);
    *((unsigned int *)t26) = 1;
    *((unsigned int *)t29) = 1;
    goto LAB15;

LAB17:    *((unsigned int *)t4) = 1;
    goto LAB20;

LAB19:    t36 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t36) = 1;
    goto LAB20;

LAB21:    t41 = ((char*)((ng6)));
    goto LAB22;

LAB23:    t46 = ((char*)((ng7)));
    goto LAB24;

LAB25:    xsi_vlog_unsigned_bit_combine(t3, 1, t41, 1, t46, 1);
    goto LAB29;

LAB27:    memcpy(t3, t41, 8);
    goto LAB29;

}


extern void work_m_00000000003015248483_4097232175_init()
{
	static char *pe[] = {(void *)Initial_30_0,(void *)Cont_37_1};
	xsi_register_didat("work_m_00000000003015248483_4097232175", "isim/vote_isim_beh.exe.sim/work/m_00000000003015248483_4097232175.didat");
	xsi_register_executes(pe);
}
