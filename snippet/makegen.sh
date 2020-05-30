#!/bin/bash
# Generate INCOMPLETE MAKEFILE
#
# usage:
# ../snippet/makegen.sh | unix2dos > dos_make_script_file
#
# dos_makae_script_file will be edited by hand.
# This script doesn't generate complete MAKEFILE,
# but helps writing MAKEFILE by hand.
#
# MAKEFILE header comment, I also apply this license to
# this file.
cat << HEADER_COMMENT
#!MAKE
#  Copyright 2020 Akinori Furuta<afuruta@m7.dion.ne.jp>.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
#  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

HEADER_COMMENT

echo "AS=TASM"
echo "ASFLAGS=/m2"
echo ""
echo "LINK=TLINK"
echo "LINKFLAGS="
echo ""

echo "TARGET=GWBASIC.EXE"
echo ""

echo "LINKER_SCRIPT=GWBASIC.LNK"
echo ""

echo "TOUCH=TOUCH"
echo ""

echo "TRESP_BODY=TRESP"
echo "TRESP=TOOLS\\\$(TRESP_BODY).COM"
echo "TRESP_SRC=TOOLS\\\$(TRESP_BODY).ASM"
echo "TRESP_OBJ=TOOLS\\\$(TRESP_BODY).OBJ"
echo "TRESP_LST=TOOLS\\\$(TRESP_BODY).LST"
echo "TRESP_MAP=TOOLS\\\$(TRESP_BODY).MAP"
echo ""

Objs=()
for f in *.ASM
do
	fObj="${f%.ASM}.OBJ"
	Objs=(${Objs[*]} "${fObj}")
done

ObjsNum=${#Objs[*]}

part=0
part_len=0
part_len_max=80

for o in ${Objs[*]}
do
	if (( ${part_len} <= 0 ))
	then
		echo "OBJS${part}=\\"
	fi
	echo -n $'\t'"${o}"
	l=`echo -n "${o}" | wc -c`
	part_len=$(( ${part_len} + ${l} ))
	if (( ${part_len} <  ${part_len_max} ))
	then
		echo " \\"
	else
		echo ""
		echo ""
		part_len=0
		part=$(( ${part} + 1 ))
	fi
done
if (( ${part_len} > 0 ))
then
	part=$(( ${part} + 1 ))
	echo ""
	echo ""
fi

echo	"OBJS_SUPPLEMENTAL="
echo -n "OBJS="
i=0
while (( ${i} < ${part} ))
do
	echo -n "\$(OBJS${i})"
	i=$(( ${i} + 1 ))
	if (( ${i} < ${part} ))
	then
		echo -n " "
	else
		echo " \$(OBJS_SUPPLEMENTAL)"
	fi
done
echo ""

echo "INCS_SUPPLEMENTAL="

Incs=( *.H GIO86U MSDOSU )

echo "INCS=${Incs[*]} \$(INCS_SUPPLEMENTAL)"
echo ""

echo "ALL : \$(TARGET)"
echo $'\t'"ECHO DONE > ALL"
echo ""

echo "\$(TARGET) : \$(OBJS) \$(LINKER_SCRIPT)"
echo $'\t'"\$(LINK) \$(LINKFLAGS) @\$(LINKER_SCRIPT)"
echo ""

echo "\$(LINKER_SCRIPT) : \$(OBJS) MAKEFILE \$(TRESP)"
echo $'\t'"\$(TRESP) /t +\\r\\n \$(OBJS0) > RESP0.TMP"
echo $'\t'"\$(TRESP) /t +\\r\\n \$(OBJS1) > RESP1.TMP"
echo $'\t'"\$(TRESP) /t +\\r\\n \$(OBJS2) > RESP2.TMP"
echo $'\t'"\$(TRESP) /t +\\r\\n \$(OBJS3) > RESP3.TMP"
echo $'\t'"\$(TRESP) /t +\\r\\n \$(OBJS_SUPPLEMENTAL) > RESPS.TMP"
echo $'\t'"ECHO , \$(TARGET) > RESPT.TMP"
echo $'\t'"TYPE RESP0.TMP RESP1.TMP RESP2.TMP RESP3.TMP RESPS.TMP RESPT.TMP > \$(LINKER_SCRIPT)"
echo ""

echo "\$(TRESP): \$(TRESP_SRC)"
echo $'\t'"\$(AS) \$(ASFLAGS) \$(TRESP_SRC), \$(TRESP_OBJ), \$(TRESP_LST)"
echo $'\t'"\$(LINK) /t \$(TRESP_OBJ), \$<, \$(TRESP_MAP)"
echo ""

for f in *.ASM
do
	fAsm="${f}"
	fObj="${f%.ASM}.OBJ"
	echo "${fObj} : ${fAsm} \$(INCS)"
	echo $'\t'"\$(AS) \$(ASFLAGS) \$*.ASM,,"
	echo
done

echo "CLEAN:"
echo $'\t'"DEL *.OBJ"
echo $'\t'"DEL *.LST"
echo $'\t'"DEL *.MAP"
echo $'\t'"DEL *.EXE"
echo $'\t'"DEL ALL"
echo $'\t'"DEL RESP*.TMP"
echo $'\t'"DEL TOOLS\*.OBJ"
echo $'\t'"DEL TOOLS\*.LST"
echo $'\t'"DEL TOOLS\*.MAP"
echo $'\t'"DEL TOOLS\*.COM"
