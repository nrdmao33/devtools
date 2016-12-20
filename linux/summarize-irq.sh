#!/bin/bash
#
cat /proc/interrupts |
    awk '
    {
        if ($1 == "CPU0") {
            NCPUS = NF
	    printf("%4.4s ", "CPU")
	    for (i = 0; i < NCPUS; i++) {
		printf("%d", i / 10)
	    }
	    printf("\n%4.4s ", "IRQ")
	    for (i = 0; i < NCPUS; i++) {
		printf("%d", i % 10)
	    }
	    printf("\n")
            next
        }
        printf("%4.4s ", $1)
        for (i = 2; i <= NF; i++) {
            if (i > (NCPUS + 1)) {
                printf(" %s", $i)
            } else {
                if ($i == 0) {
                    printf("0")
                } else {
                    printf("X")
                }
            }
        }
        printf("\n")
    }'

