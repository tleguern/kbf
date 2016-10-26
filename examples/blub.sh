# Tristan Le Guern <tleguern@bouledef.eu>
# Public domain

fromblub() {
	trivialbrainfucksubstitution "Blub. Blub?" "Blub? Blub." "Blub. Blub." \
		"Blub! Blub!" "Blub! Blub." "Blub. Blub!" "Blub! Blub?" \
		"Blub? Blub!"
}

toblub() {
	trivialbrainfucksubstitution '>' '<' '+' '-' '.' ',' '[' ']' \
		"Blub. Blub?" "Blub? Blub." "Blub. Blub." "Blub! Blub!" \
		"Blub! Blub." "Blub. Blub!" "Blub! Blub?" "Blub? Blub!"
}

