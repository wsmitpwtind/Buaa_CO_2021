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
static const char *ng0 = "C:/Users/zhangke/Desktop/CO/p5/DM.v";
static unsigned int ng1[] = {0U, 0U};
static int ng2[] = {0, 0};
static int ng3[] = {4096, 0};
static int ng4[] = {1, 0};
static int ng5[] = {2, 0};
static unsigned int ng6[] = {4294967292U, 0U};
static int ng7[] = {31, 0};
static int ng8[] = {24, 0};
static int ng9[] = {23, 0};
static int ng10[] = {16, 0};
static int ng11[] = {15, 0};
static int ng12[] = {8, 0};
static int ng13[] = {7, 0};
static const char *ng14 = "%d@%h: *%h <= %h";



static void Cont_37_0(char *t0)
{
    char t3[8];
    char t4[8];
    char t6[8];
    char *t1;
    char *t2;
    char *t5;
    char *t7;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    char *t33;
    char *t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    char *t39;
    char *t40;
    char *t41;
    char *t42;
    char *t43;
    char *t44;

LAB0:    t1 = (t0 + 4128U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(37, ng0);
    t2 = (t0 + 1368U);
    t5 = *((char **)t2);
    t2 = ((char*)((ng1)));
    memset(t6, 0, 8);
    t7 = (t5 + 4);
    t8 = (t2 + 4);
    t9 = *((unsigned int *)t5);
    t10 = *((unsigned int *)t2);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t7);
    t13 = *((unsigned int *)t8);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t7);
    t17 = *((unsigned int *)t8);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB5;

LAB4:    if (t18 != 0)
        goto LAB6;

LAB7:    memset(t4, 0, 8);
    t22 = (t6 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 & 1U);
    if (t27 != 0)
        goto LAB8;

LAB9:    if (*((unsigned int *)t22) != 0)
        goto LAB10;

LAB11:    t29 = (t4 + 4);
    t30 = *((unsigned int *)t4);
    t31 = *((unsigned int *)t29);
    t32 = (t30 || t31);
    if (t32 > 0)
        goto LAB12;

LAB13:    t35 = *((unsigned int *)t4);
    t36 = (~(t35));
    t37 = *((unsigned int *)t29);
    t38 = (t36 || t37);
    if (t38 > 0)
        goto LAB14;

LAB15:    if (*((unsigned int *)t29) > 0)
        goto LAB16;

LAB17:    if (*((unsigned int *)t4) > 0)
        goto LAB18;

LAB19:    memcpy(t3, t39, 8);

LAB20:    t33 = (t0 + 5568);
    t40 = (t33 + 56U);
    t41 = *((char **)t40);
    t42 = (t41 + 56U);
    t43 = *((char **)t42);
    memcpy(t43, t3, 8);
    xsi_driver_vfirst_trans(t33, 0, 31);
    t44 = (t0 + 5440);
    *((int *)t44) = 1;

LAB1:    return;
LAB5:    *((unsigned int *)t6) = 1;
    goto LAB7;

LAB6:    t21 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB7;

LAB8:    *((unsigned int *)t4) = 1;
    goto LAB11;

LAB10:    t28 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t28) = 1;
    goto LAB11;

LAB12:    t33 = (t0 + 1688U);
    t34 = *((char **)t33);
    goto LAB13;

LAB14:    t33 = (t0 + 1528U);
    t39 = *((char **)t33);
    goto LAB15;

LAB16:    xsi_vlog_unsigned_bit_combine(t3, 32, t34, 32, t39, 32);
    goto LAB20;

LAB18:    memcpy(t3, t34, 8);
    goto LAB20;

}

static void Initial_42_1(char *t0)
{
    char t5[8];
    char t14[8];
    char t15[8];
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
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    unsigned int t26;
    int t27;
    char *t28;
    unsigned int t29;
    int t30;
    int t31;
    unsigned int t32;
    unsigned int t33;
    int t34;
    int t35;

LAB0:    xsi_set_current_line(42, ng0);

LAB2:    xsi_set_current_line(43, ng0);
    xsi_set_current_line(43, ng0);
    t1 = ((char*)((ng2)));
    t2 = (t0 + 2888);
    xsi_vlogvar_assign_value(t2, t1, 0, 0, 32);

LAB3:    t1 = (t0 + 2888);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = ((char*)((ng3)));
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
LAB4:    xsi_set_current_line(44, ng0);
    t12 = ((char*)((ng2)));
    t13 = (t0 + 2728);
    t16 = (t0 + 2728);
    t17 = (t16 + 72U);
    t18 = *((char **)t17);
    t19 = (t0 + 2728);
    t20 = (t19 + 64U);
    t21 = *((char **)t20);
    t22 = (t0 + 2888);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    xsi_vlog_generic_convert_array_indices(t14, t15, t18, t21, 2, 1, t24, 32, 1);
    t25 = (t14 + 4);
    t26 = *((unsigned int *)t25);
    t27 = (!(t26));
    t28 = (t15 + 4);
    t29 = *((unsigned int *)t28);
    t30 = (!(t29));
    t31 = (t27 && t30);
    if (t31 == 1)
        goto LAB6;

LAB7:    xsi_set_current_line(43, ng0);
    t1 = (t0 + 2888);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = ((char*)((ng4)));
    memset(t5, 0, 8);
    xsi_vlog_signed_add(t5, 32, t3, 32, t4, 32);
    t6 = (t0 + 2888);
    xsi_vlogvar_assign_value(t6, t5, 0, 0, 32);
    goto LAB3;

LAB6:    t32 = *((unsigned int *)t14);
    t33 = *((unsigned int *)t15);
    t34 = (t32 - t33);
    t35 = (t34 + 1);
    xsi_vlogvar_assign_value(t13, t12, 0, *((unsigned int *)t15), t35);
    goto LAB7;

}

static void Cont_47_2(char *t0)
{
    char t5[8];
    char t12[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t13;
    char *t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;

LAB0:    t1 = (t0 + 4624U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(47, ng0);
    t2 = (t0 + 2728);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = (t0 + 2728);
    t7 = (t6 + 72U);
    t8 = *((char **)t7);
    t9 = (t0 + 2728);
    t10 = (t9 + 64U);
    t11 = *((char **)t10);
    t13 = (t0 + 2328U);
    t14 = *((char **)t13);
    memset(t12, 0, 8);
    t13 = (t12 + 4);
    t15 = (t14 + 4);
    t16 = *((unsigned int *)t14);
    t17 = (t16 >> 2);
    *((unsigned int *)t12) = t17;
    t18 = *((unsigned int *)t15);
    t19 = (t18 >> 2);
    *((unsigned int *)t13) = t19;
    t20 = *((unsigned int *)t12);
    *((unsigned int *)t12) = (t20 & 4095U);
    t21 = *((unsigned int *)t13);
    *((unsigned int *)t13) = (t21 & 4095U);
    xsi_vlog_generic_get_array_select_value(t5, 32, t4, t8, t11, 2, 1, t12, 12, 2);
    t22 = (t0 + 5632);
    t23 = (t22 + 56U);
    t24 = *((char **)t23);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    memcpy(t26, t5, 8);
    xsi_driver_vfirst_trans(t22, 0, 31);
    t27 = (t0 + 5456);
    *((int *)t27) = 1;

LAB1:    return;
}

static void Always_52_3(char *t0)
{
    char t7[8];
    char t16[8];
    char t44[8];
    char t45[8];
    char t46[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    int t36;
    int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    char *t47;
    int t48;
    char *t49;
    int t50;
    int t51;
    int t52;
    int t53;
    int t54;

LAB0:    t1 = (t0 + 4872U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(52, ng0);
    t2 = (t0 + 5472);
    *((int *)t2) = 1;
    t3 = (t0 + 4904);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(52, ng0);

LAB5:    xsi_set_current_line(53, ng0);
    t4 = (t0 + 2728);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t8 = (t0 + 2728);
    t9 = (t8 + 72U);
    t10 = *((char **)t9);
    t11 = (t0 + 2728);
    t12 = (t11 + 64U);
    t13 = *((char **)t12);
    t14 = (t0 + 2328U);
    t15 = *((char **)t14);
    t14 = ((char*)((ng5)));
    memset(t16, 0, 8);
    xsi_vlog_unsigned_rshift(t16, 32, t15, 32, t14, 32);
    xsi_vlog_generic_get_array_select_value(t7, 32, t6, t10, t13, 2, 1, t16, 32, 2);
    t17 = (t0 + 3208);
    xsi_vlogvar_assign_value(t17, t7, 0, 0, 32);
    xsi_set_current_line(54, ng0);
    t2 = (t0 + 2328U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng6)));
    t18 = *((unsigned int *)t3);
    t19 = *((unsigned int *)t2);
    t20 = (t18 & t19);
    *((unsigned int *)t7) = t20;
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t6 = (t7 + 4);
    t21 = *((unsigned int *)t4);
    t22 = *((unsigned int *)t5);
    t23 = (t21 | t22);
    *((unsigned int *)t6) = t23;
    t24 = *((unsigned int *)t6);
    t25 = (t24 != 0);
    if (t25 == 1)
        goto LAB6;

LAB7:
LAB8:    t10 = (t0 + 3048);
    xsi_vlogvar_assign_value(t10, t7, 0, 0, 32);
    xsi_set_current_line(55, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    memset(t7, 0, 8);
    t2 = (t7 + 4);
    t4 = (t3 + 4);
    t18 = *((unsigned int *)t3);
    t19 = (t18 >> 3);
    t20 = (t19 & 1);
    *((unsigned int *)t7) = t20;
    t21 = *((unsigned int *)t4);
    t22 = (t21 >> 3);
    t23 = (t22 & 1);
    *((unsigned int *)t2) = t23;
    t5 = (t7 + 4);
    t24 = *((unsigned int *)t5);
    t25 = (~(t24));
    t26 = *((unsigned int *)t7);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB9;

LAB10:
LAB11:    xsi_set_current_line(56, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    memset(t7, 0, 8);
    t2 = (t7 + 4);
    t4 = (t3 + 4);
    t18 = *((unsigned int *)t3);
    t19 = (t18 >> 2);
    t20 = (t19 & 1);
    *((unsigned int *)t7) = t20;
    t21 = *((unsigned int *)t4);
    t22 = (t21 >> 2);
    t23 = (t22 & 1);
    *((unsigned int *)t2) = t23;
    t5 = (t7 + 4);
    t24 = *((unsigned int *)t5);
    t25 = (~(t24));
    t26 = *((unsigned int *)t7);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB14;

LAB15:
LAB16:    xsi_set_current_line(57, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    memset(t7, 0, 8);
    t2 = (t7 + 4);
    t4 = (t3 + 4);
    t18 = *((unsigned int *)t3);
    t19 = (t18 >> 1);
    t20 = (t19 & 1);
    *((unsigned int *)t7) = t20;
    t21 = *((unsigned int *)t4);
    t22 = (t21 >> 1);
    t23 = (t22 & 1);
    *((unsigned int *)t2) = t23;
    t5 = (t7 + 4);
    t24 = *((unsigned int *)t5);
    t25 = (~(t24));
    t26 = *((unsigned int *)t7);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB19;

LAB20:
LAB21:    xsi_set_current_line(58, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    memset(t7, 0, 8);
    t2 = (t7 + 4);
    t4 = (t3 + 4);
    t18 = *((unsigned int *)t3);
    t19 = (t18 >> 0);
    t20 = (t19 & 1);
    *((unsigned int *)t7) = t20;
    t21 = *((unsigned int *)t4);
    t22 = (t21 >> 0);
    t23 = (t22 & 1);
    *((unsigned int *)t2) = t23;
    t5 = (t7 + 4);
    t24 = *((unsigned int *)t5);
    t25 = (~(t24));
    t26 = *((unsigned int *)t7);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB24;

LAB25:
LAB26:    goto LAB2;

LAB6:    t26 = *((unsigned int *)t7);
    t27 = *((unsigned int *)t6);
    *((unsigned int *)t7) = (t26 | t27);
    t8 = (t3 + 4);
    t9 = (t2 + 4);
    t28 = *((unsigned int *)t3);
    t29 = (~(t28));
    t30 = *((unsigned int *)t8);
    t31 = (~(t30));
    t32 = *((unsigned int *)t2);
    t33 = (~(t32));
    t34 = *((unsigned int *)t9);
    t35 = (~(t34));
    t36 = (t29 & t31);
    t37 = (t33 & t35);
    t38 = (~(t36));
    t39 = (~(t37));
    t40 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t40 & t38);
    t41 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t41 & t39);
    t42 = *((unsigned int *)t7);
    *((unsigned int *)t7) = (t42 & t38);
    t43 = *((unsigned int *)t7);
    *((unsigned int *)t7) = (t43 & t39);
    goto LAB8;

LAB9:    xsi_set_current_line(55, ng0);
    t6 = (t0 + 1848U);
    t8 = *((char **)t6);
    memset(t16, 0, 8);
    t6 = (t16 + 4);
    t9 = (t8 + 4);
    t29 = *((unsigned int *)t8);
    t30 = (t29 >> 24);
    *((unsigned int *)t16) = t30;
    t31 = *((unsigned int *)t9);
    t32 = (t31 >> 24);
    *((unsigned int *)t6) = t32;
    t33 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t33 & 255U);
    t34 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t34 & 255U);
    t10 = (t0 + 3208);
    t11 = (t0 + 3208);
    t12 = (t11 + 72U);
    t13 = *((char **)t12);
    t14 = ((char*)((ng7)));
    t15 = ((char*)((ng8)));
    xsi_vlog_convert_partindices(t44, t45, t46, ((int*)(t13)), 2, t14, 32, 1, t15, 32, 1);
    t17 = (t44 + 4);
    t35 = *((unsigned int *)t17);
    t36 = (!(t35));
    t47 = (t45 + 4);
    t38 = *((unsigned int *)t47);
    t37 = (!(t38));
    t48 = (t36 && t37);
    t49 = (t46 + 4);
    t39 = *((unsigned int *)t49);
    t50 = (!(t39));
    t51 = (t48 && t50);
    if (t51 == 1)
        goto LAB12;

LAB13:    goto LAB11;

LAB12:    t40 = *((unsigned int *)t46);
    t52 = (t40 + 0);
    t41 = *((unsigned int *)t44);
    t42 = *((unsigned int *)t45);
    t53 = (t41 - t42);
    t54 = (t53 + 1);
    xsi_vlogvar_assign_value(t10, t16, t52, *((unsigned int *)t45), t54);
    goto LAB13;

LAB14:    xsi_set_current_line(56, ng0);
    t6 = (t0 + 1848U);
    t8 = *((char **)t6);
    memset(t16, 0, 8);
    t6 = (t16 + 4);
    t9 = (t8 + 4);
    t29 = *((unsigned int *)t8);
    t30 = (t29 >> 16);
    *((unsigned int *)t16) = t30;
    t31 = *((unsigned int *)t9);
    t32 = (t31 >> 16);
    *((unsigned int *)t6) = t32;
    t33 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t33 & 255U);
    t34 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t34 & 255U);
    t10 = (t0 + 3208);
    t11 = (t0 + 3208);
    t12 = (t11 + 72U);
    t13 = *((char **)t12);
    t14 = ((char*)((ng9)));
    t15 = ((char*)((ng10)));
    xsi_vlog_convert_partindices(t44, t45, t46, ((int*)(t13)), 2, t14, 32, 1, t15, 32, 1);
    t17 = (t44 + 4);
    t35 = *((unsigned int *)t17);
    t36 = (!(t35));
    t47 = (t45 + 4);
    t38 = *((unsigned int *)t47);
    t37 = (!(t38));
    t48 = (t36 && t37);
    t49 = (t46 + 4);
    t39 = *((unsigned int *)t49);
    t50 = (!(t39));
    t51 = (t48 && t50);
    if (t51 == 1)
        goto LAB17;

LAB18:    goto LAB16;

LAB17:    t40 = *((unsigned int *)t46);
    t52 = (t40 + 0);
    t41 = *((unsigned int *)t44);
    t42 = *((unsigned int *)t45);
    t53 = (t41 - t42);
    t54 = (t53 + 1);
    xsi_vlogvar_assign_value(t10, t16, t52, *((unsigned int *)t45), t54);
    goto LAB18;

LAB19:    xsi_set_current_line(57, ng0);
    t6 = (t0 + 1848U);
    t8 = *((char **)t6);
    memset(t16, 0, 8);
    t6 = (t16 + 4);
    t9 = (t8 + 4);
    t29 = *((unsigned int *)t8);
    t30 = (t29 >> 8);
    *((unsigned int *)t16) = t30;
    t31 = *((unsigned int *)t9);
    t32 = (t31 >> 8);
    *((unsigned int *)t6) = t32;
    t33 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t33 & 255U);
    t34 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t34 & 255U);
    t10 = (t0 + 3208);
    t11 = (t0 + 3208);
    t12 = (t11 + 72U);
    t13 = *((char **)t12);
    t14 = ((char*)((ng11)));
    t15 = ((char*)((ng12)));
    xsi_vlog_convert_partindices(t44, t45, t46, ((int*)(t13)), 2, t14, 32, 1, t15, 32, 1);
    t17 = (t44 + 4);
    t35 = *((unsigned int *)t17);
    t36 = (!(t35));
    t47 = (t45 + 4);
    t38 = *((unsigned int *)t47);
    t37 = (!(t38));
    t48 = (t36 && t37);
    t49 = (t46 + 4);
    t39 = *((unsigned int *)t49);
    t50 = (!(t39));
    t51 = (t48 && t50);
    if (t51 == 1)
        goto LAB22;

LAB23:    goto LAB21;

LAB22:    t40 = *((unsigned int *)t46);
    t52 = (t40 + 0);
    t41 = *((unsigned int *)t44);
    t42 = *((unsigned int *)t45);
    t53 = (t41 - t42);
    t54 = (t53 + 1);
    xsi_vlogvar_assign_value(t10, t16, t52, *((unsigned int *)t45), t54);
    goto LAB23;

LAB24:    xsi_set_current_line(58, ng0);
    t6 = (t0 + 1848U);
    t8 = *((char **)t6);
    memset(t16, 0, 8);
    t6 = (t16 + 4);
    t9 = (t8 + 4);
    t29 = *((unsigned int *)t8);
    t30 = (t29 >> 0);
    *((unsigned int *)t16) = t30;
    t31 = *((unsigned int *)t9);
    t32 = (t31 >> 0);
    *((unsigned int *)t6) = t32;
    t33 = *((unsigned int *)t16);
    *((unsigned int *)t16) = (t33 & 255U);
    t34 = *((unsigned int *)t6);
    *((unsigned int *)t6) = (t34 & 255U);
    t10 = (t0 + 3208);
    t11 = (t0 + 3208);
    t12 = (t11 + 72U);
    t13 = *((char **)t12);
    t14 = ((char*)((ng13)));
    t15 = ((char*)((ng2)));
    xsi_vlog_convert_partindices(t44, t45, t46, ((int*)(t13)), 2, t14, 32, 1, t15, 32, 1);
    t17 = (t44 + 4);
    t35 = *((unsigned int *)t17);
    t36 = (!(t35));
    t47 = (t45 + 4);
    t38 = *((unsigned int *)t47);
    t37 = (!(t38));
    t48 = (t36 && t37);
    t49 = (t46 + 4);
    t39 = *((unsigned int *)t49);
    t50 = (!(t39));
    t51 = (t48 && t50);
    if (t51 == 1)
        goto LAB27;

LAB28:    goto LAB26;

LAB27:    t40 = *((unsigned int *)t46);
    t52 = (t40 + 0);
    t41 = *((unsigned int *)t44);
    t42 = *((unsigned int *)t45);
    t53 = (t41 - t42);
    t54 = (t53 + 1);
    xsi_vlogvar_assign_value(t10, t16, t52, *((unsigned int *)t45), t54);
    goto LAB28;

}

static void Always_61_4(char *t0)
{
    char t13[8];
    char t15[8];
    char t16[8];
    char t38[8];
    char t45[16];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t14;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    unsigned int t27;
    int t28;
    char *t29;
    unsigned int t30;
    int t31;
    int t32;
    unsigned int t33;
    unsigned int t34;
    int t35;
    int t36;
    unsigned int t37;
    char *t39;
    unsigned int t40;
    char *t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;

LAB0:    t1 = (t0 + 5120U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(61, ng0);
    t2 = (t0 + 5488);
    *((int *)t2) = 1;
    t3 = (t0 + 5152);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(61, ng0);

LAB5:    xsi_set_current_line(62, ng0);
    t4 = (t0 + 1208U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(63, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    memset(t13, 0, 8);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 & 15U);
    if (t10 != 0)
        goto LAB14;

LAB15:    if (*((unsigned int *)t2) != 0)
        goto LAB16;

LAB17:    t5 = (t13 + 4);
    t27 = *((unsigned int *)t5);
    t30 = (~(t27));
    t33 = *((unsigned int *)t13);
    t34 = (t33 & t30);
    t37 = (t34 != 0);
    if (t37 > 0)
        goto LAB18;

LAB19:
LAB20:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(62, ng0);
    xsi_set_current_line(62, ng0);
    t11 = ((char*)((ng2)));
    t12 = (t0 + 2888);
    xsi_vlogvar_assign_value(t12, t11, 0, 0, 32);

LAB9:    t2 = (t0 + 2888);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng3)));
    memset(t13, 0, 8);
    xsi_vlog_signed_less(t13, 32, t4, 32, t5, 32);
    t11 = (t13 + 4);
    t6 = *((unsigned int *)t11);
    t7 = (~(t6));
    t8 = *((unsigned int *)t13);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB10;

LAB11:    goto LAB8;

LAB10:    xsi_set_current_line(62, ng0);
    t12 = ((char*)((ng2)));
    t14 = (t0 + 2728);
    t17 = (t0 + 2728);
    t18 = (t17 + 72U);
    t19 = *((char **)t18);
    t20 = (t0 + 2728);
    t21 = (t20 + 64U);
    t22 = *((char **)t21);
    t23 = (t0 + 2888);
    t24 = (t23 + 56U);
    t25 = *((char **)t24);
    xsi_vlog_generic_convert_array_indices(t15, t16, t19, t22, 2, 1, t25, 32, 1);
    t26 = (t15 + 4);
    t27 = *((unsigned int *)t26);
    t28 = (!(t27));
    t29 = (t16 + 4);
    t30 = *((unsigned int *)t29);
    t31 = (!(t30));
    t32 = (t28 && t31);
    if (t32 == 1)
        goto LAB12;

LAB13:    xsi_set_current_line(62, ng0);
    t2 = (t0 + 2888);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng4)));
    memset(t13, 0, 8);
    xsi_vlog_signed_add(t13, 32, t4, 32, t5, 32);
    t11 = (t0 + 2888);
    xsi_vlogvar_assign_value(t11, t13, 0, 0, 32);
    goto LAB9;

LAB12:    t33 = *((unsigned int *)t15);
    t34 = *((unsigned int *)t16);
    t35 = (t33 - t34);
    t36 = (t35 + 1);
    xsi_vlogvar_wait_assign_value(t14, t12, 0, *((unsigned int *)t16), t36, 0LL);
    goto LAB13;

LAB14:    *((unsigned int *)t13) = 1;
    goto LAB17;

LAB16:    t4 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t4) = 1;
    goto LAB17;

LAB18:    xsi_set_current_line(63, ng0);

LAB21:    xsi_set_current_line(64, ng0);
    t11 = (t0 + 3208);
    t12 = (t11 + 56U);
    t14 = *((char **)t12);
    t17 = (t0 + 2728);
    t18 = (t0 + 2728);
    t19 = (t18 + 72U);
    t20 = *((char **)t19);
    t21 = (t0 + 2728);
    t22 = (t21 + 64U);
    t23 = *((char **)t22);
    t24 = (t0 + 3048);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    t29 = ((char*)((ng5)));
    memset(t38, 0, 8);
    xsi_vlog_unsigned_rshift(t38, 32, t26, 32, t29, 32);
    xsi_vlog_generic_convert_array_indices(t15, t16, t20, t23, 2, 1, t38, 32, 2);
    t39 = (t15 + 4);
    t40 = *((unsigned int *)t39);
    t28 = (!(t40));
    t41 = (t16 + 4);
    t42 = *((unsigned int *)t41);
    t31 = (!(t42));
    t32 = (t28 && t31);
    if (t32 == 1)
        goto LAB22;

LAB23:    xsi_set_current_line(65, ng0);
    t2 = xsi_vlog_time(t45, 1000.0000000000000, 1000.0000000000000);
    t3 = (t0 + 2168U);
    t4 = *((char **)t3);
    t3 = (t0 + 3048);
    t5 = (t3 + 56U);
    t11 = *((char **)t5);
    t12 = (t0 + 3208);
    t14 = (t12 + 56U);
    t17 = *((char **)t14);
    xsi_vlogfile_write(1, 0, 0, ng14, 5, t0, (char)118, t45, 64, (char)118, t4, 32, (char)118, t11, 32, (char)118, t17, 32);
    goto LAB20;

LAB22:    t43 = *((unsigned int *)t15);
    t44 = *((unsigned int *)t16);
    t35 = (t43 - t44);
    t36 = (t35 + 1);
    xsi_vlogvar_wait_assign_value(t17, t14, 0, *((unsigned int *)t16), t36, 0LL);
    goto LAB23;

}


extern void work_m_00000000000221389309_2924402094_init()
{
	static char *pe[] = {(void *)Cont_37_0,(void *)Initial_42_1,(void *)Cont_47_2,(void *)Always_52_3,(void *)Always_61_4};
	xsi_register_didat("work_m_00000000000221389309_2924402094", "isim/tmips_isim_beh.exe.sim/work/m_00000000000221389309_2924402094.didat");
	xsi_register_executes(pe);
}
