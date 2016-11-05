SCRIPT= kbf.sh
PROG= ${SCRIPT:R}

BINDIR?= /usr/local/bin

install: maninstall
	${INSTALL} ${INSTALL_COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} \
		${.CURDIR}/${SCRIPT} ${BINDIR}/${PROG}

SPELL_TARGETS= README.md regress/README.md kbf.1 kbf.3 kbf.sh
SPELL_LIST= tools/spell_extra_list
spell:
	spell -b +${SPELL_LIST} ${SPELL_TARGETS} | diff tools/spell_output -

.include <bsd.prog.mk>
