#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

// -- DEISO --
#include "pstat.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// -- DEISO --

uint64
sys_settickets(void)
{
  int tickets;
  argint(0, &tickets);

  if (tickets < 1)
    return -1;
  myproc()->tickets = tickets;
  return 0;
}

uint64 
sys_getpinfo(void)
{
  struct pstat pstat; //En kernel
  uint64 upstat; //Dirección del pstat que se ha pasado. En usuario
  argaddr(0, &upstat); 
  if (&upstat <= 0)
    return -1;

  getpinfo(&pstat); //Se ha rellenado pstat con los datos en el kernel

  if(copyout(myproc()->pagetable, upstat, (char *)&pstat,sizeof(pstat)) < 0) // Copiamos la pstat desde el kernel al espacio de usuario
      return -1;

  return 0;
}