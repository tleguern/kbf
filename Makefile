SCRIPT= kbf.sh
PROG= ${SCRIPT:R}

BINDIR?= /usr/local/bin

install: maninstall
	${INSTALL} ${INSTALL_COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} \
		${.CURDIR}/${SCRIPT} ${BINDIR}/${PROG}

.include <bsd.prog.mk>
