
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	25013103          	ld	sp,592(sp) # 8000a250 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdac1f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	1ca020ef          	jal	800022c4 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	15c50513          	addi	a0,a0,348 # 800122b0 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	15048493          	addi	s1,s1,336 # 800122b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	1e090913          	addi	s2,s2,480 # 80012348 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	7d3010ef          	jal	80002156 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	591010ef          	jal	80001f1e <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	11070713          	addi	a4,a4,272 # 800122b0 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	0a8020ef          	jal	8000227a <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	0c650513          	addi	a0,a0,198 # 800122b0 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	12f72a23          	sw	a5,308(a4) # 80012348 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	08650513          	addi	a0,a0,134 # 800122b0 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	03250513          	addi	a0,a0,50 # 800122b0 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	0b4020ef          	jal	80002354 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	00c50513          	addi	a0,a0,12 # 800122b0 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	fee70713          	addi	a4,a4,-18 # 800122b0 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	fc878793          	addi	a5,a5,-56 # 800122b0 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	0327a783          	lw	a5,50(a5) # 80012348 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	f8470713          	addi	a4,a4,-124 # 800122b0 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	f7448493          	addi	s1,s1,-140 # 800122b0 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	f3270713          	addi	a4,a4,-206 # 800122b0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	faf72e23          	sw	a5,-68(a4) # 80012350 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	efe78793          	addi	a5,a5,-258 # 800122b0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	f6c7ab23          	sw	a2,-138(a5) # 8001234c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	f6a50513          	addi	a0,a0,-150 # 80012348 <cons+0x98>
    800003e6:	385010ef          	jal	80001f6a <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	eb450513          	addi	a0,a0,-332 # 800122b0 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	63c78793          	addi	a5,a5,1596 # 80022a48 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	e907a783          	lw	a5,-368(a5) # 80012370 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	e2c50513          	addi	a0,a0,-468 # 80012358 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	bd250513          	addi	a0,a0,-1070 # 80012358 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	bc07a823          	sw	zero,-1072(a5) # 80012370 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	aaf72623          	sw	a5,-1364(a4) # 8000a270 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	b8048493          	addi	s1,s1,-1152 # 80012358 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	b3850513          	addi	a0,a0,-1224 # 80012378 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	a0c7a783          	lw	a5,-1524(a5) # 8000a270 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	9de7b783          	ld	a5,-1570(a5) # 8000a278 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	9de73703          	ld	a4,-1570(a4) # 8000a280 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	ab0a8a93          	addi	s5,s5,-1360 # 80012378 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	9a848493          	addi	s1,s1,-1624 # 8000a278 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	9a498993          	addi	s3,s3,-1628 # 8000a280 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	66c010ef          	jal	80001f6a <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	a2c50513          	addi	a0,a0,-1492 # 80012378 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	9187a783          	lw	a5,-1768(a5) # 8000a270 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	91e73703          	ld	a4,-1762(a4) # 8000a280 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	90e7b783          	ld	a5,-1778(a5) # 8000a278 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	a0298993          	addi	s3,s3,-1534 # 80012378 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	8fa48493          	addi	s1,s1,-1798 # 8000a278 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	8fa90913          	addi	s2,s2,-1798 # 8000a280 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	588010ef          	jal	80001f1e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	9d048493          	addi	s1,s1,-1584 # 80012378 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	8ce7b223          	sd	a4,-1852(a5) # 8000a280 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	95848493          	addi	s1,s1,-1704 # 80012378 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00023797          	auipc	a5,0x23
    80000a5a:	18a78793          	addi	a5,a5,394 # 80023be0 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	93e90913          	addi	s2,s2,-1730 # 800123b0 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	8b050513          	addi	a0,a0,-1872 # 800123b0 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00023517          	auipc	a0,0x23
    80000b14:	0d050513          	addi	a0,a0,208 # 80023be0 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	88248493          	addi	s1,s1,-1918 # 800123b0 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	86e50513          	addi	a0,a0,-1938 # 800123b0 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	84a50513          	addi	a0,a0,-1974 # 800123b0 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb421>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	41a70713          	addi	a4,a4,1050 # 8000a288 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	5ee010ef          	jal	80002486 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	4ec040ef          	jal	80005388 <plicinithart>
  }

  scheduler();        
    80000ea0:	68b000ef          	jal	80001d2a <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	582010ef          	jal	80002462 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	5a2010ef          	jal	80002486 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	486040ef          	jal	8000536e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	49c040ef          	jal	80005388 <plicinithart>
    binit();         // buffer cache
    80000ef0:	443010ef          	jal	80002b32 <binit>
    iinit();         // inode table
    80000ef4:	234020ef          	jal	80003128 <iinit>
    fileinit();      // file table
    80000ef8:	7e1020ef          	jal	80003ed8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	57c040ef          	jal	80005478 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	457000ef          	jal	80001b56 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	36f72f23          	sw	a5,894(a4) # 8000a288 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	3727b783          	ld	a5,882(a5) # 8000a290 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb417>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	0ea7b323          	sd	a0,230(a5) # 8000a290 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	08448493          	addi	s1,s1,132 # 80012800 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	ff4df937          	lui	s2,0xff4df
    8000178a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baddd>
    8000178e:	0936                	slli	s2,s2,0xd
    80001790:	6f590913          	addi	s2,s2,1781
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	bd390913          	addi	s2,s2,-1069
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	7a790913          	addi	s2,s2,1959
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	c58a8a93          	addi	s5,s5,-936 # 80018400 <pstat>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	17048493          	addi	s1,s1,368
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	bb650513          	addi	a0,a0,-1098 # 800123d0 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	bba50513          	addi	a0,a0,-1094 # 800123e8 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	fc648493          	addi	s1,s1,-58 # 80012800 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	ff4df937          	lui	s2,0xff4df
    80001850:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baddd>
    80001854:	0936                	slli	s2,s2,0xd
    80001856:	6f590913          	addi	s2,s2,1781
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	bd390913          	addi	s2,s2,-1069
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	7a790913          	addi	s2,s2,1959
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	b92a0a13          	addi	s4,s4,-1134 # 80018400 <pstat>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	8791                	srai	a5,a5,0x4
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	17048493          	addi	s1,s1,368
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	b3050513          	addi	a0,a0,-1232 # 80012400 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	adc70713          	addi	a4,a4,-1316 # 800123d0 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00009797          	auipc	a5,0x9
    80001924:	8e07a783          	lw	a5,-1824(a5) # 8000a200 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	375000ef          	jal	8000249e <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	784010ef          	jal	800030bc <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	8c07a223          	sw	zero,-1852(a5) # 8000a200 <first.1>
    __sync_synchronize();
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	a7a90913          	addi	s2,s2,-1414 # 800123d0 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	8a078793          	addi	a5,a5,-1888 # 8000a204 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
  p->tickets = 0;
    80001a98:	1604a423          	sw	zero,360(s1)
}
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6105                	addi	sp,sp,32
    80001aa4:	8082                	ret

0000000080001aa6 <allocproc>:
{
    80001aa6:	1101                	addi	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	e04a                	sd	s2,0(sp)
    80001ab0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab2:	00011497          	auipc	s1,0x11
    80001ab6:	d4e48493          	addi	s1,s1,-690 # 80012800 <proc>
    80001aba:	00017917          	auipc	s2,0x17
    80001abe:	94690913          	addi	s2,s2,-1722 # 80018400 <pstat>
    acquire(&p->lock);
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	930ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac8:	4c9c                	lw	a5,24(s1)
    80001aca:	cb91                	beqz	a5,80001ade <allocproc+0x38>
      release(&p->lock);
    80001acc:	8526                	mv	a0,s1
    80001ace:	9beff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad2:	17048493          	addi	s1,s1,368
    80001ad6:	ff2496e3          	bne	s1,s2,80001ac2 <allocproc+0x1c>
  return 0;
    80001ada:	4481                	li	s1,0
    80001adc:	a0b1                	j	80001b28 <allocproc+0x82>
  p->pid = allocpid();
    80001ade:	e6dff0ef          	jal	8000194a <allocpid>
    80001ae2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae4:	4785                	li	a5,1
    80001ae6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae8:	83cff0ef          	jal	80000b24 <kalloc>
    80001aec:	892a                	mv	s2,a0
    80001aee:	eca8                	sd	a0,88(s1)
    80001af0:	c139                	beqz	a0,80001b36 <allocproc+0x90>
  p->pagetable = proc_pagetable(p);
    80001af2:	8526                	mv	a0,s1
    80001af4:	e95ff0ef          	jal	80001988 <proc_pagetable>
    80001af8:	892a                	mv	s2,a0
    80001afa:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001afc:	c529                	beqz	a0,80001b46 <allocproc+0xa0>
  memset(&p->context, 0, sizeof(p->context));
    80001afe:	07000613          	li	a2,112
    80001b02:	4581                	li	a1,0
    80001b04:	06048513          	addi	a0,s1,96
    80001b08:	9c0ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b0c:	00000797          	auipc	a5,0x0
    80001b10:	e0478793          	addi	a5,a5,-508 # 80001910 <forkret>
    80001b14:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b16:	60bc                	ld	a5,64(s1)
    80001b18:	6705                	lui	a4,0x1
    80001b1a:	97ba                	add	a5,a5,a4
    80001b1c:	f4bc                	sd	a5,104(s1)
  p->tickets = 1;
    80001b1e:	4785                	li	a5,1
    80001b20:	16f4a423          	sw	a5,360(s1)
  p->ticks = 0;
    80001b24:	1604a623          	sw	zero,364(s1)
}
    80001b28:	8526                	mv	a0,s1
    80001b2a:	60e2                	ld	ra,24(sp)
    80001b2c:	6442                	ld	s0,16(sp)
    80001b2e:	64a2                	ld	s1,8(sp)
    80001b30:	6902                	ld	s2,0(sp)
    80001b32:	6105                	addi	sp,sp,32
    80001b34:	8082                	ret
    freeproc(p);
    80001b36:	8526                	mv	a0,s1
    80001b38:	f1bff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	94eff0ef          	jal	80000c8c <release>
    return 0;
    80001b42:	84ca                	mv	s1,s2
    80001b44:	b7d5                	j	80001b28 <allocproc+0x82>
    freeproc(p);
    80001b46:	8526                	mv	a0,s1
    80001b48:	f0bff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	93eff0ef          	jal	80000c8c <release>
    return 0;
    80001b52:	84ca                	mv	s1,s2
    80001b54:	bfd1                	j	80001b28 <allocproc+0x82>

0000000080001b56 <userinit>:
{
    80001b56:	1101                	addi	sp,sp,-32
    80001b58:	ec06                	sd	ra,24(sp)
    80001b5a:	e822                	sd	s0,16(sp)
    80001b5c:	e426                	sd	s1,8(sp)
    80001b5e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b60:	f47ff0ef          	jal	80001aa6 <allocproc>
    80001b64:	84aa                	mv	s1,a0
  initproc = p;
    80001b66:	00008797          	auipc	a5,0x8
    80001b6a:	72a7b923          	sd	a0,1842(a5) # 8000a298 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b6e:	03400613          	li	a2,52
    80001b72:	00008597          	auipc	a1,0x8
    80001b76:	69e58593          	addi	a1,a1,1694 # 8000a210 <initcode>
    80001b7a:	6928                	ld	a0,80(a0)
    80001b7c:	f20ff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b80:	6785                	lui	a5,0x1
    80001b82:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b84:	6cb8                	ld	a4,88(s1)
    80001b86:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b8a:	6cb8                	ld	a4,88(s1)
    80001b8c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b8e:	4641                	li	a2,16
    80001b90:	00005597          	auipc	a1,0x5
    80001b94:	69058593          	addi	a1,a1,1680 # 80007220 <etext+0x220>
    80001b98:	15848513          	addi	a0,s1,344
    80001b9c:	a6aff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001ba0:	00005517          	auipc	a0,0x5
    80001ba4:	69050513          	addi	a0,a0,1680 # 80007230 <etext+0x230>
    80001ba8:	623010ef          	jal	800039ca <namei>
    80001bac:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bb0:	478d                	li	a5,3
    80001bb2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	8d6ff0ef          	jal	80000c8c <release>
}
    80001bba:	60e2                	ld	ra,24(sp)
    80001bbc:	6442                	ld	s0,16(sp)
    80001bbe:	64a2                	ld	s1,8(sp)
    80001bc0:	6105                	addi	sp,sp,32
    80001bc2:	8082                	ret

0000000080001bc4 <growproc>:
{
    80001bc4:	1101                	addi	sp,sp,-32
    80001bc6:	ec06                	sd	ra,24(sp)
    80001bc8:	e822                	sd	s0,16(sp)
    80001bca:	e426                	sd	s1,8(sp)
    80001bcc:	e04a                	sd	s2,0(sp)
    80001bce:	1000                	addi	s0,sp,32
    80001bd0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bd2:	d0fff0ef          	jal	800018e0 <myproc>
    80001bd6:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bd8:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bda:	01204c63          	bgtz	s2,80001bf2 <growproc+0x2e>
  } else if(n < 0){
    80001bde:	02094463          	bltz	s2,80001c06 <growproc+0x42>
  p->sz = sz;
    80001be2:	e4ac                	sd	a1,72(s1)
  return 0;
    80001be4:	4501                	li	a0,0
}
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6902                	ld	s2,0(sp)
    80001bee:	6105                	addi	sp,sp,32
    80001bf0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bf2:	4691                	li	a3,4
    80001bf4:	00b90633          	add	a2,s2,a1
    80001bf8:	6928                	ld	a0,80(a0)
    80001bfa:	f44ff0ef          	jal	8000133e <uvmalloc>
    80001bfe:	85aa                	mv	a1,a0
    80001c00:	f16d                	bnez	a0,80001be2 <growproc+0x1e>
      return -1;
    80001c02:	557d                	li	a0,-1
    80001c04:	b7cd                	j	80001be6 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c06:	00b90633          	add	a2,s2,a1
    80001c0a:	6928                	ld	a0,80(a0)
    80001c0c:	eeeff0ef          	jal	800012fa <uvmdealloc>
    80001c10:	85aa                	mv	a1,a0
    80001c12:	bfc1                	j	80001be2 <growproc+0x1e>

0000000080001c14 <fork>:
{
    80001c14:	7139                	addi	sp,sp,-64
    80001c16:	fc06                	sd	ra,56(sp)
    80001c18:	f822                	sd	s0,48(sp)
    80001c1a:	f04a                	sd	s2,32(sp)
    80001c1c:	e456                	sd	s5,8(sp)
    80001c1e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c20:	cc1ff0ef          	jal	800018e0 <myproc>
    80001c24:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c26:	e81ff0ef          	jal	80001aa6 <allocproc>
    80001c2a:	0e050e63          	beqz	a0,80001d26 <fork+0x112>
    80001c2e:	ec4e                	sd	s3,24(sp)
    80001c30:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c32:	048ab603          	ld	a2,72(s5)
    80001c36:	692c                	ld	a1,80(a0)
    80001c38:	050ab503          	ld	a0,80(s5)
    80001c3c:	83bff0ef          	jal	80001476 <uvmcopy>
    80001c40:	04054a63          	bltz	a0,80001c94 <fork+0x80>
    80001c44:	f426                	sd	s1,40(sp)
    80001c46:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c48:	048ab783          	ld	a5,72(s5)
    80001c4c:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c50:	058ab683          	ld	a3,88(s5)
    80001c54:	87b6                	mv	a5,a3
    80001c56:	0589b703          	ld	a4,88(s3)
    80001c5a:	12068693          	addi	a3,a3,288
    80001c5e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c62:	6788                	ld	a0,8(a5)
    80001c64:	6b8c                	ld	a1,16(a5)
    80001c66:	6f90                	ld	a2,24(a5)
    80001c68:	01073023          	sd	a6,0(a4)
    80001c6c:	e708                	sd	a0,8(a4)
    80001c6e:	eb0c                	sd	a1,16(a4)
    80001c70:	ef10                	sd	a2,24(a4)
    80001c72:	02078793          	addi	a5,a5,32
    80001c76:	02070713          	addi	a4,a4,32
    80001c7a:	fed792e3          	bne	a5,a3,80001c5e <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c7e:	0589b783          	ld	a5,88(s3)
    80001c82:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c86:	0d0a8493          	addi	s1,s5,208
    80001c8a:	0d098913          	addi	s2,s3,208
    80001c8e:	150a8a13          	addi	s4,s5,336
    80001c92:	a831                	j	80001cae <fork+0x9a>
    freeproc(np);
    80001c94:	854e                	mv	a0,s3
    80001c96:	dbdff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c9a:	854e                	mv	a0,s3
    80001c9c:	ff1fe0ef          	jal	80000c8c <release>
    return -1;
    80001ca0:	597d                	li	s2,-1
    80001ca2:	69e2                	ld	s3,24(sp)
    80001ca4:	a895                	j	80001d18 <fork+0x104>
  for(i = 0; i < NOFILE; i++)
    80001ca6:	04a1                	addi	s1,s1,8
    80001ca8:	0921                	addi	s2,s2,8
    80001caa:	01448963          	beq	s1,s4,80001cbc <fork+0xa8>
    if(p->ofile[i])
    80001cae:	6088                	ld	a0,0(s1)
    80001cb0:	d97d                	beqz	a0,80001ca6 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cb2:	2a8020ef          	jal	80003f5a <filedup>
    80001cb6:	00a93023          	sd	a0,0(s2)
    80001cba:	b7f5                	j	80001ca6 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cbc:	150ab503          	ld	a0,336(s5)
    80001cc0:	5fa010ef          	jal	800032ba <idup>
    80001cc4:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cc8:	4641                	li	a2,16
    80001cca:	158a8593          	addi	a1,s5,344
    80001cce:	15898513          	addi	a0,s3,344
    80001cd2:	934ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cd6:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001cda:	854e                	mv	a0,s3
    80001cdc:	fb1fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001ce0:	00010497          	auipc	s1,0x10
    80001ce4:	70848493          	addi	s1,s1,1800 # 800123e8 <wait_lock>
    80001ce8:	8526                	mv	a0,s1
    80001cea:	f0bfe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001cee:	0359bc23          	sd	s5,56(s3)
  np->tickets = p->tickets;
    80001cf2:	168aa783          	lw	a5,360(s5)
    80001cf6:	16f9a423          	sw	a5,360(s3)
  release(&wait_lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	f91fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001d00:	854e                	mv	a0,s3
    80001d02:	ef3fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001d06:	478d                	li	a5,3
    80001d08:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d0c:	854e                	mv	a0,s3
    80001d0e:	f7ffe0ef          	jal	80000c8c <release>
  return pid;
    80001d12:	74a2                	ld	s1,40(sp)
    80001d14:	69e2                	ld	s3,24(sp)
    80001d16:	6a42                	ld	s4,16(sp)
}
    80001d18:	854a                	mv	a0,s2
    80001d1a:	70e2                	ld	ra,56(sp)
    80001d1c:	7442                	ld	s0,48(sp)
    80001d1e:	7902                	ld	s2,32(sp)
    80001d20:	6aa2                	ld	s5,8(sp)
    80001d22:	6121                	addi	sp,sp,64
    80001d24:	8082                	ret
    return -1;
    80001d26:	597d                	li	s2,-1
    80001d28:	bfc5                	j	80001d18 <fork+0x104>

0000000080001d2a <scheduler>:
{
    80001d2a:	7159                	addi	sp,sp,-112
    80001d2c:	f486                	sd	ra,104(sp)
    80001d2e:	f0a2                	sd	s0,96(sp)
    80001d30:	eca6                	sd	s1,88(sp)
    80001d32:	e8ca                	sd	s2,80(sp)
    80001d34:	e4ce                	sd	s3,72(sp)
    80001d36:	e0d2                	sd	s4,64(sp)
    80001d38:	fc56                	sd	s5,56(sp)
    80001d3a:	f85a                	sd	s6,48(sp)
    80001d3c:	f45e                	sd	s7,40(sp)
    80001d3e:	f062                	sd	s8,32(sp)
    80001d40:	ec66                	sd	s9,24(sp)
    80001d42:	e86a                	sd	s10,16(sp)
    80001d44:	e46e                	sd	s11,8(sp)
    80001d46:	1880                	addi	s0,sp,112
    80001d48:	8792                	mv	a5,tp
  int id = r_tp();
    80001d4a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d4c:	00779d13          	slli	s10,a5,0x7
    80001d50:	00010717          	auipc	a4,0x10
    80001d54:	68070713          	addi	a4,a4,1664 # 800123d0 <pid_lock>
    80001d58:	976a                	add	a4,a4,s10
    80001d5a:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001d5e:	00010717          	auipc	a4,0x10
    80001d62:	6aa70713          	addi	a4,a4,1706 # 80012408 <cpus+0x8>
    80001d66:	9d3a                	add	s10,s10,a4
    for (p = proc; p < &proc[NPROC]; p++){
    80001d68:	00016997          	auipc	s3,0x16
    80001d6c:	69898993          	addi	s3,s3,1688 # 80018400 <pstat>
    int winning_ticket = rand_seed % total_tickets;
    80001d70:	0432cdb7          	lui	s11,0x432c
    80001d74:	270d8d9b          	addiw	s11,s11,624 # 432c270 <_entry-0x7bcd3d90>
          c->proc = p;
    80001d78:	079e                	slli	a5,a5,0x7
    80001d7a:	00010b17          	auipc	s6,0x10
    80001d7e:	656b0b13          	addi	s6,s6,1622 # 800123d0 <pid_lock>
    80001d82:	9b3e                	add	s6,s6,a5
    80001d84:	a869                	j	80001e1e <scheduler+0xf4>
      release(&p->lock);
    80001d86:	8526                	mv	a0,s1
    80001d88:	f05fe0ef          	jal	80000c8c <release>
    for (p = proc; p < &proc[NPROC]; p++){
    80001d8c:	17048493          	addi	s1,s1,368
    80001d90:	01348d63          	beq	s1,s3,80001daa <scheduler+0x80>
      acquire(&p->lock);
    80001d94:	8526                	mv	a0,s1
    80001d96:	e5ffe0ef          	jal	80000bf4 <acquire>
      if (p->state == RUNNABLE){
    80001d9a:	4c9c                	lw	a5,24(s1)
    80001d9c:	ff2795e3          	bne	a5,s2,80001d86 <scheduler+0x5c>
        total_tickets += p->tickets;
    80001da0:	1684a783          	lw	a5,360(s1)
    80001da4:	01478a3b          	addw	s4,a5,s4
    80001da8:	bff9                	j	80001d86 <scheduler+0x5c>
    int winning_ticket = rand_seed % total_tickets;
    80001daa:	034dea3b          	remw	s4,s11,s4
    int suma_tickets = 0;
    80001dae:	4a81                	li	s5,0
    int found = 0;
    80001db0:	4b81                	li	s7,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db2:	00011497          	auipc	s1,0x11
    80001db6:	a4e48493          	addi	s1,s1,-1458 # 80012800 <proc>
          p->state = RUNNING;
    80001dba:	4c91                	li	s9,4
          found = 1;
    80001dbc:	4c05                	li	s8,1
    80001dbe:	a801                	j	80001dce <scheduler+0xa4>
      release(&p->lock);
    80001dc0:	8526                	mv	a0,s1
    80001dc2:	ecbfe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dc6:	17048493          	addi	s1,s1,368
    80001dca:	05348063          	beq	s1,s3,80001e0a <scheduler+0xe0>
      acquire(&p->lock);
    80001dce:	8526                	mv	a0,s1
    80001dd0:	e25fe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001dd4:	4c9c                	lw	a5,24(s1)
    80001dd6:	ff2795e3          	bne	a5,s2,80001dc0 <scheduler+0x96>
        suma_tickets += p->tickets;
    80001dda:	1684a783          	lw	a5,360(s1)
    80001dde:	01578abb          	addw	s5,a5,s5
        if(suma_tickets > winning_ticket) {
    80001de2:	fd5a5fe3          	bge	s4,s5,80001dc0 <scheduler+0x96>
          p->ticks++;
    80001de6:	16c4a783          	lw	a5,364(s1)
    80001dea:	2785                	addiw	a5,a5,1
    80001dec:	16f4a623          	sw	a5,364(s1)
          p->state = RUNNING;
    80001df0:	0194ac23          	sw	s9,24(s1)
          c->proc = p;
    80001df4:	029b3823          	sd	s1,48(s6)
          swtch(&c->context, &p->context);
    80001df8:	06048593          	addi	a1,s1,96
    80001dfc:	856a                	mv	a0,s10
    80001dfe:	5fa000ef          	jal	800023f8 <swtch>
          c->proc = 0;
    80001e02:	020b3823          	sd	zero,48(s6)
          found = 1;
    80001e06:	8be2                	mv	s7,s8
    80001e08:	bf65                	j	80001dc0 <scheduler+0x96>
    if(found == 0) {
    80001e0a:	000b9b63          	bnez	s7,80001e20 <scheduler+0xf6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e16:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e1a:	10500073          	wfi
      if (p->state == RUNNABLE){
    80001e1e:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e20:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e24:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e28:	10079073          	csrw	sstatus,a5
    int total_tickets = 0;
    80001e2c:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++){
    80001e2e:	00011497          	auipc	s1,0x11
    80001e32:	9d248493          	addi	s1,s1,-1582 # 80012800 <proc>
    80001e36:	bfb9                	j	80001d94 <scheduler+0x6a>

0000000080001e38 <sched>:
{
    80001e38:	7179                	addi	sp,sp,-48
    80001e3a:	f406                	sd	ra,40(sp)
    80001e3c:	f022                	sd	s0,32(sp)
    80001e3e:	ec26                	sd	s1,24(sp)
    80001e40:	e84a                	sd	s2,16(sp)
    80001e42:	e44e                	sd	s3,8(sp)
    80001e44:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e46:	a9bff0ef          	jal	800018e0 <myproc>
    80001e4a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e4c:	d3ffe0ef          	jal	80000b8a <holding>
    80001e50:	c92d                	beqz	a0,80001ec2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e52:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e54:	2781                	sext.w	a5,a5
    80001e56:	079e                	slli	a5,a5,0x7
    80001e58:	00010717          	auipc	a4,0x10
    80001e5c:	57870713          	addi	a4,a4,1400 # 800123d0 <pid_lock>
    80001e60:	97ba                	add	a5,a5,a4
    80001e62:	0a87a703          	lw	a4,168(a5)
    80001e66:	4785                	li	a5,1
    80001e68:	06f71363          	bne	a4,a5,80001ece <sched+0x96>
  if(p->state == RUNNING)
    80001e6c:	4c98                	lw	a4,24(s1)
    80001e6e:	4791                	li	a5,4
    80001e70:	06f70563          	beq	a4,a5,80001eda <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e74:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e78:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e7a:	e7b5                	bnez	a5,80001ee6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e7c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e7e:	00010917          	auipc	s2,0x10
    80001e82:	55290913          	addi	s2,s2,1362 # 800123d0 <pid_lock>
    80001e86:	2781                	sext.w	a5,a5
    80001e88:	079e                	slli	a5,a5,0x7
    80001e8a:	97ca                	add	a5,a5,s2
    80001e8c:	0ac7a983          	lw	s3,172(a5)
    80001e90:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e92:	2781                	sext.w	a5,a5
    80001e94:	079e                	slli	a5,a5,0x7
    80001e96:	00010597          	auipc	a1,0x10
    80001e9a:	57258593          	addi	a1,a1,1394 # 80012408 <cpus+0x8>
    80001e9e:	95be                	add	a1,a1,a5
    80001ea0:	06048513          	addi	a0,s1,96
    80001ea4:	554000ef          	jal	800023f8 <swtch>
    80001ea8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eaa:	2781                	sext.w	a5,a5
    80001eac:	079e                	slli	a5,a5,0x7
    80001eae:	993e                	add	s2,s2,a5
    80001eb0:	0b392623          	sw	s3,172(s2)
}
    80001eb4:	70a2                	ld	ra,40(sp)
    80001eb6:	7402                	ld	s0,32(sp)
    80001eb8:	64e2                	ld	s1,24(sp)
    80001eba:	6942                	ld	s2,16(sp)
    80001ebc:	69a2                	ld	s3,8(sp)
    80001ebe:	6145                	addi	sp,sp,48
    80001ec0:	8082                	ret
    panic("sched p->lock");
    80001ec2:	00005517          	auipc	a0,0x5
    80001ec6:	37650513          	addi	a0,a0,886 # 80007238 <etext+0x238>
    80001eca:	8cbfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001ece:	00005517          	auipc	a0,0x5
    80001ed2:	37a50513          	addi	a0,a0,890 # 80007248 <etext+0x248>
    80001ed6:	8bffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001eda:	00005517          	auipc	a0,0x5
    80001ede:	37e50513          	addi	a0,a0,894 # 80007258 <etext+0x258>
    80001ee2:	8b3fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001ee6:	00005517          	auipc	a0,0x5
    80001eea:	38250513          	addi	a0,a0,898 # 80007268 <etext+0x268>
    80001eee:	8a7fe0ef          	jal	80000794 <panic>

0000000080001ef2 <yield>:
{
    80001ef2:	1101                	addi	sp,sp,-32
    80001ef4:	ec06                	sd	ra,24(sp)
    80001ef6:	e822                	sd	s0,16(sp)
    80001ef8:	e426                	sd	s1,8(sp)
    80001efa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001efc:	9e5ff0ef          	jal	800018e0 <myproc>
    80001f00:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f02:	cf3fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001f06:	478d                	li	a5,3
    80001f08:	cc9c                	sw	a5,24(s1)
  sched();
    80001f0a:	f2fff0ef          	jal	80001e38 <sched>
  release(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	d7dfe0ef          	jal	80000c8c <release>
}
    80001f14:	60e2                	ld	ra,24(sp)
    80001f16:	6442                	ld	s0,16(sp)
    80001f18:	64a2                	ld	s1,8(sp)
    80001f1a:	6105                	addi	sp,sp,32
    80001f1c:	8082                	ret

0000000080001f1e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f1e:	7179                	addi	sp,sp,-48
    80001f20:	f406                	sd	ra,40(sp)
    80001f22:	f022                	sd	s0,32(sp)
    80001f24:	ec26                	sd	s1,24(sp)
    80001f26:	e84a                	sd	s2,16(sp)
    80001f28:	e44e                	sd	s3,8(sp)
    80001f2a:	1800                	addi	s0,sp,48
    80001f2c:	89aa                	mv	s3,a0
    80001f2e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f30:	9b1ff0ef          	jal	800018e0 <myproc>
    80001f34:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f36:	cbffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001f3a:	854a                	mv	a0,s2
    80001f3c:	d51fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001f40:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f44:	4789                	li	a5,2
    80001f46:	cc9c                	sw	a5,24(s1)

  sched();
    80001f48:	ef1ff0ef          	jal	80001e38 <sched>

  // Tidy up.
  p->chan = 0;
    80001f4c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	d3bfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001f56:	854a                	mv	a0,s2
    80001f58:	c9dfe0ef          	jal	80000bf4 <acquire>
}
    80001f5c:	70a2                	ld	ra,40(sp)
    80001f5e:	7402                	ld	s0,32(sp)
    80001f60:	64e2                	ld	s1,24(sp)
    80001f62:	6942                	ld	s2,16(sp)
    80001f64:	69a2                	ld	s3,8(sp)
    80001f66:	6145                	addi	sp,sp,48
    80001f68:	8082                	ret

0000000080001f6a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f6a:	7139                	addi	sp,sp,-64
    80001f6c:	fc06                	sd	ra,56(sp)
    80001f6e:	f822                	sd	s0,48(sp)
    80001f70:	f426                	sd	s1,40(sp)
    80001f72:	f04a                	sd	s2,32(sp)
    80001f74:	ec4e                	sd	s3,24(sp)
    80001f76:	e852                	sd	s4,16(sp)
    80001f78:	e456                	sd	s5,8(sp)
    80001f7a:	0080                	addi	s0,sp,64
    80001f7c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f7e:	00011497          	auipc	s1,0x11
    80001f82:	88248493          	addi	s1,s1,-1918 # 80012800 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f86:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f88:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f8a:	00016917          	auipc	s2,0x16
    80001f8e:	47690913          	addi	s2,s2,1142 # 80018400 <pstat>
    80001f92:	a801                	j	80001fa2 <wakeup+0x38>
      }
      release(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	cf7fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f9a:	17048493          	addi	s1,s1,368
    80001f9e:	03248263          	beq	s1,s2,80001fc2 <wakeup+0x58>
    if(p != myproc()){
    80001fa2:	93fff0ef          	jal	800018e0 <myproc>
    80001fa6:	fea48ae3          	beq	s1,a0,80001f9a <wakeup+0x30>
      acquire(&p->lock);
    80001faa:	8526                	mv	a0,s1
    80001fac:	c49fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fb0:	4c9c                	lw	a5,24(s1)
    80001fb2:	ff3791e3          	bne	a5,s3,80001f94 <wakeup+0x2a>
    80001fb6:	709c                	ld	a5,32(s1)
    80001fb8:	fd479ee3          	bne	a5,s4,80001f94 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fbc:	0154ac23          	sw	s5,24(s1)
    80001fc0:	bfd1                	j	80001f94 <wakeup+0x2a>
    }
  }
}
    80001fc2:	70e2                	ld	ra,56(sp)
    80001fc4:	7442                	ld	s0,48(sp)
    80001fc6:	74a2                	ld	s1,40(sp)
    80001fc8:	7902                	ld	s2,32(sp)
    80001fca:	69e2                	ld	s3,24(sp)
    80001fcc:	6a42                	ld	s4,16(sp)
    80001fce:	6aa2                	ld	s5,8(sp)
    80001fd0:	6121                	addi	sp,sp,64
    80001fd2:	8082                	ret

0000000080001fd4 <reparent>:
{
    80001fd4:	7179                	addi	sp,sp,-48
    80001fd6:	f406                	sd	ra,40(sp)
    80001fd8:	f022                	sd	s0,32(sp)
    80001fda:	ec26                	sd	s1,24(sp)
    80001fdc:	e84a                	sd	s2,16(sp)
    80001fde:	e44e                	sd	s3,8(sp)
    80001fe0:	e052                	sd	s4,0(sp)
    80001fe2:	1800                	addi	s0,sp,48
    80001fe4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fe6:	00011497          	auipc	s1,0x11
    80001fea:	81a48493          	addi	s1,s1,-2022 # 80012800 <proc>
      pp->parent = initproc;
    80001fee:	00008a17          	auipc	s4,0x8
    80001ff2:	2aaa0a13          	addi	s4,s4,682 # 8000a298 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ff6:	00016997          	auipc	s3,0x16
    80001ffa:	40a98993          	addi	s3,s3,1034 # 80018400 <pstat>
    80001ffe:	a029                	j	80002008 <reparent+0x34>
    80002000:	17048493          	addi	s1,s1,368
    80002004:	01348b63          	beq	s1,s3,8000201a <reparent+0x46>
    if(pp->parent == p){
    80002008:	7c9c                	ld	a5,56(s1)
    8000200a:	ff279be3          	bne	a5,s2,80002000 <reparent+0x2c>
      pp->parent = initproc;
    8000200e:	000a3503          	ld	a0,0(s4)
    80002012:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002014:	f57ff0ef          	jal	80001f6a <wakeup>
    80002018:	b7e5                	j	80002000 <reparent+0x2c>
}
    8000201a:	70a2                	ld	ra,40(sp)
    8000201c:	7402                	ld	s0,32(sp)
    8000201e:	64e2                	ld	s1,24(sp)
    80002020:	6942                	ld	s2,16(sp)
    80002022:	69a2                	ld	s3,8(sp)
    80002024:	6a02                	ld	s4,0(sp)
    80002026:	6145                	addi	sp,sp,48
    80002028:	8082                	ret

000000008000202a <exit>:
{
    8000202a:	7179                	addi	sp,sp,-48
    8000202c:	f406                	sd	ra,40(sp)
    8000202e:	f022                	sd	s0,32(sp)
    80002030:	ec26                	sd	s1,24(sp)
    80002032:	e84a                	sd	s2,16(sp)
    80002034:	e44e                	sd	s3,8(sp)
    80002036:	e052                	sd	s4,0(sp)
    80002038:	1800                	addi	s0,sp,48
    8000203a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000203c:	8a5ff0ef          	jal	800018e0 <myproc>
    80002040:	89aa                	mv	s3,a0
  if(p == initproc)
    80002042:	00008797          	auipc	a5,0x8
    80002046:	2567b783          	ld	a5,598(a5) # 8000a298 <initproc>
    8000204a:	0d050493          	addi	s1,a0,208
    8000204e:	15050913          	addi	s2,a0,336
    80002052:	00a79f63          	bne	a5,a0,80002070 <exit+0x46>
    panic("init exiting");
    80002056:	00005517          	auipc	a0,0x5
    8000205a:	22a50513          	addi	a0,a0,554 # 80007280 <etext+0x280>
    8000205e:	f36fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002062:	73f010ef          	jal	80003fa0 <fileclose>
      p->ofile[fd] = 0;
    80002066:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000206a:	04a1                	addi	s1,s1,8
    8000206c:	01248563          	beq	s1,s2,80002076 <exit+0x4c>
    if(p->ofile[fd]){
    80002070:	6088                	ld	a0,0(s1)
    80002072:	f965                	bnez	a0,80002062 <exit+0x38>
    80002074:	bfdd                	j	8000206a <exit+0x40>
  begin_op();
    80002076:	311010ef          	jal	80003b86 <begin_op>
  iput(p->cwd);
    8000207a:	1509b503          	ld	a0,336(s3)
    8000207e:	3f4010ef          	jal	80003472 <iput>
  end_op();
    80002082:	36f010ef          	jal	80003bf0 <end_op>
  p->cwd = 0;
    80002086:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000208a:	00010497          	auipc	s1,0x10
    8000208e:	35e48493          	addi	s1,s1,862 # 800123e8 <wait_lock>
    80002092:	8526                	mv	a0,s1
    80002094:	b61fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002098:	854e                	mv	a0,s3
    8000209a:	f3bff0ef          	jal	80001fd4 <reparent>
  wakeup(p->parent);
    8000209e:	0389b503          	ld	a0,56(s3)
    800020a2:	ec9ff0ef          	jal	80001f6a <wakeup>
  acquire(&p->lock);
    800020a6:	854e                	mv	a0,s3
    800020a8:	b4dfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800020ac:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020b0:	4795                	li	a5,5
    800020b2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020b6:	8526                	mv	a0,s1
    800020b8:	bd5fe0ef          	jal	80000c8c <release>
  sched();
    800020bc:	d7dff0ef          	jal	80001e38 <sched>
  panic("zombie exit");
    800020c0:	00005517          	auipc	a0,0x5
    800020c4:	1d050513          	addi	a0,a0,464 # 80007290 <etext+0x290>
    800020c8:	eccfe0ef          	jal	80000794 <panic>

00000000800020cc <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020cc:	7179                	addi	sp,sp,-48
    800020ce:	f406                	sd	ra,40(sp)
    800020d0:	f022                	sd	s0,32(sp)
    800020d2:	ec26                	sd	s1,24(sp)
    800020d4:	e84a                	sd	s2,16(sp)
    800020d6:	e44e                	sd	s3,8(sp)
    800020d8:	1800                	addi	s0,sp,48
    800020da:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020dc:	00010497          	auipc	s1,0x10
    800020e0:	72448493          	addi	s1,s1,1828 # 80012800 <proc>
    800020e4:	00016997          	auipc	s3,0x16
    800020e8:	31c98993          	addi	s3,s3,796 # 80018400 <pstat>
    acquire(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	b07fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800020f2:	589c                	lw	a5,48(s1)
    800020f4:	01278b63          	beq	a5,s2,8000210a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	b93fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020fe:	17048493          	addi	s1,s1,368
    80002102:	ff3495e3          	bne	s1,s3,800020ec <kill+0x20>
  }
  return -1;
    80002106:	557d                	li	a0,-1
    80002108:	a819                	j	8000211e <kill+0x52>
      p->killed = 1;
    8000210a:	4785                	li	a5,1
    8000210c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000210e:	4c98                	lw	a4,24(s1)
    80002110:	4789                	li	a5,2
    80002112:	00f70d63          	beq	a4,a5,8000212c <kill+0x60>
      release(&p->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	b75fe0ef          	jal	80000c8c <release>
      return 0;
    8000211c:	4501                	li	a0,0
}
    8000211e:	70a2                	ld	ra,40(sp)
    80002120:	7402                	ld	s0,32(sp)
    80002122:	64e2                	ld	s1,24(sp)
    80002124:	6942                	ld	s2,16(sp)
    80002126:	69a2                	ld	s3,8(sp)
    80002128:	6145                	addi	sp,sp,48
    8000212a:	8082                	ret
        p->state = RUNNABLE;
    8000212c:	478d                	li	a5,3
    8000212e:	cc9c                	sw	a5,24(s1)
    80002130:	b7dd                	j	80002116 <kill+0x4a>

0000000080002132 <setkilled>:

void
setkilled(struct proc *p)
{
    80002132:	1101                	addi	sp,sp,-32
    80002134:	ec06                	sd	ra,24(sp)
    80002136:	e822                	sd	s0,16(sp)
    80002138:	e426                	sd	s1,8(sp)
    8000213a:	1000                	addi	s0,sp,32
    8000213c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000213e:	ab7fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80002142:	4785                	li	a5,1
    80002144:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	b45fe0ef          	jal	80000c8c <release>
}
    8000214c:	60e2                	ld	ra,24(sp)
    8000214e:	6442                	ld	s0,16(sp)
    80002150:	64a2                	ld	s1,8(sp)
    80002152:	6105                	addi	sp,sp,32
    80002154:	8082                	ret

0000000080002156 <killed>:

int
killed(struct proc *p)
{
    80002156:	1101                	addi	sp,sp,-32
    80002158:	ec06                	sd	ra,24(sp)
    8000215a:	e822                	sd	s0,16(sp)
    8000215c:	e426                	sd	s1,8(sp)
    8000215e:	e04a                	sd	s2,0(sp)
    80002160:	1000                	addi	s0,sp,32
    80002162:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002164:	a91fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002168:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	b1ffe0ef          	jal	80000c8c <release>
  return k;
}
    80002172:	854a                	mv	a0,s2
    80002174:	60e2                	ld	ra,24(sp)
    80002176:	6442                	ld	s0,16(sp)
    80002178:	64a2                	ld	s1,8(sp)
    8000217a:	6902                	ld	s2,0(sp)
    8000217c:	6105                	addi	sp,sp,32
    8000217e:	8082                	ret

0000000080002180 <wait>:
{
    80002180:	715d                	addi	sp,sp,-80
    80002182:	e486                	sd	ra,72(sp)
    80002184:	e0a2                	sd	s0,64(sp)
    80002186:	fc26                	sd	s1,56(sp)
    80002188:	f84a                	sd	s2,48(sp)
    8000218a:	f44e                	sd	s3,40(sp)
    8000218c:	f052                	sd	s4,32(sp)
    8000218e:	ec56                	sd	s5,24(sp)
    80002190:	e85a                	sd	s6,16(sp)
    80002192:	e45e                	sd	s7,8(sp)
    80002194:	e062                	sd	s8,0(sp)
    80002196:	0880                	addi	s0,sp,80
    80002198:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000219a:	f46ff0ef          	jal	800018e0 <myproc>
    8000219e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021a0:	00010517          	auipc	a0,0x10
    800021a4:	24850513          	addi	a0,a0,584 # 800123e8 <wait_lock>
    800021a8:	a4dfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800021ac:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800021ae:	4a15                	li	s4,5
        havekids = 1;
    800021b0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b2:	00016997          	auipc	s3,0x16
    800021b6:	24e98993          	addi	s3,s3,590 # 80018400 <pstat>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021ba:	00010c17          	auipc	s8,0x10
    800021be:	22ec0c13          	addi	s8,s8,558 # 800123e8 <wait_lock>
    800021c2:	a871                	j	8000225e <wait+0xde>
          pid = pp->pid;
    800021c4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021c8:	000b0c63          	beqz	s6,800021e0 <wait+0x60>
    800021cc:	4691                	li	a3,4
    800021ce:	02c48613          	addi	a2,s1,44
    800021d2:	85da                	mv	a1,s6
    800021d4:	05093503          	ld	a0,80(s2)
    800021d8:	b7aff0ef          	jal	80001552 <copyout>
    800021dc:	02054b63          	bltz	a0,80002212 <wait+0x92>
          freeproc(pp);
    800021e0:	8526                	mv	a0,s1
    800021e2:	871ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	aa5fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800021ec:	00010517          	auipc	a0,0x10
    800021f0:	1fc50513          	addi	a0,a0,508 # 800123e8 <wait_lock>
    800021f4:	a99fe0ef          	jal	80000c8c <release>
}
    800021f8:	854e                	mv	a0,s3
    800021fa:	60a6                	ld	ra,72(sp)
    800021fc:	6406                	ld	s0,64(sp)
    800021fe:	74e2                	ld	s1,56(sp)
    80002200:	7942                	ld	s2,48(sp)
    80002202:	79a2                	ld	s3,40(sp)
    80002204:	7a02                	ld	s4,32(sp)
    80002206:	6ae2                	ld	s5,24(sp)
    80002208:	6b42                	ld	s6,16(sp)
    8000220a:	6ba2                	ld	s7,8(sp)
    8000220c:	6c02                	ld	s8,0(sp)
    8000220e:	6161                	addi	sp,sp,80
    80002210:	8082                	ret
            release(&pp->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	a79fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002218:	00010517          	auipc	a0,0x10
    8000221c:	1d050513          	addi	a0,a0,464 # 800123e8 <wait_lock>
    80002220:	a6dfe0ef          	jal	80000c8c <release>
            return -1;
    80002224:	59fd                	li	s3,-1
    80002226:	bfc9                	j	800021f8 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002228:	17048493          	addi	s1,s1,368
    8000222c:	03348063          	beq	s1,s3,8000224c <wait+0xcc>
      if(pp->parent == p){
    80002230:	7c9c                	ld	a5,56(s1)
    80002232:	ff279be3          	bne	a5,s2,80002228 <wait+0xa8>
        acquire(&pp->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	9bdfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    8000223c:	4c9c                	lw	a5,24(s1)
    8000223e:	f94783e3          	beq	a5,s4,800021c4 <wait+0x44>
        release(&pp->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	a49fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002248:	8756                	mv	a4,s5
    8000224a:	bff9                	j	80002228 <wait+0xa8>
    if(!havekids || killed(p)){
    8000224c:	cf19                	beqz	a4,8000226a <wait+0xea>
    8000224e:	854a                	mv	a0,s2
    80002250:	f07ff0ef          	jal	80002156 <killed>
    80002254:	e919                	bnez	a0,8000226a <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002256:	85e2                	mv	a1,s8
    80002258:	854a                	mv	a0,s2
    8000225a:	cc5ff0ef          	jal	80001f1e <sleep>
    havekids = 0;
    8000225e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002260:	00010497          	auipc	s1,0x10
    80002264:	5a048493          	addi	s1,s1,1440 # 80012800 <proc>
    80002268:	b7e1                	j	80002230 <wait+0xb0>
      release(&wait_lock);
    8000226a:	00010517          	auipc	a0,0x10
    8000226e:	17e50513          	addi	a0,a0,382 # 800123e8 <wait_lock>
    80002272:	a1bfe0ef          	jal	80000c8c <release>
      return -1;
    80002276:	59fd                	li	s3,-1
    80002278:	b741                	j	800021f8 <wait+0x78>

000000008000227a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000227a:	7179                	addi	sp,sp,-48
    8000227c:	f406                	sd	ra,40(sp)
    8000227e:	f022                	sd	s0,32(sp)
    80002280:	ec26                	sd	s1,24(sp)
    80002282:	e84a                	sd	s2,16(sp)
    80002284:	e44e                	sd	s3,8(sp)
    80002286:	e052                	sd	s4,0(sp)
    80002288:	1800                	addi	s0,sp,48
    8000228a:	84aa                	mv	s1,a0
    8000228c:	892e                	mv	s2,a1
    8000228e:	89b2                	mv	s3,a2
    80002290:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002292:	e4eff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    80002296:	cc99                	beqz	s1,800022b4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002298:	86d2                	mv	a3,s4
    8000229a:	864e                	mv	a2,s3
    8000229c:	85ca                	mv	a1,s2
    8000229e:	6928                	ld	a0,80(a0)
    800022a0:	ab2ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022a4:	70a2                	ld	ra,40(sp)
    800022a6:	7402                	ld	s0,32(sp)
    800022a8:	64e2                	ld	s1,24(sp)
    800022aa:	6942                	ld	s2,16(sp)
    800022ac:	69a2                	ld	s3,8(sp)
    800022ae:	6a02                	ld	s4,0(sp)
    800022b0:	6145                	addi	sp,sp,48
    800022b2:	8082                	ret
    memmove((char *)dst, src, len);
    800022b4:	000a061b          	sext.w	a2,s4
    800022b8:	85ce                	mv	a1,s3
    800022ba:	854a                	mv	a0,s2
    800022bc:	a69fe0ef          	jal	80000d24 <memmove>
    return 0;
    800022c0:	8526                	mv	a0,s1
    800022c2:	b7cd                	j	800022a4 <either_copyout+0x2a>

00000000800022c4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022c4:	7179                	addi	sp,sp,-48
    800022c6:	f406                	sd	ra,40(sp)
    800022c8:	f022                	sd	s0,32(sp)
    800022ca:	ec26                	sd	s1,24(sp)
    800022cc:	e84a                	sd	s2,16(sp)
    800022ce:	e44e                	sd	s3,8(sp)
    800022d0:	e052                	sd	s4,0(sp)
    800022d2:	1800                	addi	s0,sp,48
    800022d4:	892a                	mv	s2,a0
    800022d6:	84ae                	mv	s1,a1
    800022d8:	89b2                	mv	s3,a2
    800022da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022dc:	e04ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    800022e0:	cc99                	beqz	s1,800022fe <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022e2:	86d2                	mv	a3,s4
    800022e4:	864e                	mv	a2,s3
    800022e6:	85ca                	mv	a1,s2
    800022e8:	6928                	ld	a0,80(a0)
    800022ea:	b3eff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022ee:	70a2                	ld	ra,40(sp)
    800022f0:	7402                	ld	s0,32(sp)
    800022f2:	64e2                	ld	s1,24(sp)
    800022f4:	6942                	ld	s2,16(sp)
    800022f6:	69a2                	ld	s3,8(sp)
    800022f8:	6a02                	ld	s4,0(sp)
    800022fa:	6145                	addi	sp,sp,48
    800022fc:	8082                	ret
    memmove(dst, (char*)src, len);
    800022fe:	000a061b          	sext.w	a2,s4
    80002302:	85ce                	mv	a1,s3
    80002304:	854a                	mv	a0,s2
    80002306:	a1ffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000230a:	8526                	mv	a0,s1
    8000230c:	b7cd                	j	800022ee <either_copyin+0x2a>

000000008000230e <getpinfo>:

// -- DEISO --
int
getpinfo(struct pstat *addr) 
{
    8000230e:	1141                	addi	sp,sp,-16
    80002310:	e422                	sd	s0,8(sp)
    80002312:	0800                	addi	s0,sp,16
  for(int i = 0; i < NPROC; i++){
    80002314:	00010797          	auipc	a5,0x10
    80002318:	50478793          	addi	a5,a5,1284 # 80012818 <proc+0x18>
    8000231c:	00016697          	auipc	a3,0x16
    80002320:	0fc68693          	addi	a3,a3,252 # 80018418 <pstat+0x18>
    addr->inuse[i] = (proc[i].state != UNUSED);
    80002324:	4398                	lw	a4,0(a5)
    80002326:	00e03733          	snez	a4,a4
    8000232a:	c118                	sw	a4,0(a0)
    addr->pid[i] = proc[i].pid;
    8000232c:	4f98                	lw	a4,24(a5)
    8000232e:	20e52023          	sw	a4,512(a0)
    addr->tickets[i] = proc[i].tickets;
    80002332:	1507a703          	lw	a4,336(a5)
    80002336:	10e52023          	sw	a4,256(a0)
    addr->ticks[i] = proc[i].ticks;
    8000233a:	1547a703          	lw	a4,340(a5)
    8000233e:	30e52023          	sw	a4,768(a0)
  for(int i = 0; i < NPROC; i++){
    80002342:	17078793          	addi	a5,a5,368
    80002346:	0511                	addi	a0,a0,4
    80002348:	fcd79ee3          	bne	a5,a3,80002324 <getpinfo+0x16>
  } 

  return 0;
}
    8000234c:	4501                	li	a0,0
    8000234e:	6422                	ld	s0,8(sp)
    80002350:	0141                	addi	sp,sp,16
    80002352:	8082                	ret

0000000080002354 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002354:	715d                	addi	sp,sp,-80
    80002356:	e486                	sd	ra,72(sp)
    80002358:	e0a2                	sd	s0,64(sp)
    8000235a:	fc26                	sd	s1,56(sp)
    8000235c:	f84a                	sd	s2,48(sp)
    8000235e:	f44e                	sd	s3,40(sp)
    80002360:	f052                	sd	s4,32(sp)
    80002362:	ec56                	sd	s5,24(sp)
    80002364:	e85a                	sd	s6,16(sp)
    80002366:	e45e                	sd	s7,8(sp)
    80002368:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000236a:	00005517          	auipc	a0,0x5
    8000236e:	d0e50513          	addi	a0,a0,-754 # 80007078 <etext+0x78>
    80002372:	950fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002376:	00010497          	auipc	s1,0x10
    8000237a:	5e248493          	addi	s1,s1,1506 # 80012958 <proc+0x158>
    8000237e:	00016917          	auipc	s2,0x16
    80002382:	1da90913          	addi	s2,s2,474 # 80018558 <pstat+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002386:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002388:	00005997          	auipc	s3,0x5
    8000238c:	f1898993          	addi	s3,s3,-232 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002390:	00005a97          	auipc	s5,0x5
    80002394:	f18a8a93          	addi	s5,s5,-232 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002398:	00005a17          	auipc	s4,0x5
    8000239c:	ce0a0a13          	addi	s4,s4,-800 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023a0:	00005b97          	auipc	s7,0x5
    800023a4:	3e8b8b93          	addi	s7,s7,1000 # 80007788 <states.0>
    800023a8:	a829                	j	800023c2 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023aa:	ed86a583          	lw	a1,-296(a3)
    800023ae:	8556                	mv	a0,s5
    800023b0:	912fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800023b4:	8552                	mv	a0,s4
    800023b6:	90cfe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023ba:	17048493          	addi	s1,s1,368
    800023be:	03248263          	beq	s1,s2,800023e2 <procdump+0x8e>
    if(p->state == UNUSED)
    800023c2:	86a6                	mv	a3,s1
    800023c4:	ec04a783          	lw	a5,-320(s1)
    800023c8:	dbed                	beqz	a5,800023ba <procdump+0x66>
      state = "???";
    800023ca:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023cc:	fcfb6fe3          	bltu	s6,a5,800023aa <procdump+0x56>
    800023d0:	02079713          	slli	a4,a5,0x20
    800023d4:	01d75793          	srli	a5,a4,0x1d
    800023d8:	97de                	add	a5,a5,s7
    800023da:	6390                	ld	a2,0(a5)
    800023dc:	f679                	bnez	a2,800023aa <procdump+0x56>
      state = "???";
    800023de:	864e                	mv	a2,s3
    800023e0:	b7e9                	j	800023aa <procdump+0x56>
  }
}
    800023e2:	60a6                	ld	ra,72(sp)
    800023e4:	6406                	ld	s0,64(sp)
    800023e6:	74e2                	ld	s1,56(sp)
    800023e8:	7942                	ld	s2,48(sp)
    800023ea:	79a2                	ld	s3,40(sp)
    800023ec:	7a02                	ld	s4,32(sp)
    800023ee:	6ae2                	ld	s5,24(sp)
    800023f0:	6b42                	ld	s6,16(sp)
    800023f2:	6ba2                	ld	s7,8(sp)
    800023f4:	6161                	addi	sp,sp,80
    800023f6:	8082                	ret

00000000800023f8 <swtch>:
    800023f8:	00153023          	sd	ra,0(a0)
    800023fc:	00253423          	sd	sp,8(a0)
    80002400:	e900                	sd	s0,16(a0)
    80002402:	ed04                	sd	s1,24(a0)
    80002404:	03253023          	sd	s2,32(a0)
    80002408:	03353423          	sd	s3,40(a0)
    8000240c:	03453823          	sd	s4,48(a0)
    80002410:	03553c23          	sd	s5,56(a0)
    80002414:	05653023          	sd	s6,64(a0)
    80002418:	05753423          	sd	s7,72(a0)
    8000241c:	05853823          	sd	s8,80(a0)
    80002420:	05953c23          	sd	s9,88(a0)
    80002424:	07a53023          	sd	s10,96(a0)
    80002428:	07b53423          	sd	s11,104(a0)
    8000242c:	0005b083          	ld	ra,0(a1)
    80002430:	0085b103          	ld	sp,8(a1)
    80002434:	6980                	ld	s0,16(a1)
    80002436:	6d84                	ld	s1,24(a1)
    80002438:	0205b903          	ld	s2,32(a1)
    8000243c:	0285b983          	ld	s3,40(a1)
    80002440:	0305ba03          	ld	s4,48(a1)
    80002444:	0385ba83          	ld	s5,56(a1)
    80002448:	0405bb03          	ld	s6,64(a1)
    8000244c:	0485bb83          	ld	s7,72(a1)
    80002450:	0505bc03          	ld	s8,80(a1)
    80002454:	0585bc83          	ld	s9,88(a1)
    80002458:	0605bd03          	ld	s10,96(a1)
    8000245c:	0685bd83          	ld	s11,104(a1)
    80002460:	8082                	ret

0000000080002462 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002462:	1141                	addi	sp,sp,-16
    80002464:	e406                	sd	ra,8(sp)
    80002466:	e022                	sd	s0,0(sp)
    80002468:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000246a:	00005597          	auipc	a1,0x5
    8000246e:	e7e58593          	addi	a1,a1,-386 # 800072e8 <etext+0x2e8>
    80002472:	00016517          	auipc	a0,0x16
    80002476:	38e50513          	addi	a0,a0,910 # 80018800 <tickslock>
    8000247a:	efafe0ef          	jal	80000b74 <initlock>
}
    8000247e:	60a2                	ld	ra,8(sp)
    80002480:	6402                	ld	s0,0(sp)
    80002482:	0141                	addi	sp,sp,16
    80002484:	8082                	ret

0000000080002486 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002486:	1141                	addi	sp,sp,-16
    80002488:	e422                	sd	s0,8(sp)
    8000248a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000248c:	00003797          	auipc	a5,0x3
    80002490:	e8478793          	addi	a5,a5,-380 # 80005310 <kernelvec>
    80002494:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002498:	6422                	ld	s0,8(sp)
    8000249a:	0141                	addi	sp,sp,16
    8000249c:	8082                	ret

000000008000249e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000249e:	1141                	addi	sp,sp,-16
    800024a0:	e406                	sd	ra,8(sp)
    800024a2:	e022                	sd	s0,0(sp)
    800024a4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024a6:	c3aff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024aa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024ae:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024b0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024b4:	00004697          	auipc	a3,0x4
    800024b8:	b4c68693          	addi	a3,a3,-1204 # 80006000 <_trampoline>
    800024bc:	00004717          	auipc	a4,0x4
    800024c0:	b4470713          	addi	a4,a4,-1212 # 80006000 <_trampoline>
    800024c4:	8f15                	sub	a4,a4,a3
    800024c6:	040007b7          	lui	a5,0x4000
    800024ca:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800024cc:	07b2                	slli	a5,a5,0xc
    800024ce:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024d0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024d4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024d6:	18002673          	csrr	a2,satp
    800024da:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024dc:	6d30                	ld	a2,88(a0)
    800024de:	6138                	ld	a4,64(a0)
    800024e0:	6585                	lui	a1,0x1
    800024e2:	972e                	add	a4,a4,a1
    800024e4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024e6:	6d38                	ld	a4,88(a0)
    800024e8:	00000617          	auipc	a2,0x0
    800024ec:	11060613          	addi	a2,a2,272 # 800025f8 <usertrap>
    800024f0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024f2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024f4:	8612                	mv	a2,tp
    800024f6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024fc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002500:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002504:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002508:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000250a:	6f18                	ld	a4,24(a4)
    8000250c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002510:	6928                	ld	a0,80(a0)
    80002512:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002514:	00004717          	auipc	a4,0x4
    80002518:	b8870713          	addi	a4,a4,-1144 # 8000609c <userret>
    8000251c:	8f15                	sub	a4,a4,a3
    8000251e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002520:	577d                	li	a4,-1
    80002522:	177e                	slli	a4,a4,0x3f
    80002524:	8d59                	or	a0,a0,a4
    80002526:	9782                	jalr	a5
}
    80002528:	60a2                	ld	ra,8(sp)
    8000252a:	6402                	ld	s0,0(sp)
    8000252c:	0141                	addi	sp,sp,16
    8000252e:	8082                	ret

0000000080002530 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002530:	1101                	addi	sp,sp,-32
    80002532:	ec06                	sd	ra,24(sp)
    80002534:	e822                	sd	s0,16(sp)
    80002536:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002538:	b7cff0ef          	jal	800018b4 <cpuid>
    8000253c:	cd11                	beqz	a0,80002558 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000253e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002542:	000f4737          	lui	a4,0xf4
    80002546:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000254a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000254c:	14d79073          	csrw	stimecmp,a5
}
    80002550:	60e2                	ld	ra,24(sp)
    80002552:	6442                	ld	s0,16(sp)
    80002554:	6105                	addi	sp,sp,32
    80002556:	8082                	ret
    80002558:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000255a:	00016497          	auipc	s1,0x16
    8000255e:	2a648493          	addi	s1,s1,678 # 80018800 <tickslock>
    80002562:	8526                	mv	a0,s1
    80002564:	e90fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002568:	00008517          	auipc	a0,0x8
    8000256c:	d3850513          	addi	a0,a0,-712 # 8000a2a0 <ticks>
    80002570:	411c                	lw	a5,0(a0)
    80002572:	2785                	addiw	a5,a5,1
    80002574:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002576:	9f5ff0ef          	jal	80001f6a <wakeup>
    release(&tickslock);
    8000257a:	8526                	mv	a0,s1
    8000257c:	f10fe0ef          	jal	80000c8c <release>
    80002580:	64a2                	ld	s1,8(sp)
    80002582:	bf75                	j	8000253e <clockintr+0xe>

0000000080002584 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002584:	1101                	addi	sp,sp,-32
    80002586:	ec06                	sd	ra,24(sp)
    80002588:	e822                	sd	s0,16(sp)
    8000258a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000258c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002590:	57fd                	li	a5,-1
    80002592:	17fe                	slli	a5,a5,0x3f
    80002594:	07a5                	addi	a5,a5,9
    80002596:	00f70c63          	beq	a4,a5,800025ae <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000259a:	57fd                	li	a5,-1
    8000259c:	17fe                	slli	a5,a5,0x3f
    8000259e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025a0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025a2:	04f70763          	beq	a4,a5,800025f0 <devintr+0x6c>
  }
}
    800025a6:	60e2                	ld	ra,24(sp)
    800025a8:	6442                	ld	s0,16(sp)
    800025aa:	6105                	addi	sp,sp,32
    800025ac:	8082                	ret
    800025ae:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025b0:	60d020ef          	jal	800053bc <plic_claim>
    800025b4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025b6:	47a9                	li	a5,10
    800025b8:	00f50963          	beq	a0,a5,800025ca <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800025bc:	4785                	li	a5,1
    800025be:	00f50963          	beq	a0,a5,800025d0 <devintr+0x4c>
    return 1;
    800025c2:	4505                	li	a0,1
    } else if(irq){
    800025c4:	e889                	bnez	s1,800025d6 <devintr+0x52>
    800025c6:	64a2                	ld	s1,8(sp)
    800025c8:	bff9                	j	800025a6 <devintr+0x22>
      uartintr();
    800025ca:	c3cfe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800025ce:	a819                	j	800025e4 <devintr+0x60>
      virtio_disk_intr();
    800025d0:	2b2030ef          	jal	80005882 <virtio_disk_intr>
    if(irq)
    800025d4:	a801                	j	800025e4 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800025d6:	85a6                	mv	a1,s1
    800025d8:	00005517          	auipc	a0,0x5
    800025dc:	d1850513          	addi	a0,a0,-744 # 800072f0 <etext+0x2f0>
    800025e0:	ee3fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800025e4:	8526                	mv	a0,s1
    800025e6:	5f7020ef          	jal	800053dc <plic_complete>
    return 1;
    800025ea:	4505                	li	a0,1
    800025ec:	64a2                	ld	s1,8(sp)
    800025ee:	bf65                	j	800025a6 <devintr+0x22>
    clockintr();
    800025f0:	f41ff0ef          	jal	80002530 <clockintr>
    return 2;
    800025f4:	4509                	li	a0,2
    800025f6:	bf45                	j	800025a6 <devintr+0x22>

00000000800025f8 <usertrap>:
{
    800025f8:	1101                	addi	sp,sp,-32
    800025fa:	ec06                	sd	ra,24(sp)
    800025fc:	e822                	sd	s0,16(sp)
    800025fe:	e426                	sd	s1,8(sp)
    80002600:	e04a                	sd	s2,0(sp)
    80002602:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002604:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002608:	1007f793          	andi	a5,a5,256
    8000260c:	ef85                	bnez	a5,80002644 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000260e:	00003797          	auipc	a5,0x3
    80002612:	d0278793          	addi	a5,a5,-766 # 80005310 <kernelvec>
    80002616:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000261a:	ac6ff0ef          	jal	800018e0 <myproc>
    8000261e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002620:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002622:	14102773          	csrr	a4,sepc
    80002626:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002628:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000262c:	47a1                	li	a5,8
    8000262e:	02f70163          	beq	a4,a5,80002650 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002632:	f53ff0ef          	jal	80002584 <devintr>
    80002636:	892a                	mv	s2,a0
    80002638:	c135                	beqz	a0,8000269c <usertrap+0xa4>
  if(killed(p))
    8000263a:	8526                	mv	a0,s1
    8000263c:	b1bff0ef          	jal	80002156 <killed>
    80002640:	cd1d                	beqz	a0,8000267e <usertrap+0x86>
    80002642:	a81d                	j	80002678 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002644:	00005517          	auipc	a0,0x5
    80002648:	ccc50513          	addi	a0,a0,-820 # 80007310 <etext+0x310>
    8000264c:	948fe0ef          	jal	80000794 <panic>
    if(killed(p))
    80002650:	b07ff0ef          	jal	80002156 <killed>
    80002654:	e121                	bnez	a0,80002694 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002656:	6cb8                	ld	a4,88(s1)
    80002658:	6f1c                	ld	a5,24(a4)
    8000265a:	0791                	addi	a5,a5,4
    8000265c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000265e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002662:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002666:	10079073          	csrw	sstatus,a5
    syscall();
    8000266a:	248000ef          	jal	800028b2 <syscall>
  if(killed(p))
    8000266e:	8526                	mv	a0,s1
    80002670:	ae7ff0ef          	jal	80002156 <killed>
    80002674:	c901                	beqz	a0,80002684 <usertrap+0x8c>
    80002676:	4901                	li	s2,0
    exit(-1);
    80002678:	557d                	li	a0,-1
    8000267a:	9b1ff0ef          	jal	8000202a <exit>
  if(which_dev == 2)
    8000267e:	4789                	li	a5,2
    80002680:	04f90563          	beq	s2,a5,800026ca <usertrap+0xd2>
  usertrapret();
    80002684:	e1bff0ef          	jal	8000249e <usertrapret>
}
    80002688:	60e2                	ld	ra,24(sp)
    8000268a:	6442                	ld	s0,16(sp)
    8000268c:	64a2                	ld	s1,8(sp)
    8000268e:	6902                	ld	s2,0(sp)
    80002690:	6105                	addi	sp,sp,32
    80002692:	8082                	ret
      exit(-1);
    80002694:	557d                	li	a0,-1
    80002696:	995ff0ef          	jal	8000202a <exit>
    8000269a:	bf75                	j	80002656 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000269c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026a0:	5890                	lw	a2,48(s1)
    800026a2:	00005517          	auipc	a0,0x5
    800026a6:	c8e50513          	addi	a0,a0,-882 # 80007330 <etext+0x330>
    800026aa:	e19fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026b2:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026b6:	00005517          	auipc	a0,0x5
    800026ba:	caa50513          	addi	a0,a0,-854 # 80007360 <etext+0x360>
    800026be:	e05fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    800026c2:	8526                	mv	a0,s1
    800026c4:	a6fff0ef          	jal	80002132 <setkilled>
    800026c8:	b75d                	j	8000266e <usertrap+0x76>
    yield();
    800026ca:	829ff0ef          	jal	80001ef2 <yield>
    800026ce:	bf5d                	j	80002684 <usertrap+0x8c>

00000000800026d0 <kerneltrap>:
{
    800026d0:	7179                	addi	sp,sp,-48
    800026d2:	f406                	sd	ra,40(sp)
    800026d4:	f022                	sd	s0,32(sp)
    800026d6:	ec26                	sd	s1,24(sp)
    800026d8:	e84a                	sd	s2,16(sp)
    800026da:	e44e                	sd	s3,8(sp)
    800026dc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026de:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026e6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026ea:	1004f793          	andi	a5,s1,256
    800026ee:	c795                	beqz	a5,8000271a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026f4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026f6:	eb85                	bnez	a5,80002726 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026f8:	e8dff0ef          	jal	80002584 <devintr>
    800026fc:	c91d                	beqz	a0,80002732 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026fe:	4789                	li	a5,2
    80002700:	04f50a63          	beq	a0,a5,80002754 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002704:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002708:	10049073          	csrw	sstatus,s1
}
    8000270c:	70a2                	ld	ra,40(sp)
    8000270e:	7402                	ld	s0,32(sp)
    80002710:	64e2                	ld	s1,24(sp)
    80002712:	6942                	ld	s2,16(sp)
    80002714:	69a2                	ld	s3,8(sp)
    80002716:	6145                	addi	sp,sp,48
    80002718:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000271a:	00005517          	auipc	a0,0x5
    8000271e:	c6e50513          	addi	a0,a0,-914 # 80007388 <etext+0x388>
    80002722:	872fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002726:	00005517          	auipc	a0,0x5
    8000272a:	c8a50513          	addi	a0,a0,-886 # 800073b0 <etext+0x3b0>
    8000272e:	866fe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002732:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002736:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000273a:	85ce                	mv	a1,s3
    8000273c:	00005517          	auipc	a0,0x5
    80002740:	c9450513          	addi	a0,a0,-876 # 800073d0 <etext+0x3d0>
    80002744:	d7ffd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002748:	00005517          	auipc	a0,0x5
    8000274c:	cb050513          	addi	a0,a0,-848 # 800073f8 <etext+0x3f8>
    80002750:	844fe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002754:	98cff0ef          	jal	800018e0 <myproc>
    80002758:	d555                	beqz	a0,80002704 <kerneltrap+0x34>
    yield();
    8000275a:	f98ff0ef          	jal	80001ef2 <yield>
    8000275e:	b75d                	j	80002704 <kerneltrap+0x34>

0000000080002760 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002760:	1101                	addi	sp,sp,-32
    80002762:	ec06                	sd	ra,24(sp)
    80002764:	e822                	sd	s0,16(sp)
    80002766:	e426                	sd	s1,8(sp)
    80002768:	1000                	addi	s0,sp,32
    8000276a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000276c:	974ff0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002770:	4795                	li	a5,5
    80002772:	0497e163          	bltu	a5,s1,800027b4 <argraw+0x54>
    80002776:	048a                	slli	s1,s1,0x2
    80002778:	00005717          	auipc	a4,0x5
    8000277c:	04070713          	addi	a4,a4,64 # 800077b8 <states.0+0x30>
    80002780:	94ba                	add	s1,s1,a4
    80002782:	409c                	lw	a5,0(s1)
    80002784:	97ba                	add	a5,a5,a4
    80002786:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002788:	6d3c                	ld	a5,88(a0)
    8000278a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000278c:	60e2                	ld	ra,24(sp)
    8000278e:	6442                	ld	s0,16(sp)
    80002790:	64a2                	ld	s1,8(sp)
    80002792:	6105                	addi	sp,sp,32
    80002794:	8082                	ret
    return p->trapframe->a1;
    80002796:	6d3c                	ld	a5,88(a0)
    80002798:	7fa8                	ld	a0,120(a5)
    8000279a:	bfcd                	j	8000278c <argraw+0x2c>
    return p->trapframe->a2;
    8000279c:	6d3c                	ld	a5,88(a0)
    8000279e:	63c8                	ld	a0,128(a5)
    800027a0:	b7f5                	j	8000278c <argraw+0x2c>
    return p->trapframe->a3;
    800027a2:	6d3c                	ld	a5,88(a0)
    800027a4:	67c8                	ld	a0,136(a5)
    800027a6:	b7dd                	j	8000278c <argraw+0x2c>
    return p->trapframe->a4;
    800027a8:	6d3c                	ld	a5,88(a0)
    800027aa:	6bc8                	ld	a0,144(a5)
    800027ac:	b7c5                	j	8000278c <argraw+0x2c>
    return p->trapframe->a5;
    800027ae:	6d3c                	ld	a5,88(a0)
    800027b0:	6fc8                	ld	a0,152(a5)
    800027b2:	bfe9                	j	8000278c <argraw+0x2c>
  panic("argraw");
    800027b4:	00005517          	auipc	a0,0x5
    800027b8:	c5450513          	addi	a0,a0,-940 # 80007408 <etext+0x408>
    800027bc:	fd9fd0ef          	jal	80000794 <panic>

00000000800027c0 <fetchaddr>:
{
    800027c0:	1101                	addi	sp,sp,-32
    800027c2:	ec06                	sd	ra,24(sp)
    800027c4:	e822                	sd	s0,16(sp)
    800027c6:	e426                	sd	s1,8(sp)
    800027c8:	e04a                	sd	s2,0(sp)
    800027ca:	1000                	addi	s0,sp,32
    800027cc:	84aa                	mv	s1,a0
    800027ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027d0:	910ff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027d4:	653c                	ld	a5,72(a0)
    800027d6:	02f4f663          	bgeu	s1,a5,80002802 <fetchaddr+0x42>
    800027da:	00848713          	addi	a4,s1,8
    800027de:	02e7e463          	bltu	a5,a4,80002806 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027e2:	46a1                	li	a3,8
    800027e4:	8626                	mv	a2,s1
    800027e6:	85ca                	mv	a1,s2
    800027e8:	6928                	ld	a0,80(a0)
    800027ea:	e3ffe0ef          	jal	80001628 <copyin>
    800027ee:	00a03533          	snez	a0,a0
    800027f2:	40a00533          	neg	a0,a0
}
    800027f6:	60e2                	ld	ra,24(sp)
    800027f8:	6442                	ld	s0,16(sp)
    800027fa:	64a2                	ld	s1,8(sp)
    800027fc:	6902                	ld	s2,0(sp)
    800027fe:	6105                	addi	sp,sp,32
    80002800:	8082                	ret
    return -1;
    80002802:	557d                	li	a0,-1
    80002804:	bfcd                	j	800027f6 <fetchaddr+0x36>
    80002806:	557d                	li	a0,-1
    80002808:	b7fd                	j	800027f6 <fetchaddr+0x36>

000000008000280a <fetchstr>:
{
    8000280a:	7179                	addi	sp,sp,-48
    8000280c:	f406                	sd	ra,40(sp)
    8000280e:	f022                	sd	s0,32(sp)
    80002810:	ec26                	sd	s1,24(sp)
    80002812:	e84a                	sd	s2,16(sp)
    80002814:	e44e                	sd	s3,8(sp)
    80002816:	1800                	addi	s0,sp,48
    80002818:	892a                	mv	s2,a0
    8000281a:	84ae                	mv	s1,a1
    8000281c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000281e:	8c2ff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002822:	86ce                	mv	a3,s3
    80002824:	864a                	mv	a2,s2
    80002826:	85a6                	mv	a1,s1
    80002828:	6928                	ld	a0,80(a0)
    8000282a:	e85fe0ef          	jal	800016ae <copyinstr>
    8000282e:	00054c63          	bltz	a0,80002846 <fetchstr+0x3c>
  return strlen(buf);
    80002832:	8526                	mv	a0,s1
    80002834:	e04fe0ef          	jal	80000e38 <strlen>
}
    80002838:	70a2                	ld	ra,40(sp)
    8000283a:	7402                	ld	s0,32(sp)
    8000283c:	64e2                	ld	s1,24(sp)
    8000283e:	6942                	ld	s2,16(sp)
    80002840:	69a2                	ld	s3,8(sp)
    80002842:	6145                	addi	sp,sp,48
    80002844:	8082                	ret
    return -1;
    80002846:	557d                	li	a0,-1
    80002848:	bfc5                	j	80002838 <fetchstr+0x2e>

000000008000284a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000284a:	1101                	addi	sp,sp,-32
    8000284c:	ec06                	sd	ra,24(sp)
    8000284e:	e822                	sd	s0,16(sp)
    80002850:	e426                	sd	s1,8(sp)
    80002852:	1000                	addi	s0,sp,32
    80002854:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002856:	f0bff0ef          	jal	80002760 <argraw>
    8000285a:	c088                	sw	a0,0(s1)
}
    8000285c:	60e2                	ld	ra,24(sp)
    8000285e:	6442                	ld	s0,16(sp)
    80002860:	64a2                	ld	s1,8(sp)
    80002862:	6105                	addi	sp,sp,32
    80002864:	8082                	ret

0000000080002866 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002866:	1101                	addi	sp,sp,-32
    80002868:	ec06                	sd	ra,24(sp)
    8000286a:	e822                	sd	s0,16(sp)
    8000286c:	e426                	sd	s1,8(sp)
    8000286e:	1000                	addi	s0,sp,32
    80002870:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002872:	eefff0ef          	jal	80002760 <argraw>
    80002876:	e088                	sd	a0,0(s1)
}
    80002878:	60e2                	ld	ra,24(sp)
    8000287a:	6442                	ld	s0,16(sp)
    8000287c:	64a2                	ld	s1,8(sp)
    8000287e:	6105                	addi	sp,sp,32
    80002880:	8082                	ret

0000000080002882 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002882:	7179                	addi	sp,sp,-48
    80002884:	f406                	sd	ra,40(sp)
    80002886:	f022                	sd	s0,32(sp)
    80002888:	ec26                	sd	s1,24(sp)
    8000288a:	e84a                	sd	s2,16(sp)
    8000288c:	1800                	addi	s0,sp,48
    8000288e:	84ae                	mv	s1,a1
    80002890:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002892:	fd840593          	addi	a1,s0,-40
    80002896:	fd1ff0ef          	jal	80002866 <argaddr>
  return fetchstr(addr, buf, max);
    8000289a:	864a                	mv	a2,s2
    8000289c:	85a6                	mv	a1,s1
    8000289e:	fd843503          	ld	a0,-40(s0)
    800028a2:	f69ff0ef          	jal	8000280a <fetchstr>
}
    800028a6:	70a2                	ld	ra,40(sp)
    800028a8:	7402                	ld	s0,32(sp)
    800028aa:	64e2                	ld	s1,24(sp)
    800028ac:	6942                	ld	s2,16(sp)
    800028ae:	6145                	addi	sp,sp,48
    800028b0:	8082                	ret

00000000800028b2 <syscall>:
[SYS_getpinfo] sys_getpinfo,
};

void
syscall(void)
{
    800028b2:	1101                	addi	sp,sp,-32
    800028b4:	ec06                	sd	ra,24(sp)
    800028b6:	e822                	sd	s0,16(sp)
    800028b8:	e426                	sd	s1,8(sp)
    800028ba:	e04a                	sd	s2,0(sp)
    800028bc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028be:	822ff0ef          	jal	800018e0 <myproc>
    800028c2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028c4:	05853903          	ld	s2,88(a0)
    800028c8:	0a893783          	ld	a5,168(s2)
    800028cc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028d0:	37fd                	addiw	a5,a5,-1
    800028d2:	4759                	li	a4,22
    800028d4:	00f76f63          	bltu	a4,a5,800028f2 <syscall+0x40>
    800028d8:	00369713          	slli	a4,a3,0x3
    800028dc:	00005797          	auipc	a5,0x5
    800028e0:	ef478793          	addi	a5,a5,-268 # 800077d0 <syscalls>
    800028e4:	97ba                	add	a5,a5,a4
    800028e6:	639c                	ld	a5,0(a5)
    800028e8:	c789                	beqz	a5,800028f2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028ea:	9782                	jalr	a5
    800028ec:	06a93823          	sd	a0,112(s2)
    800028f0:	a829                	j	8000290a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028f2:	15848613          	addi	a2,s1,344
    800028f6:	588c                	lw	a1,48(s1)
    800028f8:	00005517          	auipc	a0,0x5
    800028fc:	b1850513          	addi	a0,a0,-1256 # 80007410 <etext+0x410>
    80002900:	bc3fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002904:	6cbc                	ld	a5,88(s1)
    80002906:	577d                	li	a4,-1
    80002908:	fbb8                	sd	a4,112(a5)
  }
}
    8000290a:	60e2                	ld	ra,24(sp)
    8000290c:	6442                	ld	s0,16(sp)
    8000290e:	64a2                	ld	s1,8(sp)
    80002910:	6902                	ld	s2,0(sp)
    80002912:	6105                	addi	sp,sp,32
    80002914:	8082                	ret

0000000080002916 <sys_exit>:
// -- DEISO --
#include "pstat.h"

uint64
sys_exit(void)
{
    80002916:	1101                	addi	sp,sp,-32
    80002918:	ec06                	sd	ra,24(sp)
    8000291a:	e822                	sd	s0,16(sp)
    8000291c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000291e:	fec40593          	addi	a1,s0,-20
    80002922:	4501                	li	a0,0
    80002924:	f27ff0ef          	jal	8000284a <argint>
  exit(n);
    80002928:	fec42503          	lw	a0,-20(s0)
    8000292c:	efeff0ef          	jal	8000202a <exit>
  return 0;  // not reached
}
    80002930:	4501                	li	a0,0
    80002932:	60e2                	ld	ra,24(sp)
    80002934:	6442                	ld	s0,16(sp)
    80002936:	6105                	addi	sp,sp,32
    80002938:	8082                	ret

000000008000293a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000293a:	1141                	addi	sp,sp,-16
    8000293c:	e406                	sd	ra,8(sp)
    8000293e:	e022                	sd	s0,0(sp)
    80002940:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002942:	f9ffe0ef          	jal	800018e0 <myproc>
}
    80002946:	5908                	lw	a0,48(a0)
    80002948:	60a2                	ld	ra,8(sp)
    8000294a:	6402                	ld	s0,0(sp)
    8000294c:	0141                	addi	sp,sp,16
    8000294e:	8082                	ret

0000000080002950 <sys_fork>:

uint64
sys_fork(void)
{
    80002950:	1141                	addi	sp,sp,-16
    80002952:	e406                	sd	ra,8(sp)
    80002954:	e022                	sd	s0,0(sp)
    80002956:	0800                	addi	s0,sp,16
  return fork();
    80002958:	abcff0ef          	jal	80001c14 <fork>
}
    8000295c:	60a2                	ld	ra,8(sp)
    8000295e:	6402                	ld	s0,0(sp)
    80002960:	0141                	addi	sp,sp,16
    80002962:	8082                	ret

0000000080002964 <sys_wait>:

uint64
sys_wait(void)
{
    80002964:	1101                	addi	sp,sp,-32
    80002966:	ec06                	sd	ra,24(sp)
    80002968:	e822                	sd	s0,16(sp)
    8000296a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000296c:	fe840593          	addi	a1,s0,-24
    80002970:	4501                	li	a0,0
    80002972:	ef5ff0ef          	jal	80002866 <argaddr>
  return wait(p);
    80002976:	fe843503          	ld	a0,-24(s0)
    8000297a:	807ff0ef          	jal	80002180 <wait>
}
    8000297e:	60e2                	ld	ra,24(sp)
    80002980:	6442                	ld	s0,16(sp)
    80002982:	6105                	addi	sp,sp,32
    80002984:	8082                	ret

0000000080002986 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002986:	7179                	addi	sp,sp,-48
    80002988:	f406                	sd	ra,40(sp)
    8000298a:	f022                	sd	s0,32(sp)
    8000298c:	ec26                	sd	s1,24(sp)
    8000298e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002990:	fdc40593          	addi	a1,s0,-36
    80002994:	4501                	li	a0,0
    80002996:	eb5ff0ef          	jal	8000284a <argint>
  addr = myproc()->sz;
    8000299a:	f47fe0ef          	jal	800018e0 <myproc>
    8000299e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800029a0:	fdc42503          	lw	a0,-36(s0)
    800029a4:	a20ff0ef          	jal	80001bc4 <growproc>
    800029a8:	00054863          	bltz	a0,800029b8 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800029ac:	8526                	mv	a0,s1
    800029ae:	70a2                	ld	ra,40(sp)
    800029b0:	7402                	ld	s0,32(sp)
    800029b2:	64e2                	ld	s1,24(sp)
    800029b4:	6145                	addi	sp,sp,48
    800029b6:	8082                	ret
    return -1;
    800029b8:	54fd                	li	s1,-1
    800029ba:	bfcd                	j	800029ac <sys_sbrk+0x26>

00000000800029bc <sys_sleep>:

uint64
sys_sleep(void)
{
    800029bc:	7139                	addi	sp,sp,-64
    800029be:	fc06                	sd	ra,56(sp)
    800029c0:	f822                	sd	s0,48(sp)
    800029c2:	f04a                	sd	s2,32(sp)
    800029c4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029c6:	fcc40593          	addi	a1,s0,-52
    800029ca:	4501                	li	a0,0
    800029cc:	e7fff0ef          	jal	8000284a <argint>
  if(n < 0)
    800029d0:	fcc42783          	lw	a5,-52(s0)
    800029d4:	0607c763          	bltz	a5,80002a42 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800029d8:	00016517          	auipc	a0,0x16
    800029dc:	e2850513          	addi	a0,a0,-472 # 80018800 <tickslock>
    800029e0:	a14fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    800029e4:	00008917          	auipc	s2,0x8
    800029e8:	8bc92903          	lw	s2,-1860(s2) # 8000a2a0 <ticks>
  while(ticks - ticks0 < n){
    800029ec:	fcc42783          	lw	a5,-52(s0)
    800029f0:	cf8d                	beqz	a5,80002a2a <sys_sleep+0x6e>
    800029f2:	f426                	sd	s1,40(sp)
    800029f4:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029f6:	00016997          	auipc	s3,0x16
    800029fa:	e0a98993          	addi	s3,s3,-502 # 80018800 <tickslock>
    800029fe:	00008497          	auipc	s1,0x8
    80002a02:	8a248493          	addi	s1,s1,-1886 # 8000a2a0 <ticks>
    if(killed(myproc())){
    80002a06:	edbfe0ef          	jal	800018e0 <myproc>
    80002a0a:	f4cff0ef          	jal	80002156 <killed>
    80002a0e:	ed0d                	bnez	a0,80002a48 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002a10:	85ce                	mv	a1,s3
    80002a12:	8526                	mv	a0,s1
    80002a14:	d0aff0ef          	jal	80001f1e <sleep>
  while(ticks - ticks0 < n){
    80002a18:	409c                	lw	a5,0(s1)
    80002a1a:	412787bb          	subw	a5,a5,s2
    80002a1e:	fcc42703          	lw	a4,-52(s0)
    80002a22:	fee7e2e3          	bltu	a5,a4,80002a06 <sys_sleep+0x4a>
    80002a26:	74a2                	ld	s1,40(sp)
    80002a28:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a2a:	00016517          	auipc	a0,0x16
    80002a2e:	dd650513          	addi	a0,a0,-554 # 80018800 <tickslock>
    80002a32:	a5afe0ef          	jal	80000c8c <release>
  return 0;
    80002a36:	4501                	li	a0,0
}
    80002a38:	70e2                	ld	ra,56(sp)
    80002a3a:	7442                	ld	s0,48(sp)
    80002a3c:	7902                	ld	s2,32(sp)
    80002a3e:	6121                	addi	sp,sp,64
    80002a40:	8082                	ret
    n = 0;
    80002a42:	fc042623          	sw	zero,-52(s0)
    80002a46:	bf49                	j	800029d8 <sys_sleep+0x1c>
      release(&tickslock);
    80002a48:	00016517          	auipc	a0,0x16
    80002a4c:	db850513          	addi	a0,a0,-584 # 80018800 <tickslock>
    80002a50:	a3cfe0ef          	jal	80000c8c <release>
      return -1;
    80002a54:	557d                	li	a0,-1
    80002a56:	74a2                	ld	s1,40(sp)
    80002a58:	69e2                	ld	s3,24(sp)
    80002a5a:	bff9                	j	80002a38 <sys_sleep+0x7c>

0000000080002a5c <sys_kill>:

uint64
sys_kill(void)
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a64:	fec40593          	addi	a1,s0,-20
    80002a68:	4501                	li	a0,0
    80002a6a:	de1ff0ef          	jal	8000284a <argint>
  return kill(pid);
    80002a6e:	fec42503          	lw	a0,-20(s0)
    80002a72:	e5aff0ef          	jal	800020cc <kill>
}
    80002a76:	60e2                	ld	ra,24(sp)
    80002a78:	6442                	ld	s0,16(sp)
    80002a7a:	6105                	addi	sp,sp,32
    80002a7c:	8082                	ret

0000000080002a7e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a88:	00016517          	auipc	a0,0x16
    80002a8c:	d7850513          	addi	a0,a0,-648 # 80018800 <tickslock>
    80002a90:	964fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002a94:	00008497          	auipc	s1,0x8
    80002a98:	80c4a483          	lw	s1,-2036(s1) # 8000a2a0 <ticks>
  release(&tickslock);
    80002a9c:	00016517          	auipc	a0,0x16
    80002aa0:	d6450513          	addi	a0,a0,-668 # 80018800 <tickslock>
    80002aa4:	9e8fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002aa8:	02049513          	slli	a0,s1,0x20
    80002aac:	9101                	srli	a0,a0,0x20
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	64a2                	ld	s1,8(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret

0000000080002ab8 <sys_settickets>:

// -- DEISO --

uint64
sys_settickets(void)
{
    80002ab8:	1101                	addi	sp,sp,-32
    80002aba:	ec06                	sd	ra,24(sp)
    80002abc:	e822                	sd	s0,16(sp)
    80002abe:	1000                	addi	s0,sp,32
  int tickets;
  argint(0, &tickets);
    80002ac0:	fec40593          	addi	a1,s0,-20
    80002ac4:	4501                	li	a0,0
    80002ac6:	d85ff0ef          	jal	8000284a <argint>

  if (tickets < 1)
    80002aca:	fec42783          	lw	a5,-20(s0)
    return -1;
    80002ace:	557d                	li	a0,-1
  if (tickets < 1)
    80002ad0:	00f05963          	blez	a5,80002ae2 <sys_settickets+0x2a>
  myproc()->tickets = tickets;
    80002ad4:	e0dfe0ef          	jal	800018e0 <myproc>
    80002ad8:	fec42783          	lw	a5,-20(s0)
    80002adc:	16f52423          	sw	a5,360(a0)
  return 0;
    80002ae0:	4501                	li	a0,0
}
    80002ae2:	60e2                	ld	ra,24(sp)
    80002ae4:	6442                	ld	s0,16(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret

0000000080002aea <sys_getpinfo>:

uint64 
sys_getpinfo(void)
{
    80002aea:	be010113          	addi	sp,sp,-1056
    80002aee:	40113c23          	sd	ra,1048(sp)
    80002af2:	40813823          	sd	s0,1040(sp)
    80002af6:	42010413          	addi	s0,sp,1056
  struct pstat pstat; //En kernel
  uint64 upstat; //Dirección del pstat que se ha pasado. En usuario
  argaddr(0, &upstat); 
    80002afa:	be840593          	addi	a1,s0,-1048
    80002afe:	4501                	li	a0,0
    80002b00:	d67ff0ef          	jal	80002866 <argaddr>
  if (&upstat <= 0)
    return -1;

  getpinfo(&pstat); //Se ha rellenado pstat con los datos en el kernel
    80002b04:	bf040513          	addi	a0,s0,-1040
    80002b08:	807ff0ef          	jal	8000230e <getpinfo>

  if(copyout(myproc()->pagetable, upstat, (char *)&pstat,sizeof(pstat)) < 0) // Copiamos la pstat desde el kernel al espacio de usuario
    80002b0c:	dd5fe0ef          	jal	800018e0 <myproc>
    80002b10:	40000693          	li	a3,1024
    80002b14:	bf040613          	addi	a2,s0,-1040
    80002b18:	be843583          	ld	a1,-1048(s0)
    80002b1c:	6928                	ld	a0,80(a0)
    80002b1e:	a35fe0ef          	jal	80001552 <copyout>
      return -1;

  return 0;
    80002b22:	957d                	srai	a0,a0,0x3f
    80002b24:	41813083          	ld	ra,1048(sp)
    80002b28:	41013403          	ld	s0,1040(sp)
    80002b2c:	42010113          	addi	sp,sp,1056
    80002b30:	8082                	ret

0000000080002b32 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b32:	7179                	addi	sp,sp,-48
    80002b34:	f406                	sd	ra,40(sp)
    80002b36:	f022                	sd	s0,32(sp)
    80002b38:	ec26                	sd	s1,24(sp)
    80002b3a:	e84a                	sd	s2,16(sp)
    80002b3c:	e44e                	sd	s3,8(sp)
    80002b3e:	e052                	sd	s4,0(sp)
    80002b40:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b42:	00005597          	auipc	a1,0x5
    80002b46:	8ee58593          	addi	a1,a1,-1810 # 80007430 <etext+0x430>
    80002b4a:	00016517          	auipc	a0,0x16
    80002b4e:	cce50513          	addi	a0,a0,-818 # 80018818 <bcache>
    80002b52:	822fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b56:	0001e797          	auipc	a5,0x1e
    80002b5a:	cc278793          	addi	a5,a5,-830 # 80020818 <bcache+0x8000>
    80002b5e:	0001e717          	auipc	a4,0x1e
    80002b62:	f2270713          	addi	a4,a4,-222 # 80020a80 <bcache+0x8268>
    80002b66:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b6a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b6e:	00016497          	auipc	s1,0x16
    80002b72:	cc248493          	addi	s1,s1,-830 # 80018830 <bcache+0x18>
    b->next = bcache.head.next;
    80002b76:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b78:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b7a:	00005a17          	auipc	s4,0x5
    80002b7e:	8bea0a13          	addi	s4,s4,-1858 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002b82:	2b893783          	ld	a5,696(s2)
    80002b86:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b88:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b8c:	85d2                	mv	a1,s4
    80002b8e:	01048513          	addi	a0,s1,16
    80002b92:	248010ef          	jal	80003dda <initsleeplock>
    bcache.head.next->prev = b;
    80002b96:	2b893783          	ld	a5,696(s2)
    80002b9a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b9c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ba0:	45848493          	addi	s1,s1,1112
    80002ba4:	fd349fe3          	bne	s1,s3,80002b82 <binit+0x50>
  }
}
    80002ba8:	70a2                	ld	ra,40(sp)
    80002baa:	7402                	ld	s0,32(sp)
    80002bac:	64e2                	ld	s1,24(sp)
    80002bae:	6942                	ld	s2,16(sp)
    80002bb0:	69a2                	ld	s3,8(sp)
    80002bb2:	6a02                	ld	s4,0(sp)
    80002bb4:	6145                	addi	sp,sp,48
    80002bb6:	8082                	ret

0000000080002bb8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bb8:	7179                	addi	sp,sp,-48
    80002bba:	f406                	sd	ra,40(sp)
    80002bbc:	f022                	sd	s0,32(sp)
    80002bbe:	ec26                	sd	s1,24(sp)
    80002bc0:	e84a                	sd	s2,16(sp)
    80002bc2:	e44e                	sd	s3,8(sp)
    80002bc4:	1800                	addi	s0,sp,48
    80002bc6:	892a                	mv	s2,a0
    80002bc8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bca:	00016517          	auipc	a0,0x16
    80002bce:	c4e50513          	addi	a0,a0,-946 # 80018818 <bcache>
    80002bd2:	822fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bd6:	0001e497          	auipc	s1,0x1e
    80002bda:	efa4b483          	ld	s1,-262(s1) # 80020ad0 <bcache+0x82b8>
    80002bde:	0001e797          	auipc	a5,0x1e
    80002be2:	ea278793          	addi	a5,a5,-350 # 80020a80 <bcache+0x8268>
    80002be6:	02f48b63          	beq	s1,a5,80002c1c <bread+0x64>
    80002bea:	873e                	mv	a4,a5
    80002bec:	a021                	j	80002bf4 <bread+0x3c>
    80002bee:	68a4                	ld	s1,80(s1)
    80002bf0:	02e48663          	beq	s1,a4,80002c1c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002bf4:	449c                	lw	a5,8(s1)
    80002bf6:	ff279ce3          	bne	a5,s2,80002bee <bread+0x36>
    80002bfa:	44dc                	lw	a5,12(s1)
    80002bfc:	ff3799e3          	bne	a5,s3,80002bee <bread+0x36>
      b->refcnt++;
    80002c00:	40bc                	lw	a5,64(s1)
    80002c02:	2785                	addiw	a5,a5,1
    80002c04:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c06:	00016517          	auipc	a0,0x16
    80002c0a:	c1250513          	addi	a0,a0,-1006 # 80018818 <bcache>
    80002c0e:	87efe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c12:	01048513          	addi	a0,s1,16
    80002c16:	1fa010ef          	jal	80003e10 <acquiresleep>
      return b;
    80002c1a:	a889                	j	80002c6c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c1c:	0001e497          	auipc	s1,0x1e
    80002c20:	eac4b483          	ld	s1,-340(s1) # 80020ac8 <bcache+0x82b0>
    80002c24:	0001e797          	auipc	a5,0x1e
    80002c28:	e5c78793          	addi	a5,a5,-420 # 80020a80 <bcache+0x8268>
    80002c2c:	00f48863          	beq	s1,a5,80002c3c <bread+0x84>
    80002c30:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c32:	40bc                	lw	a5,64(s1)
    80002c34:	cb91                	beqz	a5,80002c48 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c36:	64a4                	ld	s1,72(s1)
    80002c38:	fee49de3          	bne	s1,a4,80002c32 <bread+0x7a>
  panic("bget: no buffers");
    80002c3c:	00005517          	auipc	a0,0x5
    80002c40:	80450513          	addi	a0,a0,-2044 # 80007440 <etext+0x440>
    80002c44:	b51fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002c48:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c4c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c50:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c54:	4785                	li	a5,1
    80002c56:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c58:	00016517          	auipc	a0,0x16
    80002c5c:	bc050513          	addi	a0,a0,-1088 # 80018818 <bcache>
    80002c60:	82cfe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c64:	01048513          	addi	a0,s1,16
    80002c68:	1a8010ef          	jal	80003e10 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c6c:	409c                	lw	a5,0(s1)
    80002c6e:	cb89                	beqz	a5,80002c80 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c70:	8526                	mv	a0,s1
    80002c72:	70a2                	ld	ra,40(sp)
    80002c74:	7402                	ld	s0,32(sp)
    80002c76:	64e2                	ld	s1,24(sp)
    80002c78:	6942                	ld	s2,16(sp)
    80002c7a:	69a2                	ld	s3,8(sp)
    80002c7c:	6145                	addi	sp,sp,48
    80002c7e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c80:	4581                	li	a1,0
    80002c82:	8526                	mv	a0,s1
    80002c84:	1ed020ef          	jal	80005670 <virtio_disk_rw>
    b->valid = 1;
    80002c88:	4785                	li	a5,1
    80002c8a:	c09c                	sw	a5,0(s1)
  return b;
    80002c8c:	b7d5                	j	80002c70 <bread+0xb8>

0000000080002c8e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	1000                	addi	s0,sp,32
    80002c98:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c9a:	0541                	addi	a0,a0,16
    80002c9c:	1f2010ef          	jal	80003e8e <holdingsleep>
    80002ca0:	c911                	beqz	a0,80002cb4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ca2:	4585                	li	a1,1
    80002ca4:	8526                	mv	a0,s1
    80002ca6:	1cb020ef          	jal	80005670 <virtio_disk_rw>
}
    80002caa:	60e2                	ld	ra,24(sp)
    80002cac:	6442                	ld	s0,16(sp)
    80002cae:	64a2                	ld	s1,8(sp)
    80002cb0:	6105                	addi	sp,sp,32
    80002cb2:	8082                	ret
    panic("bwrite");
    80002cb4:	00004517          	auipc	a0,0x4
    80002cb8:	7a450513          	addi	a0,a0,1956 # 80007458 <etext+0x458>
    80002cbc:	ad9fd0ef          	jal	80000794 <panic>

0000000080002cc0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	e04a                	sd	s2,0(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cce:	01050913          	addi	s2,a0,16
    80002cd2:	854a                	mv	a0,s2
    80002cd4:	1ba010ef          	jal	80003e8e <holdingsleep>
    80002cd8:	c135                	beqz	a0,80002d3c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002cda:	854a                	mv	a0,s2
    80002cdc:	17a010ef          	jal	80003e56 <releasesleep>

  acquire(&bcache.lock);
    80002ce0:	00016517          	auipc	a0,0x16
    80002ce4:	b3850513          	addi	a0,a0,-1224 # 80018818 <bcache>
    80002ce8:	f0dfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002cec:	40bc                	lw	a5,64(s1)
    80002cee:	37fd                	addiw	a5,a5,-1
    80002cf0:	0007871b          	sext.w	a4,a5
    80002cf4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cf6:	e71d                	bnez	a4,80002d24 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cf8:	68b8                	ld	a4,80(s1)
    80002cfa:	64bc                	ld	a5,72(s1)
    80002cfc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cfe:	68b8                	ld	a4,80(s1)
    80002d00:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d02:	0001e797          	auipc	a5,0x1e
    80002d06:	b1678793          	addi	a5,a5,-1258 # 80020818 <bcache+0x8000>
    80002d0a:	2b87b703          	ld	a4,696(a5)
    80002d0e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d10:	0001e717          	auipc	a4,0x1e
    80002d14:	d7070713          	addi	a4,a4,-656 # 80020a80 <bcache+0x8268>
    80002d18:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d1a:	2b87b703          	ld	a4,696(a5)
    80002d1e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d20:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d24:	00016517          	auipc	a0,0x16
    80002d28:	af450513          	addi	a0,a0,-1292 # 80018818 <bcache>
    80002d2c:	f61fd0ef          	jal	80000c8c <release>
}
    80002d30:	60e2                	ld	ra,24(sp)
    80002d32:	6442                	ld	s0,16(sp)
    80002d34:	64a2                	ld	s1,8(sp)
    80002d36:	6902                	ld	s2,0(sp)
    80002d38:	6105                	addi	sp,sp,32
    80002d3a:	8082                	ret
    panic("brelse");
    80002d3c:	00004517          	auipc	a0,0x4
    80002d40:	72450513          	addi	a0,a0,1828 # 80007460 <etext+0x460>
    80002d44:	a51fd0ef          	jal	80000794 <panic>

0000000080002d48 <bpin>:

void
bpin(struct buf *b) {
    80002d48:	1101                	addi	sp,sp,-32
    80002d4a:	ec06                	sd	ra,24(sp)
    80002d4c:	e822                	sd	s0,16(sp)
    80002d4e:	e426                	sd	s1,8(sp)
    80002d50:	1000                	addi	s0,sp,32
    80002d52:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d54:	00016517          	auipc	a0,0x16
    80002d58:	ac450513          	addi	a0,a0,-1340 # 80018818 <bcache>
    80002d5c:	e99fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002d60:	40bc                	lw	a5,64(s1)
    80002d62:	2785                	addiw	a5,a5,1
    80002d64:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d66:	00016517          	auipc	a0,0x16
    80002d6a:	ab250513          	addi	a0,a0,-1358 # 80018818 <bcache>
    80002d6e:	f1ffd0ef          	jal	80000c8c <release>
}
    80002d72:	60e2                	ld	ra,24(sp)
    80002d74:	6442                	ld	s0,16(sp)
    80002d76:	64a2                	ld	s1,8(sp)
    80002d78:	6105                	addi	sp,sp,32
    80002d7a:	8082                	ret

0000000080002d7c <bunpin>:

void
bunpin(struct buf *b) {
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d88:	00016517          	auipc	a0,0x16
    80002d8c:	a9050513          	addi	a0,a0,-1392 # 80018818 <bcache>
    80002d90:	e65fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002d94:	40bc                	lw	a5,64(s1)
    80002d96:	37fd                	addiw	a5,a5,-1
    80002d98:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d9a:	00016517          	auipc	a0,0x16
    80002d9e:	a7e50513          	addi	a0,a0,-1410 # 80018818 <bcache>
    80002da2:	eebfd0ef          	jal	80000c8c <release>
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	e04a                	sd	s2,0(sp)
    80002dba:	1000                	addi	s0,sp,32
    80002dbc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002dbe:	00d5d59b          	srliw	a1,a1,0xd
    80002dc2:	0001e797          	auipc	a5,0x1e
    80002dc6:	1327a783          	lw	a5,306(a5) # 80020ef4 <sb+0x1c>
    80002dca:	9dbd                	addw	a1,a1,a5
    80002dcc:	dedff0ef          	jal	80002bb8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002dd0:	0074f713          	andi	a4,s1,7
    80002dd4:	4785                	li	a5,1
    80002dd6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002dda:	14ce                	slli	s1,s1,0x33
    80002ddc:	90d9                	srli	s1,s1,0x36
    80002dde:	00950733          	add	a4,a0,s1
    80002de2:	05874703          	lbu	a4,88(a4)
    80002de6:	00e7f6b3          	and	a3,a5,a4
    80002dea:	c29d                	beqz	a3,80002e10 <bfree+0x60>
    80002dec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002dee:	94aa                	add	s1,s1,a0
    80002df0:	fff7c793          	not	a5,a5
    80002df4:	8f7d                	and	a4,a4,a5
    80002df6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002dfa:	711000ef          	jal	80003d0a <log_write>
  brelse(bp);
    80002dfe:	854a                	mv	a0,s2
    80002e00:	ec1ff0ef          	jal	80002cc0 <brelse>
}
    80002e04:	60e2                	ld	ra,24(sp)
    80002e06:	6442                	ld	s0,16(sp)
    80002e08:	64a2                	ld	s1,8(sp)
    80002e0a:	6902                	ld	s2,0(sp)
    80002e0c:	6105                	addi	sp,sp,32
    80002e0e:	8082                	ret
    panic("freeing free block");
    80002e10:	00004517          	auipc	a0,0x4
    80002e14:	65850513          	addi	a0,a0,1624 # 80007468 <etext+0x468>
    80002e18:	97dfd0ef          	jal	80000794 <panic>

0000000080002e1c <balloc>:
{
    80002e1c:	711d                	addi	sp,sp,-96
    80002e1e:	ec86                	sd	ra,88(sp)
    80002e20:	e8a2                	sd	s0,80(sp)
    80002e22:	e4a6                	sd	s1,72(sp)
    80002e24:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e26:	0001e797          	auipc	a5,0x1e
    80002e2a:	0b67a783          	lw	a5,182(a5) # 80020edc <sb+0x4>
    80002e2e:	0e078f63          	beqz	a5,80002f2c <balloc+0x110>
    80002e32:	e0ca                	sd	s2,64(sp)
    80002e34:	fc4e                	sd	s3,56(sp)
    80002e36:	f852                	sd	s4,48(sp)
    80002e38:	f456                	sd	s5,40(sp)
    80002e3a:	f05a                	sd	s6,32(sp)
    80002e3c:	ec5e                	sd	s7,24(sp)
    80002e3e:	e862                	sd	s8,16(sp)
    80002e40:	e466                	sd	s9,8(sp)
    80002e42:	8baa                	mv	s7,a0
    80002e44:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e46:	0001eb17          	auipc	s6,0x1e
    80002e4a:	092b0b13          	addi	s6,s6,146 # 80020ed8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e4e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e50:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e52:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e54:	6c89                	lui	s9,0x2
    80002e56:	a0b5                	j	80002ec2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e58:	97ca                	add	a5,a5,s2
    80002e5a:	8e55                	or	a2,a2,a3
    80002e5c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e60:	854a                	mv	a0,s2
    80002e62:	6a9000ef          	jal	80003d0a <log_write>
        brelse(bp);
    80002e66:	854a                	mv	a0,s2
    80002e68:	e59ff0ef          	jal	80002cc0 <brelse>
  bp = bread(dev, bno);
    80002e6c:	85a6                	mv	a1,s1
    80002e6e:	855e                	mv	a0,s7
    80002e70:	d49ff0ef          	jal	80002bb8 <bread>
    80002e74:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e76:	40000613          	li	a2,1024
    80002e7a:	4581                	li	a1,0
    80002e7c:	05850513          	addi	a0,a0,88
    80002e80:	e49fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002e84:	854a                	mv	a0,s2
    80002e86:	685000ef          	jal	80003d0a <log_write>
  brelse(bp);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	e35ff0ef          	jal	80002cc0 <brelse>
}
    80002e90:	6906                	ld	s2,64(sp)
    80002e92:	79e2                	ld	s3,56(sp)
    80002e94:	7a42                	ld	s4,48(sp)
    80002e96:	7aa2                	ld	s5,40(sp)
    80002e98:	7b02                	ld	s6,32(sp)
    80002e9a:	6be2                	ld	s7,24(sp)
    80002e9c:	6c42                	ld	s8,16(sp)
    80002e9e:	6ca2                	ld	s9,8(sp)
}
    80002ea0:	8526                	mv	a0,s1
    80002ea2:	60e6                	ld	ra,88(sp)
    80002ea4:	6446                	ld	s0,80(sp)
    80002ea6:	64a6                	ld	s1,72(sp)
    80002ea8:	6125                	addi	sp,sp,96
    80002eaa:	8082                	ret
    brelse(bp);
    80002eac:	854a                	mv	a0,s2
    80002eae:	e13ff0ef          	jal	80002cc0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002eb2:	015c87bb          	addw	a5,s9,s5
    80002eb6:	00078a9b          	sext.w	s5,a5
    80002eba:	004b2703          	lw	a4,4(s6)
    80002ebe:	04eaff63          	bgeu	s5,a4,80002f1c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002ec2:	41fad79b          	sraiw	a5,s5,0x1f
    80002ec6:	0137d79b          	srliw	a5,a5,0x13
    80002eca:	015787bb          	addw	a5,a5,s5
    80002ece:	40d7d79b          	sraiw	a5,a5,0xd
    80002ed2:	01cb2583          	lw	a1,28(s6)
    80002ed6:	9dbd                	addw	a1,a1,a5
    80002ed8:	855e                	mv	a0,s7
    80002eda:	cdfff0ef          	jal	80002bb8 <bread>
    80002ede:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ee0:	004b2503          	lw	a0,4(s6)
    80002ee4:	000a849b          	sext.w	s1,s5
    80002ee8:	8762                	mv	a4,s8
    80002eea:	fca4f1e3          	bgeu	s1,a0,80002eac <balloc+0x90>
      m = 1 << (bi % 8);
    80002eee:	00777693          	andi	a3,a4,7
    80002ef2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ef6:	41f7579b          	sraiw	a5,a4,0x1f
    80002efa:	01d7d79b          	srliw	a5,a5,0x1d
    80002efe:	9fb9                	addw	a5,a5,a4
    80002f00:	4037d79b          	sraiw	a5,a5,0x3
    80002f04:	00f90633          	add	a2,s2,a5
    80002f08:	05864603          	lbu	a2,88(a2)
    80002f0c:	00c6f5b3          	and	a1,a3,a2
    80002f10:	d5a1                	beqz	a1,80002e58 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f12:	2705                	addiw	a4,a4,1
    80002f14:	2485                	addiw	s1,s1,1
    80002f16:	fd471ae3          	bne	a4,s4,80002eea <balloc+0xce>
    80002f1a:	bf49                	j	80002eac <balloc+0x90>
    80002f1c:	6906                	ld	s2,64(sp)
    80002f1e:	79e2                	ld	s3,56(sp)
    80002f20:	7a42                	ld	s4,48(sp)
    80002f22:	7aa2                	ld	s5,40(sp)
    80002f24:	7b02                	ld	s6,32(sp)
    80002f26:	6be2                	ld	s7,24(sp)
    80002f28:	6c42                	ld	s8,16(sp)
    80002f2a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f2c:	00004517          	auipc	a0,0x4
    80002f30:	55450513          	addi	a0,a0,1364 # 80007480 <etext+0x480>
    80002f34:	d8efd0ef          	jal	800004c2 <printf>
  return 0;
    80002f38:	4481                	li	s1,0
    80002f3a:	b79d                	j	80002ea0 <balloc+0x84>

0000000080002f3c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f3c:	7179                	addi	sp,sp,-48
    80002f3e:	f406                	sd	ra,40(sp)
    80002f40:	f022                	sd	s0,32(sp)
    80002f42:	ec26                	sd	s1,24(sp)
    80002f44:	e84a                	sd	s2,16(sp)
    80002f46:	e44e                	sd	s3,8(sp)
    80002f48:	1800                	addi	s0,sp,48
    80002f4a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f4c:	47ad                	li	a5,11
    80002f4e:	02b7e663          	bltu	a5,a1,80002f7a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f52:	02059793          	slli	a5,a1,0x20
    80002f56:	01e7d593          	srli	a1,a5,0x1e
    80002f5a:	00b504b3          	add	s1,a0,a1
    80002f5e:	0504a903          	lw	s2,80(s1)
    80002f62:	06091a63          	bnez	s2,80002fd6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f66:	4108                	lw	a0,0(a0)
    80002f68:	eb5ff0ef          	jal	80002e1c <balloc>
    80002f6c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f70:	06090363          	beqz	s2,80002fd6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f74:	0524a823          	sw	s2,80(s1)
    80002f78:	a8b9                	j	80002fd6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f7a:	ff45849b          	addiw	s1,a1,-12
    80002f7e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f82:	0ff00793          	li	a5,255
    80002f86:	06e7ee63          	bltu	a5,a4,80003002 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f8a:	08052903          	lw	s2,128(a0)
    80002f8e:	00091d63          	bnez	s2,80002fa8 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f92:	4108                	lw	a0,0(a0)
    80002f94:	e89ff0ef          	jal	80002e1c <balloc>
    80002f98:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f9c:	02090d63          	beqz	s2,80002fd6 <bmap+0x9a>
    80002fa0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fa2:	0929a023          	sw	s2,128(s3)
    80002fa6:	a011                	j	80002faa <bmap+0x6e>
    80002fa8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002faa:	85ca                	mv	a1,s2
    80002fac:	0009a503          	lw	a0,0(s3)
    80002fb0:	c09ff0ef          	jal	80002bb8 <bread>
    80002fb4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fb6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fba:	02049713          	slli	a4,s1,0x20
    80002fbe:	01e75593          	srli	a1,a4,0x1e
    80002fc2:	00b784b3          	add	s1,a5,a1
    80002fc6:	0004a903          	lw	s2,0(s1)
    80002fca:	00090e63          	beqz	s2,80002fe6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fce:	8552                	mv	a0,s4
    80002fd0:	cf1ff0ef          	jal	80002cc0 <brelse>
    return addr;
    80002fd4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fd6:	854a                	mv	a0,s2
    80002fd8:	70a2                	ld	ra,40(sp)
    80002fda:	7402                	ld	s0,32(sp)
    80002fdc:	64e2                	ld	s1,24(sp)
    80002fde:	6942                	ld	s2,16(sp)
    80002fe0:	69a2                	ld	s3,8(sp)
    80002fe2:	6145                	addi	sp,sp,48
    80002fe4:	8082                	ret
      addr = balloc(ip->dev);
    80002fe6:	0009a503          	lw	a0,0(s3)
    80002fea:	e33ff0ef          	jal	80002e1c <balloc>
    80002fee:	0005091b          	sext.w	s2,a0
      if(addr){
    80002ff2:	fc090ee3          	beqz	s2,80002fce <bmap+0x92>
        a[bn] = addr;
    80002ff6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002ffa:	8552                	mv	a0,s4
    80002ffc:	50f000ef          	jal	80003d0a <log_write>
    80003000:	b7f9                	j	80002fce <bmap+0x92>
    80003002:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003004:	00004517          	auipc	a0,0x4
    80003008:	49450513          	addi	a0,a0,1172 # 80007498 <etext+0x498>
    8000300c:	f88fd0ef          	jal	80000794 <panic>

0000000080003010 <iget>:
{
    80003010:	7179                	addi	sp,sp,-48
    80003012:	f406                	sd	ra,40(sp)
    80003014:	f022                	sd	s0,32(sp)
    80003016:	ec26                	sd	s1,24(sp)
    80003018:	e84a                	sd	s2,16(sp)
    8000301a:	e44e                	sd	s3,8(sp)
    8000301c:	e052                	sd	s4,0(sp)
    8000301e:	1800                	addi	s0,sp,48
    80003020:	89aa                	mv	s3,a0
    80003022:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003024:	0001e517          	auipc	a0,0x1e
    80003028:	ed450513          	addi	a0,a0,-300 # 80020ef8 <itable>
    8000302c:	bc9fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003030:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003032:	0001e497          	auipc	s1,0x1e
    80003036:	ede48493          	addi	s1,s1,-290 # 80020f10 <itable+0x18>
    8000303a:	00020697          	auipc	a3,0x20
    8000303e:	96668693          	addi	a3,a3,-1690 # 800229a0 <log>
    80003042:	a039                	j	80003050 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003044:	02090963          	beqz	s2,80003076 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003048:	08848493          	addi	s1,s1,136
    8000304c:	02d48863          	beq	s1,a3,8000307c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003050:	449c                	lw	a5,8(s1)
    80003052:	fef059e3          	blez	a5,80003044 <iget+0x34>
    80003056:	4098                	lw	a4,0(s1)
    80003058:	ff3716e3          	bne	a4,s3,80003044 <iget+0x34>
    8000305c:	40d8                	lw	a4,4(s1)
    8000305e:	ff4713e3          	bne	a4,s4,80003044 <iget+0x34>
      ip->ref++;
    80003062:	2785                	addiw	a5,a5,1
    80003064:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003066:	0001e517          	auipc	a0,0x1e
    8000306a:	e9250513          	addi	a0,a0,-366 # 80020ef8 <itable>
    8000306e:	c1ffd0ef          	jal	80000c8c <release>
      return ip;
    80003072:	8926                	mv	s2,s1
    80003074:	a02d                	j	8000309e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003076:	fbe9                	bnez	a5,80003048 <iget+0x38>
      empty = ip;
    80003078:	8926                	mv	s2,s1
    8000307a:	b7f9                	j	80003048 <iget+0x38>
  if(empty == 0)
    8000307c:	02090a63          	beqz	s2,800030b0 <iget+0xa0>
  ip->dev = dev;
    80003080:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003084:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003088:	4785                	li	a5,1
    8000308a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000308e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003092:	0001e517          	auipc	a0,0x1e
    80003096:	e6650513          	addi	a0,a0,-410 # 80020ef8 <itable>
    8000309a:	bf3fd0ef          	jal	80000c8c <release>
}
    8000309e:	854a                	mv	a0,s2
    800030a0:	70a2                	ld	ra,40(sp)
    800030a2:	7402                	ld	s0,32(sp)
    800030a4:	64e2                	ld	s1,24(sp)
    800030a6:	6942                	ld	s2,16(sp)
    800030a8:	69a2                	ld	s3,8(sp)
    800030aa:	6a02                	ld	s4,0(sp)
    800030ac:	6145                	addi	sp,sp,48
    800030ae:	8082                	ret
    panic("iget: no inodes");
    800030b0:	00004517          	auipc	a0,0x4
    800030b4:	40050513          	addi	a0,a0,1024 # 800074b0 <etext+0x4b0>
    800030b8:	edcfd0ef          	jal	80000794 <panic>

00000000800030bc <fsinit>:
fsinit(int dev) {
    800030bc:	7179                	addi	sp,sp,-48
    800030be:	f406                	sd	ra,40(sp)
    800030c0:	f022                	sd	s0,32(sp)
    800030c2:	ec26                	sd	s1,24(sp)
    800030c4:	e84a                	sd	s2,16(sp)
    800030c6:	e44e                	sd	s3,8(sp)
    800030c8:	1800                	addi	s0,sp,48
    800030ca:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030cc:	4585                	li	a1,1
    800030ce:	aebff0ef          	jal	80002bb8 <bread>
    800030d2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030d4:	0001e997          	auipc	s3,0x1e
    800030d8:	e0498993          	addi	s3,s3,-508 # 80020ed8 <sb>
    800030dc:	02000613          	li	a2,32
    800030e0:	05850593          	addi	a1,a0,88
    800030e4:	854e                	mv	a0,s3
    800030e6:	c3ffd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800030ea:	8526                	mv	a0,s1
    800030ec:	bd5ff0ef          	jal	80002cc0 <brelse>
  if(sb.magic != FSMAGIC)
    800030f0:	0009a703          	lw	a4,0(s3)
    800030f4:	102037b7          	lui	a5,0x10203
    800030f8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800030fc:	02f71063          	bne	a4,a5,8000311c <fsinit+0x60>
  initlog(dev, &sb);
    80003100:	0001e597          	auipc	a1,0x1e
    80003104:	dd858593          	addi	a1,a1,-552 # 80020ed8 <sb>
    80003108:	854a                	mv	a0,s2
    8000310a:	1f9000ef          	jal	80003b02 <initlog>
}
    8000310e:	70a2                	ld	ra,40(sp)
    80003110:	7402                	ld	s0,32(sp)
    80003112:	64e2                	ld	s1,24(sp)
    80003114:	6942                	ld	s2,16(sp)
    80003116:	69a2                	ld	s3,8(sp)
    80003118:	6145                	addi	sp,sp,48
    8000311a:	8082                	ret
    panic("invalid file system");
    8000311c:	00004517          	auipc	a0,0x4
    80003120:	3a450513          	addi	a0,a0,932 # 800074c0 <etext+0x4c0>
    80003124:	e70fd0ef          	jal	80000794 <panic>

0000000080003128 <iinit>:
{
    80003128:	7179                	addi	sp,sp,-48
    8000312a:	f406                	sd	ra,40(sp)
    8000312c:	f022                	sd	s0,32(sp)
    8000312e:	ec26                	sd	s1,24(sp)
    80003130:	e84a                	sd	s2,16(sp)
    80003132:	e44e                	sd	s3,8(sp)
    80003134:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003136:	00004597          	auipc	a1,0x4
    8000313a:	3a258593          	addi	a1,a1,930 # 800074d8 <etext+0x4d8>
    8000313e:	0001e517          	auipc	a0,0x1e
    80003142:	dba50513          	addi	a0,a0,-582 # 80020ef8 <itable>
    80003146:	a2ffd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000314a:	0001e497          	auipc	s1,0x1e
    8000314e:	dd648493          	addi	s1,s1,-554 # 80020f20 <itable+0x28>
    80003152:	00020997          	auipc	s3,0x20
    80003156:	85e98993          	addi	s3,s3,-1954 # 800229b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000315a:	00004917          	auipc	s2,0x4
    8000315e:	38690913          	addi	s2,s2,902 # 800074e0 <etext+0x4e0>
    80003162:	85ca                	mv	a1,s2
    80003164:	8526                	mv	a0,s1
    80003166:	475000ef          	jal	80003dda <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000316a:	08848493          	addi	s1,s1,136
    8000316e:	ff349ae3          	bne	s1,s3,80003162 <iinit+0x3a>
}
    80003172:	70a2                	ld	ra,40(sp)
    80003174:	7402                	ld	s0,32(sp)
    80003176:	64e2                	ld	s1,24(sp)
    80003178:	6942                	ld	s2,16(sp)
    8000317a:	69a2                	ld	s3,8(sp)
    8000317c:	6145                	addi	sp,sp,48
    8000317e:	8082                	ret

0000000080003180 <ialloc>:
{
    80003180:	7139                	addi	sp,sp,-64
    80003182:	fc06                	sd	ra,56(sp)
    80003184:	f822                	sd	s0,48(sp)
    80003186:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003188:	0001e717          	auipc	a4,0x1e
    8000318c:	d5c72703          	lw	a4,-676(a4) # 80020ee4 <sb+0xc>
    80003190:	4785                	li	a5,1
    80003192:	06e7f063          	bgeu	a5,a4,800031f2 <ialloc+0x72>
    80003196:	f426                	sd	s1,40(sp)
    80003198:	f04a                	sd	s2,32(sp)
    8000319a:	ec4e                	sd	s3,24(sp)
    8000319c:	e852                	sd	s4,16(sp)
    8000319e:	e456                	sd	s5,8(sp)
    800031a0:	e05a                	sd	s6,0(sp)
    800031a2:	8aaa                	mv	s5,a0
    800031a4:	8b2e                	mv	s6,a1
    800031a6:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800031a8:	0001ea17          	auipc	s4,0x1e
    800031ac:	d30a0a13          	addi	s4,s4,-720 # 80020ed8 <sb>
    800031b0:	00495593          	srli	a1,s2,0x4
    800031b4:	018a2783          	lw	a5,24(s4)
    800031b8:	9dbd                	addw	a1,a1,a5
    800031ba:	8556                	mv	a0,s5
    800031bc:	9fdff0ef          	jal	80002bb8 <bread>
    800031c0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031c2:	05850993          	addi	s3,a0,88
    800031c6:	00f97793          	andi	a5,s2,15
    800031ca:	079a                	slli	a5,a5,0x6
    800031cc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031ce:	00099783          	lh	a5,0(s3)
    800031d2:	cb9d                	beqz	a5,80003208 <ialloc+0x88>
    brelse(bp);
    800031d4:	aedff0ef          	jal	80002cc0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031d8:	0905                	addi	s2,s2,1
    800031da:	00ca2703          	lw	a4,12(s4)
    800031de:	0009079b          	sext.w	a5,s2
    800031e2:	fce7e7e3          	bltu	a5,a4,800031b0 <ialloc+0x30>
    800031e6:	74a2                	ld	s1,40(sp)
    800031e8:	7902                	ld	s2,32(sp)
    800031ea:	69e2                	ld	s3,24(sp)
    800031ec:	6a42                	ld	s4,16(sp)
    800031ee:	6aa2                	ld	s5,8(sp)
    800031f0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031f2:	00004517          	auipc	a0,0x4
    800031f6:	2f650513          	addi	a0,a0,758 # 800074e8 <etext+0x4e8>
    800031fa:	ac8fd0ef          	jal	800004c2 <printf>
  return 0;
    800031fe:	4501                	li	a0,0
}
    80003200:	70e2                	ld	ra,56(sp)
    80003202:	7442                	ld	s0,48(sp)
    80003204:	6121                	addi	sp,sp,64
    80003206:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003208:	04000613          	li	a2,64
    8000320c:	4581                	li	a1,0
    8000320e:	854e                	mv	a0,s3
    80003210:	ab9fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003214:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003218:	8526                	mv	a0,s1
    8000321a:	2f1000ef          	jal	80003d0a <log_write>
      brelse(bp);
    8000321e:	8526                	mv	a0,s1
    80003220:	aa1ff0ef          	jal	80002cc0 <brelse>
      return iget(dev, inum);
    80003224:	0009059b          	sext.w	a1,s2
    80003228:	8556                	mv	a0,s5
    8000322a:	de7ff0ef          	jal	80003010 <iget>
    8000322e:	74a2                	ld	s1,40(sp)
    80003230:	7902                	ld	s2,32(sp)
    80003232:	69e2                	ld	s3,24(sp)
    80003234:	6a42                	ld	s4,16(sp)
    80003236:	6aa2                	ld	s5,8(sp)
    80003238:	6b02                	ld	s6,0(sp)
    8000323a:	b7d9                	j	80003200 <ialloc+0x80>

000000008000323c <iupdate>:
{
    8000323c:	1101                	addi	sp,sp,-32
    8000323e:	ec06                	sd	ra,24(sp)
    80003240:	e822                	sd	s0,16(sp)
    80003242:	e426                	sd	s1,8(sp)
    80003244:	e04a                	sd	s2,0(sp)
    80003246:	1000                	addi	s0,sp,32
    80003248:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000324a:	415c                	lw	a5,4(a0)
    8000324c:	0047d79b          	srliw	a5,a5,0x4
    80003250:	0001e597          	auipc	a1,0x1e
    80003254:	ca05a583          	lw	a1,-864(a1) # 80020ef0 <sb+0x18>
    80003258:	9dbd                	addw	a1,a1,a5
    8000325a:	4108                	lw	a0,0(a0)
    8000325c:	95dff0ef          	jal	80002bb8 <bread>
    80003260:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003262:	05850793          	addi	a5,a0,88
    80003266:	40d8                	lw	a4,4(s1)
    80003268:	8b3d                	andi	a4,a4,15
    8000326a:	071a                	slli	a4,a4,0x6
    8000326c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000326e:	04449703          	lh	a4,68(s1)
    80003272:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003276:	04649703          	lh	a4,70(s1)
    8000327a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000327e:	04849703          	lh	a4,72(s1)
    80003282:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003286:	04a49703          	lh	a4,74(s1)
    8000328a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000328e:	44f8                	lw	a4,76(s1)
    80003290:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003292:	03400613          	li	a2,52
    80003296:	05048593          	addi	a1,s1,80
    8000329a:	00c78513          	addi	a0,a5,12
    8000329e:	a87fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    800032a2:	854a                	mv	a0,s2
    800032a4:	267000ef          	jal	80003d0a <log_write>
  brelse(bp);
    800032a8:	854a                	mv	a0,s2
    800032aa:	a17ff0ef          	jal	80002cc0 <brelse>
}
    800032ae:	60e2                	ld	ra,24(sp)
    800032b0:	6442                	ld	s0,16(sp)
    800032b2:	64a2                	ld	s1,8(sp)
    800032b4:	6902                	ld	s2,0(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <idup>:
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
    800032c4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032c6:	0001e517          	auipc	a0,0x1e
    800032ca:	c3250513          	addi	a0,a0,-974 # 80020ef8 <itable>
    800032ce:	927fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800032d2:	449c                	lw	a5,8(s1)
    800032d4:	2785                	addiw	a5,a5,1
    800032d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032d8:	0001e517          	auipc	a0,0x1e
    800032dc:	c2050513          	addi	a0,a0,-992 # 80020ef8 <itable>
    800032e0:	9adfd0ef          	jal	80000c8c <release>
}
    800032e4:	8526                	mv	a0,s1
    800032e6:	60e2                	ld	ra,24(sp)
    800032e8:	6442                	ld	s0,16(sp)
    800032ea:	64a2                	ld	s1,8(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret

00000000800032f0 <ilock>:
{
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	e426                	sd	s1,8(sp)
    800032f8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032fa:	cd19                	beqz	a0,80003318 <ilock+0x28>
    800032fc:	84aa                	mv	s1,a0
    800032fe:	451c                	lw	a5,8(a0)
    80003300:	00f05c63          	blez	a5,80003318 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003304:	0541                	addi	a0,a0,16
    80003306:	30b000ef          	jal	80003e10 <acquiresleep>
  if(ip->valid == 0){
    8000330a:	40bc                	lw	a5,64(s1)
    8000330c:	cf89                	beqz	a5,80003326 <ilock+0x36>
}
    8000330e:	60e2                	ld	ra,24(sp)
    80003310:	6442                	ld	s0,16(sp)
    80003312:	64a2                	ld	s1,8(sp)
    80003314:	6105                	addi	sp,sp,32
    80003316:	8082                	ret
    80003318:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000331a:	00004517          	auipc	a0,0x4
    8000331e:	1e650513          	addi	a0,a0,486 # 80007500 <etext+0x500>
    80003322:	c72fd0ef          	jal	80000794 <panic>
    80003326:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003328:	40dc                	lw	a5,4(s1)
    8000332a:	0047d79b          	srliw	a5,a5,0x4
    8000332e:	0001e597          	auipc	a1,0x1e
    80003332:	bc25a583          	lw	a1,-1086(a1) # 80020ef0 <sb+0x18>
    80003336:	9dbd                	addw	a1,a1,a5
    80003338:	4088                	lw	a0,0(s1)
    8000333a:	87fff0ef          	jal	80002bb8 <bread>
    8000333e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003340:	05850593          	addi	a1,a0,88
    80003344:	40dc                	lw	a5,4(s1)
    80003346:	8bbd                	andi	a5,a5,15
    80003348:	079a                	slli	a5,a5,0x6
    8000334a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000334c:	00059783          	lh	a5,0(a1)
    80003350:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003354:	00259783          	lh	a5,2(a1)
    80003358:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000335c:	00459783          	lh	a5,4(a1)
    80003360:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003364:	00659783          	lh	a5,6(a1)
    80003368:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000336c:	459c                	lw	a5,8(a1)
    8000336e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003370:	03400613          	li	a2,52
    80003374:	05b1                	addi	a1,a1,12
    80003376:	05048513          	addi	a0,s1,80
    8000337a:	9abfd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000337e:	854a                	mv	a0,s2
    80003380:	941ff0ef          	jal	80002cc0 <brelse>
    ip->valid = 1;
    80003384:	4785                	li	a5,1
    80003386:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003388:	04449783          	lh	a5,68(s1)
    8000338c:	c399                	beqz	a5,80003392 <ilock+0xa2>
    8000338e:	6902                	ld	s2,0(sp)
    80003390:	bfbd                	j	8000330e <ilock+0x1e>
      panic("ilock: no type");
    80003392:	00004517          	auipc	a0,0x4
    80003396:	17650513          	addi	a0,a0,374 # 80007508 <etext+0x508>
    8000339a:	bfafd0ef          	jal	80000794 <panic>

000000008000339e <iunlock>:
{
    8000339e:	1101                	addi	sp,sp,-32
    800033a0:	ec06                	sd	ra,24(sp)
    800033a2:	e822                	sd	s0,16(sp)
    800033a4:	e426                	sd	s1,8(sp)
    800033a6:	e04a                	sd	s2,0(sp)
    800033a8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033aa:	c505                	beqz	a0,800033d2 <iunlock+0x34>
    800033ac:	84aa                	mv	s1,a0
    800033ae:	01050913          	addi	s2,a0,16
    800033b2:	854a                	mv	a0,s2
    800033b4:	2db000ef          	jal	80003e8e <holdingsleep>
    800033b8:	cd09                	beqz	a0,800033d2 <iunlock+0x34>
    800033ba:	449c                	lw	a5,8(s1)
    800033bc:	00f05b63          	blez	a5,800033d2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033c0:	854a                	mv	a0,s2
    800033c2:	295000ef          	jal	80003e56 <releasesleep>
}
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6902                	ld	s2,0(sp)
    800033ce:	6105                	addi	sp,sp,32
    800033d0:	8082                	ret
    panic("iunlock");
    800033d2:	00004517          	auipc	a0,0x4
    800033d6:	14650513          	addi	a0,a0,326 # 80007518 <etext+0x518>
    800033da:	bbafd0ef          	jal	80000794 <panic>

00000000800033de <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033de:	7179                	addi	sp,sp,-48
    800033e0:	f406                	sd	ra,40(sp)
    800033e2:	f022                	sd	s0,32(sp)
    800033e4:	ec26                	sd	s1,24(sp)
    800033e6:	e84a                	sd	s2,16(sp)
    800033e8:	e44e                	sd	s3,8(sp)
    800033ea:	1800                	addi	s0,sp,48
    800033ec:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033ee:	05050493          	addi	s1,a0,80
    800033f2:	08050913          	addi	s2,a0,128
    800033f6:	a021                	j	800033fe <itrunc+0x20>
    800033f8:	0491                	addi	s1,s1,4
    800033fa:	01248b63          	beq	s1,s2,80003410 <itrunc+0x32>
    if(ip->addrs[i]){
    800033fe:	408c                	lw	a1,0(s1)
    80003400:	dde5                	beqz	a1,800033f8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003402:	0009a503          	lw	a0,0(s3)
    80003406:	9abff0ef          	jal	80002db0 <bfree>
      ip->addrs[i] = 0;
    8000340a:	0004a023          	sw	zero,0(s1)
    8000340e:	b7ed                	j	800033f8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003410:	0809a583          	lw	a1,128(s3)
    80003414:	ed89                	bnez	a1,8000342e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003416:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000341a:	854e                	mv	a0,s3
    8000341c:	e21ff0ef          	jal	8000323c <iupdate>
}
    80003420:	70a2                	ld	ra,40(sp)
    80003422:	7402                	ld	s0,32(sp)
    80003424:	64e2                	ld	s1,24(sp)
    80003426:	6942                	ld	s2,16(sp)
    80003428:	69a2                	ld	s3,8(sp)
    8000342a:	6145                	addi	sp,sp,48
    8000342c:	8082                	ret
    8000342e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003430:	0009a503          	lw	a0,0(s3)
    80003434:	f84ff0ef          	jal	80002bb8 <bread>
    80003438:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000343a:	05850493          	addi	s1,a0,88
    8000343e:	45850913          	addi	s2,a0,1112
    80003442:	a021                	j	8000344a <itrunc+0x6c>
    80003444:	0491                	addi	s1,s1,4
    80003446:	01248963          	beq	s1,s2,80003458 <itrunc+0x7a>
      if(a[j])
    8000344a:	408c                	lw	a1,0(s1)
    8000344c:	dde5                	beqz	a1,80003444 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000344e:	0009a503          	lw	a0,0(s3)
    80003452:	95fff0ef          	jal	80002db0 <bfree>
    80003456:	b7fd                	j	80003444 <itrunc+0x66>
    brelse(bp);
    80003458:	8552                	mv	a0,s4
    8000345a:	867ff0ef          	jal	80002cc0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000345e:	0809a583          	lw	a1,128(s3)
    80003462:	0009a503          	lw	a0,0(s3)
    80003466:	94bff0ef          	jal	80002db0 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000346a:	0809a023          	sw	zero,128(s3)
    8000346e:	6a02                	ld	s4,0(sp)
    80003470:	b75d                	j	80003416 <itrunc+0x38>

0000000080003472 <iput>:
{
    80003472:	1101                	addi	sp,sp,-32
    80003474:	ec06                	sd	ra,24(sp)
    80003476:	e822                	sd	s0,16(sp)
    80003478:	e426                	sd	s1,8(sp)
    8000347a:	1000                	addi	s0,sp,32
    8000347c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000347e:	0001e517          	auipc	a0,0x1e
    80003482:	a7a50513          	addi	a0,a0,-1414 # 80020ef8 <itable>
    80003486:	f6efd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000348a:	4498                	lw	a4,8(s1)
    8000348c:	4785                	li	a5,1
    8000348e:	02f70063          	beq	a4,a5,800034ae <iput+0x3c>
  ip->ref--;
    80003492:	449c                	lw	a5,8(s1)
    80003494:	37fd                	addiw	a5,a5,-1
    80003496:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003498:	0001e517          	auipc	a0,0x1e
    8000349c:	a6050513          	addi	a0,a0,-1440 # 80020ef8 <itable>
    800034a0:	fecfd0ef          	jal	80000c8c <release>
}
    800034a4:	60e2                	ld	ra,24(sp)
    800034a6:	6442                	ld	s0,16(sp)
    800034a8:	64a2                	ld	s1,8(sp)
    800034aa:	6105                	addi	sp,sp,32
    800034ac:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034ae:	40bc                	lw	a5,64(s1)
    800034b0:	d3ed                	beqz	a5,80003492 <iput+0x20>
    800034b2:	04a49783          	lh	a5,74(s1)
    800034b6:	fff1                	bnez	a5,80003492 <iput+0x20>
    800034b8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034ba:	01048913          	addi	s2,s1,16
    800034be:	854a                	mv	a0,s2
    800034c0:	151000ef          	jal	80003e10 <acquiresleep>
    release(&itable.lock);
    800034c4:	0001e517          	auipc	a0,0x1e
    800034c8:	a3450513          	addi	a0,a0,-1484 # 80020ef8 <itable>
    800034cc:	fc0fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800034d0:	8526                	mv	a0,s1
    800034d2:	f0dff0ef          	jal	800033de <itrunc>
    ip->type = 0;
    800034d6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034da:	8526                	mv	a0,s1
    800034dc:	d61ff0ef          	jal	8000323c <iupdate>
    ip->valid = 0;
    800034e0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034e4:	854a                	mv	a0,s2
    800034e6:	171000ef          	jal	80003e56 <releasesleep>
    acquire(&itable.lock);
    800034ea:	0001e517          	auipc	a0,0x1e
    800034ee:	a0e50513          	addi	a0,a0,-1522 # 80020ef8 <itable>
    800034f2:	f02fd0ef          	jal	80000bf4 <acquire>
    800034f6:	6902                	ld	s2,0(sp)
    800034f8:	bf69                	j	80003492 <iput+0x20>

00000000800034fa <iunlockput>:
{
    800034fa:	1101                	addi	sp,sp,-32
    800034fc:	ec06                	sd	ra,24(sp)
    800034fe:	e822                	sd	s0,16(sp)
    80003500:	e426                	sd	s1,8(sp)
    80003502:	1000                	addi	s0,sp,32
    80003504:	84aa                	mv	s1,a0
  iunlock(ip);
    80003506:	e99ff0ef          	jal	8000339e <iunlock>
  iput(ip);
    8000350a:	8526                	mv	a0,s1
    8000350c:	f67ff0ef          	jal	80003472 <iput>
}
    80003510:	60e2                	ld	ra,24(sp)
    80003512:	6442                	ld	s0,16(sp)
    80003514:	64a2                	ld	s1,8(sp)
    80003516:	6105                	addi	sp,sp,32
    80003518:	8082                	ret

000000008000351a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000351a:	1141                	addi	sp,sp,-16
    8000351c:	e422                	sd	s0,8(sp)
    8000351e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003520:	411c                	lw	a5,0(a0)
    80003522:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003524:	415c                	lw	a5,4(a0)
    80003526:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003528:	04451783          	lh	a5,68(a0)
    8000352c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003530:	04a51783          	lh	a5,74(a0)
    80003534:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003538:	04c56783          	lwu	a5,76(a0)
    8000353c:	e99c                	sd	a5,16(a1)
}
    8000353e:	6422                	ld	s0,8(sp)
    80003540:	0141                	addi	sp,sp,16
    80003542:	8082                	ret

0000000080003544 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003544:	457c                	lw	a5,76(a0)
    80003546:	0ed7eb63          	bltu	a5,a3,8000363c <readi+0xf8>
{
    8000354a:	7159                	addi	sp,sp,-112
    8000354c:	f486                	sd	ra,104(sp)
    8000354e:	f0a2                	sd	s0,96(sp)
    80003550:	eca6                	sd	s1,88(sp)
    80003552:	e0d2                	sd	s4,64(sp)
    80003554:	fc56                	sd	s5,56(sp)
    80003556:	f85a                	sd	s6,48(sp)
    80003558:	f45e                	sd	s7,40(sp)
    8000355a:	1880                	addi	s0,sp,112
    8000355c:	8b2a                	mv	s6,a0
    8000355e:	8bae                	mv	s7,a1
    80003560:	8a32                	mv	s4,a2
    80003562:	84b6                	mv	s1,a3
    80003564:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003566:	9f35                	addw	a4,a4,a3
    return 0;
    80003568:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000356a:	0cd76063          	bltu	a4,a3,8000362a <readi+0xe6>
    8000356e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003570:	00e7f463          	bgeu	a5,a4,80003578 <readi+0x34>
    n = ip->size - off;
    80003574:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003578:	080a8f63          	beqz	s5,80003616 <readi+0xd2>
    8000357c:	e8ca                	sd	s2,80(sp)
    8000357e:	f062                	sd	s8,32(sp)
    80003580:	ec66                	sd	s9,24(sp)
    80003582:	e86a                	sd	s10,16(sp)
    80003584:	e46e                	sd	s11,8(sp)
    80003586:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003588:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000358c:	5c7d                	li	s8,-1
    8000358e:	a80d                	j	800035c0 <readi+0x7c>
    80003590:	020d1d93          	slli	s11,s10,0x20
    80003594:	020ddd93          	srli	s11,s11,0x20
    80003598:	05890613          	addi	a2,s2,88
    8000359c:	86ee                	mv	a3,s11
    8000359e:	963a                	add	a2,a2,a4
    800035a0:	85d2                	mv	a1,s4
    800035a2:	855e                	mv	a0,s7
    800035a4:	cd7fe0ef          	jal	8000227a <either_copyout>
    800035a8:	05850763          	beq	a0,s8,800035f6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035ac:	854a                	mv	a0,s2
    800035ae:	f12ff0ef          	jal	80002cc0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035b2:	013d09bb          	addw	s3,s10,s3
    800035b6:	009d04bb          	addw	s1,s10,s1
    800035ba:	9a6e                	add	s4,s4,s11
    800035bc:	0559f763          	bgeu	s3,s5,8000360a <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800035c0:	00a4d59b          	srliw	a1,s1,0xa
    800035c4:	855a                	mv	a0,s6
    800035c6:	977ff0ef          	jal	80002f3c <bmap>
    800035ca:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035ce:	c5b1                	beqz	a1,8000361a <readi+0xd6>
    bp = bread(ip->dev, addr);
    800035d0:	000b2503          	lw	a0,0(s6)
    800035d4:	de4ff0ef          	jal	80002bb8 <bread>
    800035d8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035da:	3ff4f713          	andi	a4,s1,1023
    800035de:	40ec87bb          	subw	a5,s9,a4
    800035e2:	413a86bb          	subw	a3,s5,s3
    800035e6:	8d3e                	mv	s10,a5
    800035e8:	2781                	sext.w	a5,a5
    800035ea:	0006861b          	sext.w	a2,a3
    800035ee:	faf671e3          	bgeu	a2,a5,80003590 <readi+0x4c>
    800035f2:	8d36                	mv	s10,a3
    800035f4:	bf71                	j	80003590 <readi+0x4c>
      brelse(bp);
    800035f6:	854a                	mv	a0,s2
    800035f8:	ec8ff0ef          	jal	80002cc0 <brelse>
      tot = -1;
    800035fc:	59fd                	li	s3,-1
      break;
    800035fe:	6946                	ld	s2,80(sp)
    80003600:	7c02                	ld	s8,32(sp)
    80003602:	6ce2                	ld	s9,24(sp)
    80003604:	6d42                	ld	s10,16(sp)
    80003606:	6da2                	ld	s11,8(sp)
    80003608:	a831                	j	80003624 <readi+0xe0>
    8000360a:	6946                	ld	s2,80(sp)
    8000360c:	7c02                	ld	s8,32(sp)
    8000360e:	6ce2                	ld	s9,24(sp)
    80003610:	6d42                	ld	s10,16(sp)
    80003612:	6da2                	ld	s11,8(sp)
    80003614:	a801                	j	80003624 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003616:	89d6                	mv	s3,s5
    80003618:	a031                	j	80003624 <readi+0xe0>
    8000361a:	6946                	ld	s2,80(sp)
    8000361c:	7c02                	ld	s8,32(sp)
    8000361e:	6ce2                	ld	s9,24(sp)
    80003620:	6d42                	ld	s10,16(sp)
    80003622:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003624:	0009851b          	sext.w	a0,s3
    80003628:	69a6                	ld	s3,72(sp)
}
    8000362a:	70a6                	ld	ra,104(sp)
    8000362c:	7406                	ld	s0,96(sp)
    8000362e:	64e6                	ld	s1,88(sp)
    80003630:	6a06                	ld	s4,64(sp)
    80003632:	7ae2                	ld	s5,56(sp)
    80003634:	7b42                	ld	s6,48(sp)
    80003636:	7ba2                	ld	s7,40(sp)
    80003638:	6165                	addi	sp,sp,112
    8000363a:	8082                	ret
    return 0;
    8000363c:	4501                	li	a0,0
}
    8000363e:	8082                	ret

0000000080003640 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003640:	457c                	lw	a5,76(a0)
    80003642:	10d7e063          	bltu	a5,a3,80003742 <writei+0x102>
{
    80003646:	7159                	addi	sp,sp,-112
    80003648:	f486                	sd	ra,104(sp)
    8000364a:	f0a2                	sd	s0,96(sp)
    8000364c:	e8ca                	sd	s2,80(sp)
    8000364e:	e0d2                	sd	s4,64(sp)
    80003650:	fc56                	sd	s5,56(sp)
    80003652:	f85a                	sd	s6,48(sp)
    80003654:	f45e                	sd	s7,40(sp)
    80003656:	1880                	addi	s0,sp,112
    80003658:	8aaa                	mv	s5,a0
    8000365a:	8bae                	mv	s7,a1
    8000365c:	8a32                	mv	s4,a2
    8000365e:	8936                	mv	s2,a3
    80003660:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003662:	00e687bb          	addw	a5,a3,a4
    80003666:	0ed7e063          	bltu	a5,a3,80003746 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000366a:	00043737          	lui	a4,0x43
    8000366e:	0cf76e63          	bltu	a4,a5,8000374a <writei+0x10a>
    80003672:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003674:	0a0b0f63          	beqz	s6,80003732 <writei+0xf2>
    80003678:	eca6                	sd	s1,88(sp)
    8000367a:	f062                	sd	s8,32(sp)
    8000367c:	ec66                	sd	s9,24(sp)
    8000367e:	e86a                	sd	s10,16(sp)
    80003680:	e46e                	sd	s11,8(sp)
    80003682:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003684:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003688:	5c7d                	li	s8,-1
    8000368a:	a825                	j	800036c2 <writei+0x82>
    8000368c:	020d1d93          	slli	s11,s10,0x20
    80003690:	020ddd93          	srli	s11,s11,0x20
    80003694:	05848513          	addi	a0,s1,88
    80003698:	86ee                	mv	a3,s11
    8000369a:	8652                	mv	a2,s4
    8000369c:	85de                	mv	a1,s7
    8000369e:	953a                	add	a0,a0,a4
    800036a0:	c25fe0ef          	jal	800022c4 <either_copyin>
    800036a4:	05850a63          	beq	a0,s8,800036f8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036a8:	8526                	mv	a0,s1
    800036aa:	660000ef          	jal	80003d0a <log_write>
    brelse(bp);
    800036ae:	8526                	mv	a0,s1
    800036b0:	e10ff0ef          	jal	80002cc0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036b4:	013d09bb          	addw	s3,s10,s3
    800036b8:	012d093b          	addw	s2,s10,s2
    800036bc:	9a6e                	add	s4,s4,s11
    800036be:	0569f063          	bgeu	s3,s6,800036fe <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036c2:	00a9559b          	srliw	a1,s2,0xa
    800036c6:	8556                	mv	a0,s5
    800036c8:	875ff0ef          	jal	80002f3c <bmap>
    800036cc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036d0:	c59d                	beqz	a1,800036fe <writei+0xbe>
    bp = bread(ip->dev, addr);
    800036d2:	000aa503          	lw	a0,0(s5)
    800036d6:	ce2ff0ef          	jal	80002bb8 <bread>
    800036da:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036dc:	3ff97713          	andi	a4,s2,1023
    800036e0:	40ec87bb          	subw	a5,s9,a4
    800036e4:	413b06bb          	subw	a3,s6,s3
    800036e8:	8d3e                	mv	s10,a5
    800036ea:	2781                	sext.w	a5,a5
    800036ec:	0006861b          	sext.w	a2,a3
    800036f0:	f8f67ee3          	bgeu	a2,a5,8000368c <writei+0x4c>
    800036f4:	8d36                	mv	s10,a3
    800036f6:	bf59                	j	8000368c <writei+0x4c>
      brelse(bp);
    800036f8:	8526                	mv	a0,s1
    800036fa:	dc6ff0ef          	jal	80002cc0 <brelse>
  }

  if(off > ip->size)
    800036fe:	04caa783          	lw	a5,76(s5)
    80003702:	0327fa63          	bgeu	a5,s2,80003736 <writei+0xf6>
    ip->size = off;
    80003706:	052aa623          	sw	s2,76(s5)
    8000370a:	64e6                	ld	s1,88(sp)
    8000370c:	7c02                	ld	s8,32(sp)
    8000370e:	6ce2                	ld	s9,24(sp)
    80003710:	6d42                	ld	s10,16(sp)
    80003712:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003714:	8556                	mv	a0,s5
    80003716:	b27ff0ef          	jal	8000323c <iupdate>

  return tot;
    8000371a:	0009851b          	sext.w	a0,s3
    8000371e:	69a6                	ld	s3,72(sp)
}
    80003720:	70a6                	ld	ra,104(sp)
    80003722:	7406                	ld	s0,96(sp)
    80003724:	6946                	ld	s2,80(sp)
    80003726:	6a06                	ld	s4,64(sp)
    80003728:	7ae2                	ld	s5,56(sp)
    8000372a:	7b42                	ld	s6,48(sp)
    8000372c:	7ba2                	ld	s7,40(sp)
    8000372e:	6165                	addi	sp,sp,112
    80003730:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003732:	89da                	mv	s3,s6
    80003734:	b7c5                	j	80003714 <writei+0xd4>
    80003736:	64e6                	ld	s1,88(sp)
    80003738:	7c02                	ld	s8,32(sp)
    8000373a:	6ce2                	ld	s9,24(sp)
    8000373c:	6d42                	ld	s10,16(sp)
    8000373e:	6da2                	ld	s11,8(sp)
    80003740:	bfd1                	j	80003714 <writei+0xd4>
    return -1;
    80003742:	557d                	li	a0,-1
}
    80003744:	8082                	ret
    return -1;
    80003746:	557d                	li	a0,-1
    80003748:	bfe1                	j	80003720 <writei+0xe0>
    return -1;
    8000374a:	557d                	li	a0,-1
    8000374c:	bfd1                	j	80003720 <writei+0xe0>

000000008000374e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000374e:	1141                	addi	sp,sp,-16
    80003750:	e406                	sd	ra,8(sp)
    80003752:	e022                	sd	s0,0(sp)
    80003754:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003756:	4639                	li	a2,14
    80003758:	e3cfd0ef          	jal	80000d94 <strncmp>
}
    8000375c:	60a2                	ld	ra,8(sp)
    8000375e:	6402                	ld	s0,0(sp)
    80003760:	0141                	addi	sp,sp,16
    80003762:	8082                	ret

0000000080003764 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003764:	7139                	addi	sp,sp,-64
    80003766:	fc06                	sd	ra,56(sp)
    80003768:	f822                	sd	s0,48(sp)
    8000376a:	f426                	sd	s1,40(sp)
    8000376c:	f04a                	sd	s2,32(sp)
    8000376e:	ec4e                	sd	s3,24(sp)
    80003770:	e852                	sd	s4,16(sp)
    80003772:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003774:	04451703          	lh	a4,68(a0)
    80003778:	4785                	li	a5,1
    8000377a:	00f71a63          	bne	a4,a5,8000378e <dirlookup+0x2a>
    8000377e:	892a                	mv	s2,a0
    80003780:	89ae                	mv	s3,a1
    80003782:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003784:	457c                	lw	a5,76(a0)
    80003786:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003788:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000378a:	e39d                	bnez	a5,800037b0 <dirlookup+0x4c>
    8000378c:	a095                	j	800037f0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000378e:	00004517          	auipc	a0,0x4
    80003792:	d9250513          	addi	a0,a0,-622 # 80007520 <etext+0x520>
    80003796:	ffffc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    8000379a:	00004517          	auipc	a0,0x4
    8000379e:	d9e50513          	addi	a0,a0,-610 # 80007538 <etext+0x538>
    800037a2:	ff3fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037a6:	24c1                	addiw	s1,s1,16
    800037a8:	04c92783          	lw	a5,76(s2)
    800037ac:	04f4f163          	bgeu	s1,a5,800037ee <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037b0:	4741                	li	a4,16
    800037b2:	86a6                	mv	a3,s1
    800037b4:	fc040613          	addi	a2,s0,-64
    800037b8:	4581                	li	a1,0
    800037ba:	854a                	mv	a0,s2
    800037bc:	d89ff0ef          	jal	80003544 <readi>
    800037c0:	47c1                	li	a5,16
    800037c2:	fcf51ce3          	bne	a0,a5,8000379a <dirlookup+0x36>
    if(de.inum == 0)
    800037c6:	fc045783          	lhu	a5,-64(s0)
    800037ca:	dff1                	beqz	a5,800037a6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800037cc:	fc240593          	addi	a1,s0,-62
    800037d0:	854e                	mv	a0,s3
    800037d2:	f7dff0ef          	jal	8000374e <namecmp>
    800037d6:	f961                	bnez	a0,800037a6 <dirlookup+0x42>
      if(poff)
    800037d8:	000a0463          	beqz	s4,800037e0 <dirlookup+0x7c>
        *poff = off;
    800037dc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800037e0:	fc045583          	lhu	a1,-64(s0)
    800037e4:	00092503          	lw	a0,0(s2)
    800037e8:	829ff0ef          	jal	80003010 <iget>
    800037ec:	a011                	j	800037f0 <dirlookup+0x8c>
  return 0;
    800037ee:	4501                	li	a0,0
}
    800037f0:	70e2                	ld	ra,56(sp)
    800037f2:	7442                	ld	s0,48(sp)
    800037f4:	74a2                	ld	s1,40(sp)
    800037f6:	7902                	ld	s2,32(sp)
    800037f8:	69e2                	ld	s3,24(sp)
    800037fa:	6a42                	ld	s4,16(sp)
    800037fc:	6121                	addi	sp,sp,64
    800037fe:	8082                	ret

0000000080003800 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003800:	711d                	addi	sp,sp,-96
    80003802:	ec86                	sd	ra,88(sp)
    80003804:	e8a2                	sd	s0,80(sp)
    80003806:	e4a6                	sd	s1,72(sp)
    80003808:	e0ca                	sd	s2,64(sp)
    8000380a:	fc4e                	sd	s3,56(sp)
    8000380c:	f852                	sd	s4,48(sp)
    8000380e:	f456                	sd	s5,40(sp)
    80003810:	f05a                	sd	s6,32(sp)
    80003812:	ec5e                	sd	s7,24(sp)
    80003814:	e862                	sd	s8,16(sp)
    80003816:	e466                	sd	s9,8(sp)
    80003818:	1080                	addi	s0,sp,96
    8000381a:	84aa                	mv	s1,a0
    8000381c:	8b2e                	mv	s6,a1
    8000381e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003820:	00054703          	lbu	a4,0(a0)
    80003824:	02f00793          	li	a5,47
    80003828:	00f70e63          	beq	a4,a5,80003844 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000382c:	8b4fe0ef          	jal	800018e0 <myproc>
    80003830:	15053503          	ld	a0,336(a0)
    80003834:	a87ff0ef          	jal	800032ba <idup>
    80003838:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000383a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000383e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003840:	4b85                	li	s7,1
    80003842:	a871                	j	800038de <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003844:	4585                	li	a1,1
    80003846:	4505                	li	a0,1
    80003848:	fc8ff0ef          	jal	80003010 <iget>
    8000384c:	8a2a                	mv	s4,a0
    8000384e:	b7f5                	j	8000383a <namex+0x3a>
      iunlockput(ip);
    80003850:	8552                	mv	a0,s4
    80003852:	ca9ff0ef          	jal	800034fa <iunlockput>
      return 0;
    80003856:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003858:	8552                	mv	a0,s4
    8000385a:	60e6                	ld	ra,88(sp)
    8000385c:	6446                	ld	s0,80(sp)
    8000385e:	64a6                	ld	s1,72(sp)
    80003860:	6906                	ld	s2,64(sp)
    80003862:	79e2                	ld	s3,56(sp)
    80003864:	7a42                	ld	s4,48(sp)
    80003866:	7aa2                	ld	s5,40(sp)
    80003868:	7b02                	ld	s6,32(sp)
    8000386a:	6be2                	ld	s7,24(sp)
    8000386c:	6c42                	ld	s8,16(sp)
    8000386e:	6ca2                	ld	s9,8(sp)
    80003870:	6125                	addi	sp,sp,96
    80003872:	8082                	ret
      iunlock(ip);
    80003874:	8552                	mv	a0,s4
    80003876:	b29ff0ef          	jal	8000339e <iunlock>
      return ip;
    8000387a:	bff9                	j	80003858 <namex+0x58>
      iunlockput(ip);
    8000387c:	8552                	mv	a0,s4
    8000387e:	c7dff0ef          	jal	800034fa <iunlockput>
      return 0;
    80003882:	8a4e                	mv	s4,s3
    80003884:	bfd1                	j	80003858 <namex+0x58>
  len = path - s;
    80003886:	40998633          	sub	a2,s3,s1
    8000388a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000388e:	099c5063          	bge	s8,s9,8000390e <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003892:	4639                	li	a2,14
    80003894:	85a6                	mv	a1,s1
    80003896:	8556                	mv	a0,s5
    80003898:	c8cfd0ef          	jal	80000d24 <memmove>
    8000389c:	84ce                	mv	s1,s3
  while(*path == '/')
    8000389e:	0004c783          	lbu	a5,0(s1)
    800038a2:	01279763          	bne	a5,s2,800038b0 <namex+0xb0>
    path++;
    800038a6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038a8:	0004c783          	lbu	a5,0(s1)
    800038ac:	ff278de3          	beq	a5,s2,800038a6 <namex+0xa6>
    ilock(ip);
    800038b0:	8552                	mv	a0,s4
    800038b2:	a3fff0ef          	jal	800032f0 <ilock>
    if(ip->type != T_DIR){
    800038b6:	044a1783          	lh	a5,68(s4)
    800038ba:	f9779be3          	bne	a5,s7,80003850 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800038be:	000b0563          	beqz	s6,800038c8 <namex+0xc8>
    800038c2:	0004c783          	lbu	a5,0(s1)
    800038c6:	d7dd                	beqz	a5,80003874 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038c8:	4601                	li	a2,0
    800038ca:	85d6                	mv	a1,s5
    800038cc:	8552                	mv	a0,s4
    800038ce:	e97ff0ef          	jal	80003764 <dirlookup>
    800038d2:	89aa                	mv	s3,a0
    800038d4:	d545                	beqz	a0,8000387c <namex+0x7c>
    iunlockput(ip);
    800038d6:	8552                	mv	a0,s4
    800038d8:	c23ff0ef          	jal	800034fa <iunlockput>
    ip = next;
    800038dc:	8a4e                	mv	s4,s3
  while(*path == '/')
    800038de:	0004c783          	lbu	a5,0(s1)
    800038e2:	01279763          	bne	a5,s2,800038f0 <namex+0xf0>
    path++;
    800038e6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038e8:	0004c783          	lbu	a5,0(s1)
    800038ec:	ff278de3          	beq	a5,s2,800038e6 <namex+0xe6>
  if(*path == 0)
    800038f0:	cb8d                	beqz	a5,80003922 <namex+0x122>
  while(*path != '/' && *path != 0)
    800038f2:	0004c783          	lbu	a5,0(s1)
    800038f6:	89a6                	mv	s3,s1
  len = path - s;
    800038f8:	4c81                	li	s9,0
    800038fa:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800038fc:	01278963          	beq	a5,s2,8000390e <namex+0x10e>
    80003900:	d3d9                	beqz	a5,80003886 <namex+0x86>
    path++;
    80003902:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003904:	0009c783          	lbu	a5,0(s3)
    80003908:	ff279ce3          	bne	a5,s2,80003900 <namex+0x100>
    8000390c:	bfad                	j	80003886 <namex+0x86>
    memmove(name, s, len);
    8000390e:	2601                	sext.w	a2,a2
    80003910:	85a6                	mv	a1,s1
    80003912:	8556                	mv	a0,s5
    80003914:	c10fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003918:	9cd6                	add	s9,s9,s5
    8000391a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000391e:	84ce                	mv	s1,s3
    80003920:	bfbd                	j	8000389e <namex+0x9e>
  if(nameiparent){
    80003922:	f20b0be3          	beqz	s6,80003858 <namex+0x58>
    iput(ip);
    80003926:	8552                	mv	a0,s4
    80003928:	b4bff0ef          	jal	80003472 <iput>
    return 0;
    8000392c:	4a01                	li	s4,0
    8000392e:	b72d                	j	80003858 <namex+0x58>

0000000080003930 <dirlink>:
{
    80003930:	7139                	addi	sp,sp,-64
    80003932:	fc06                	sd	ra,56(sp)
    80003934:	f822                	sd	s0,48(sp)
    80003936:	f04a                	sd	s2,32(sp)
    80003938:	ec4e                	sd	s3,24(sp)
    8000393a:	e852                	sd	s4,16(sp)
    8000393c:	0080                	addi	s0,sp,64
    8000393e:	892a                	mv	s2,a0
    80003940:	8a2e                	mv	s4,a1
    80003942:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003944:	4601                	li	a2,0
    80003946:	e1fff0ef          	jal	80003764 <dirlookup>
    8000394a:	e535                	bnez	a0,800039b6 <dirlink+0x86>
    8000394c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000394e:	04c92483          	lw	s1,76(s2)
    80003952:	c48d                	beqz	s1,8000397c <dirlink+0x4c>
    80003954:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003956:	4741                	li	a4,16
    80003958:	86a6                	mv	a3,s1
    8000395a:	fc040613          	addi	a2,s0,-64
    8000395e:	4581                	li	a1,0
    80003960:	854a                	mv	a0,s2
    80003962:	be3ff0ef          	jal	80003544 <readi>
    80003966:	47c1                	li	a5,16
    80003968:	04f51b63          	bne	a0,a5,800039be <dirlink+0x8e>
    if(de.inum == 0)
    8000396c:	fc045783          	lhu	a5,-64(s0)
    80003970:	c791                	beqz	a5,8000397c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003972:	24c1                	addiw	s1,s1,16
    80003974:	04c92783          	lw	a5,76(s2)
    80003978:	fcf4efe3          	bltu	s1,a5,80003956 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000397c:	4639                	li	a2,14
    8000397e:	85d2                	mv	a1,s4
    80003980:	fc240513          	addi	a0,s0,-62
    80003984:	c46fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003988:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000398c:	4741                	li	a4,16
    8000398e:	86a6                	mv	a3,s1
    80003990:	fc040613          	addi	a2,s0,-64
    80003994:	4581                	li	a1,0
    80003996:	854a                	mv	a0,s2
    80003998:	ca9ff0ef          	jal	80003640 <writei>
    8000399c:	1541                	addi	a0,a0,-16
    8000399e:	00a03533          	snez	a0,a0
    800039a2:	40a00533          	neg	a0,a0
    800039a6:	74a2                	ld	s1,40(sp)
}
    800039a8:	70e2                	ld	ra,56(sp)
    800039aa:	7442                	ld	s0,48(sp)
    800039ac:	7902                	ld	s2,32(sp)
    800039ae:	69e2                	ld	s3,24(sp)
    800039b0:	6a42                	ld	s4,16(sp)
    800039b2:	6121                	addi	sp,sp,64
    800039b4:	8082                	ret
    iput(ip);
    800039b6:	abdff0ef          	jal	80003472 <iput>
    return -1;
    800039ba:	557d                	li	a0,-1
    800039bc:	b7f5                	j	800039a8 <dirlink+0x78>
      panic("dirlink read");
    800039be:	00004517          	auipc	a0,0x4
    800039c2:	b8a50513          	addi	a0,a0,-1142 # 80007548 <etext+0x548>
    800039c6:	dcffc0ef          	jal	80000794 <panic>

00000000800039ca <namei>:

struct inode*
namei(char *path)
{
    800039ca:	1101                	addi	sp,sp,-32
    800039cc:	ec06                	sd	ra,24(sp)
    800039ce:	e822                	sd	s0,16(sp)
    800039d0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039d2:	fe040613          	addi	a2,s0,-32
    800039d6:	4581                	li	a1,0
    800039d8:	e29ff0ef          	jal	80003800 <namex>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	6105                	addi	sp,sp,32
    800039e2:	8082                	ret

00000000800039e4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800039e4:	1141                	addi	sp,sp,-16
    800039e6:	e406                	sd	ra,8(sp)
    800039e8:	e022                	sd	s0,0(sp)
    800039ea:	0800                	addi	s0,sp,16
    800039ec:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800039ee:	4585                	li	a1,1
    800039f0:	e11ff0ef          	jal	80003800 <namex>
}
    800039f4:	60a2                	ld	ra,8(sp)
    800039f6:	6402                	ld	s0,0(sp)
    800039f8:	0141                	addi	sp,sp,16
    800039fa:	8082                	ret

00000000800039fc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800039fc:	1101                	addi	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	e04a                	sd	s2,0(sp)
    80003a06:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a08:	0001f917          	auipc	s2,0x1f
    80003a0c:	f9890913          	addi	s2,s2,-104 # 800229a0 <log>
    80003a10:	01892583          	lw	a1,24(s2)
    80003a14:	02892503          	lw	a0,40(s2)
    80003a18:	9a0ff0ef          	jal	80002bb8 <bread>
    80003a1c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a1e:	02c92603          	lw	a2,44(s2)
    80003a22:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a24:	00c05f63          	blez	a2,80003a42 <write_head+0x46>
    80003a28:	0001f717          	auipc	a4,0x1f
    80003a2c:	fa870713          	addi	a4,a4,-88 # 800229d0 <log+0x30>
    80003a30:	87aa                	mv	a5,a0
    80003a32:	060a                	slli	a2,a2,0x2
    80003a34:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a36:	4314                	lw	a3,0(a4)
    80003a38:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a3a:	0711                	addi	a4,a4,4
    80003a3c:	0791                	addi	a5,a5,4
    80003a3e:	fec79ce3          	bne	a5,a2,80003a36 <write_head+0x3a>
  }
  bwrite(buf);
    80003a42:	8526                	mv	a0,s1
    80003a44:	a4aff0ef          	jal	80002c8e <bwrite>
  brelse(buf);
    80003a48:	8526                	mv	a0,s1
    80003a4a:	a76ff0ef          	jal	80002cc0 <brelse>
}
    80003a4e:	60e2                	ld	ra,24(sp)
    80003a50:	6442                	ld	s0,16(sp)
    80003a52:	64a2                	ld	s1,8(sp)
    80003a54:	6902                	ld	s2,0(sp)
    80003a56:	6105                	addi	sp,sp,32
    80003a58:	8082                	ret

0000000080003a5a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a5a:	0001f797          	auipc	a5,0x1f
    80003a5e:	f727a783          	lw	a5,-142(a5) # 800229cc <log+0x2c>
    80003a62:	08f05f63          	blez	a5,80003b00 <install_trans+0xa6>
{
    80003a66:	7139                	addi	sp,sp,-64
    80003a68:	fc06                	sd	ra,56(sp)
    80003a6a:	f822                	sd	s0,48(sp)
    80003a6c:	f426                	sd	s1,40(sp)
    80003a6e:	f04a                	sd	s2,32(sp)
    80003a70:	ec4e                	sd	s3,24(sp)
    80003a72:	e852                	sd	s4,16(sp)
    80003a74:	e456                	sd	s5,8(sp)
    80003a76:	e05a                	sd	s6,0(sp)
    80003a78:	0080                	addi	s0,sp,64
    80003a7a:	8b2a                	mv	s6,a0
    80003a7c:	0001fa97          	auipc	s5,0x1f
    80003a80:	f54a8a93          	addi	s5,s5,-172 # 800229d0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a84:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a86:	0001f997          	auipc	s3,0x1f
    80003a8a:	f1a98993          	addi	s3,s3,-230 # 800229a0 <log>
    80003a8e:	a829                	j	80003aa8 <install_trans+0x4e>
    brelse(lbuf);
    80003a90:	854a                	mv	a0,s2
    80003a92:	a2eff0ef          	jal	80002cc0 <brelse>
    brelse(dbuf);
    80003a96:	8526                	mv	a0,s1
    80003a98:	a28ff0ef          	jal	80002cc0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a9c:	2a05                	addiw	s4,s4,1
    80003a9e:	0a91                	addi	s5,s5,4
    80003aa0:	02c9a783          	lw	a5,44(s3)
    80003aa4:	04fa5463          	bge	s4,a5,80003aec <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003aa8:	0189a583          	lw	a1,24(s3)
    80003aac:	014585bb          	addw	a1,a1,s4
    80003ab0:	2585                	addiw	a1,a1,1
    80003ab2:	0289a503          	lw	a0,40(s3)
    80003ab6:	902ff0ef          	jal	80002bb8 <bread>
    80003aba:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003abc:	000aa583          	lw	a1,0(s5)
    80003ac0:	0289a503          	lw	a0,40(s3)
    80003ac4:	8f4ff0ef          	jal	80002bb8 <bread>
    80003ac8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003aca:	40000613          	li	a2,1024
    80003ace:	05890593          	addi	a1,s2,88
    80003ad2:	05850513          	addi	a0,a0,88
    80003ad6:	a4efd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ada:	8526                	mv	a0,s1
    80003adc:	9b2ff0ef          	jal	80002c8e <bwrite>
    if(recovering == 0)
    80003ae0:	fa0b18e3          	bnez	s6,80003a90 <install_trans+0x36>
      bunpin(dbuf);
    80003ae4:	8526                	mv	a0,s1
    80003ae6:	a96ff0ef          	jal	80002d7c <bunpin>
    80003aea:	b75d                	j	80003a90 <install_trans+0x36>
}
    80003aec:	70e2                	ld	ra,56(sp)
    80003aee:	7442                	ld	s0,48(sp)
    80003af0:	74a2                	ld	s1,40(sp)
    80003af2:	7902                	ld	s2,32(sp)
    80003af4:	69e2                	ld	s3,24(sp)
    80003af6:	6a42                	ld	s4,16(sp)
    80003af8:	6aa2                	ld	s5,8(sp)
    80003afa:	6b02                	ld	s6,0(sp)
    80003afc:	6121                	addi	sp,sp,64
    80003afe:	8082                	ret
    80003b00:	8082                	ret

0000000080003b02 <initlog>:
{
    80003b02:	7179                	addi	sp,sp,-48
    80003b04:	f406                	sd	ra,40(sp)
    80003b06:	f022                	sd	s0,32(sp)
    80003b08:	ec26                	sd	s1,24(sp)
    80003b0a:	e84a                	sd	s2,16(sp)
    80003b0c:	e44e                	sd	s3,8(sp)
    80003b0e:	1800                	addi	s0,sp,48
    80003b10:	892a                	mv	s2,a0
    80003b12:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b14:	0001f497          	auipc	s1,0x1f
    80003b18:	e8c48493          	addi	s1,s1,-372 # 800229a0 <log>
    80003b1c:	00004597          	auipc	a1,0x4
    80003b20:	a3c58593          	addi	a1,a1,-1476 # 80007558 <etext+0x558>
    80003b24:	8526                	mv	a0,s1
    80003b26:	84efd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003b2a:	0149a583          	lw	a1,20(s3)
    80003b2e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b30:	0109a783          	lw	a5,16(s3)
    80003b34:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b36:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b3a:	854a                	mv	a0,s2
    80003b3c:	87cff0ef          	jal	80002bb8 <bread>
  log.lh.n = lh->n;
    80003b40:	4d30                	lw	a2,88(a0)
    80003b42:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b44:	00c05f63          	blez	a2,80003b62 <initlog+0x60>
    80003b48:	87aa                	mv	a5,a0
    80003b4a:	0001f717          	auipc	a4,0x1f
    80003b4e:	e8670713          	addi	a4,a4,-378 # 800229d0 <log+0x30>
    80003b52:	060a                	slli	a2,a2,0x2
    80003b54:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b56:	4ff4                	lw	a3,92(a5)
    80003b58:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b5a:	0791                	addi	a5,a5,4
    80003b5c:	0711                	addi	a4,a4,4
    80003b5e:	fec79ce3          	bne	a5,a2,80003b56 <initlog+0x54>
  brelse(buf);
    80003b62:	95eff0ef          	jal	80002cc0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b66:	4505                	li	a0,1
    80003b68:	ef3ff0ef          	jal	80003a5a <install_trans>
  log.lh.n = 0;
    80003b6c:	0001f797          	auipc	a5,0x1f
    80003b70:	e607a023          	sw	zero,-416(a5) # 800229cc <log+0x2c>
  write_head(); // clear the log
    80003b74:	e89ff0ef          	jal	800039fc <write_head>
}
    80003b78:	70a2                	ld	ra,40(sp)
    80003b7a:	7402                	ld	s0,32(sp)
    80003b7c:	64e2                	ld	s1,24(sp)
    80003b7e:	6942                	ld	s2,16(sp)
    80003b80:	69a2                	ld	s3,8(sp)
    80003b82:	6145                	addi	sp,sp,48
    80003b84:	8082                	ret

0000000080003b86 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003b86:	1101                	addi	sp,sp,-32
    80003b88:	ec06                	sd	ra,24(sp)
    80003b8a:	e822                	sd	s0,16(sp)
    80003b8c:	e426                	sd	s1,8(sp)
    80003b8e:	e04a                	sd	s2,0(sp)
    80003b90:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003b92:	0001f517          	auipc	a0,0x1f
    80003b96:	e0e50513          	addi	a0,a0,-498 # 800229a0 <log>
    80003b9a:	85afd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003b9e:	0001f497          	auipc	s1,0x1f
    80003ba2:	e0248493          	addi	s1,s1,-510 # 800229a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ba6:	4979                	li	s2,30
    80003ba8:	a029                	j	80003bb2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003baa:	85a6                	mv	a1,s1
    80003bac:	8526                	mv	a0,s1
    80003bae:	b70fe0ef          	jal	80001f1e <sleep>
    if(log.committing){
    80003bb2:	50dc                	lw	a5,36(s1)
    80003bb4:	fbfd                	bnez	a5,80003baa <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bb6:	5098                	lw	a4,32(s1)
    80003bb8:	2705                	addiw	a4,a4,1
    80003bba:	0027179b          	slliw	a5,a4,0x2
    80003bbe:	9fb9                	addw	a5,a5,a4
    80003bc0:	0017979b          	slliw	a5,a5,0x1
    80003bc4:	54d4                	lw	a3,44(s1)
    80003bc6:	9fb5                	addw	a5,a5,a3
    80003bc8:	00f95763          	bge	s2,a5,80003bd6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003bcc:	85a6                	mv	a1,s1
    80003bce:	8526                	mv	a0,s1
    80003bd0:	b4efe0ef          	jal	80001f1e <sleep>
    80003bd4:	bff9                	j	80003bb2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003bd6:	0001f517          	auipc	a0,0x1f
    80003bda:	dca50513          	addi	a0,a0,-566 # 800229a0 <log>
    80003bde:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003be0:	8acfd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003be4:	60e2                	ld	ra,24(sp)
    80003be6:	6442                	ld	s0,16(sp)
    80003be8:	64a2                	ld	s1,8(sp)
    80003bea:	6902                	ld	s2,0(sp)
    80003bec:	6105                	addi	sp,sp,32
    80003bee:	8082                	ret

0000000080003bf0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003bf0:	7139                	addi	sp,sp,-64
    80003bf2:	fc06                	sd	ra,56(sp)
    80003bf4:	f822                	sd	s0,48(sp)
    80003bf6:	f426                	sd	s1,40(sp)
    80003bf8:	f04a                	sd	s2,32(sp)
    80003bfa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003bfc:	0001f497          	auipc	s1,0x1f
    80003c00:	da448493          	addi	s1,s1,-604 # 800229a0 <log>
    80003c04:	8526                	mv	a0,s1
    80003c06:	feffc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003c0a:	509c                	lw	a5,32(s1)
    80003c0c:	37fd                	addiw	a5,a5,-1
    80003c0e:	0007891b          	sext.w	s2,a5
    80003c12:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003c14:	50dc                	lw	a5,36(s1)
    80003c16:	ef9d                	bnez	a5,80003c54 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c18:	04091763          	bnez	s2,80003c66 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c1c:	0001f497          	auipc	s1,0x1f
    80003c20:	d8448493          	addi	s1,s1,-636 # 800229a0 <log>
    80003c24:	4785                	li	a5,1
    80003c26:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c28:	8526                	mv	a0,s1
    80003c2a:	862fd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c2e:	54dc                	lw	a5,44(s1)
    80003c30:	04f04b63          	bgtz	a5,80003c86 <end_op+0x96>
    acquire(&log.lock);
    80003c34:	0001f497          	auipc	s1,0x1f
    80003c38:	d6c48493          	addi	s1,s1,-660 # 800229a0 <log>
    80003c3c:	8526                	mv	a0,s1
    80003c3e:	fb7fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003c42:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c46:	8526                	mv	a0,s1
    80003c48:	b22fe0ef          	jal	80001f6a <wakeup>
    release(&log.lock);
    80003c4c:	8526                	mv	a0,s1
    80003c4e:	83efd0ef          	jal	80000c8c <release>
}
    80003c52:	a025                	j	80003c7a <end_op+0x8a>
    80003c54:	ec4e                	sd	s3,24(sp)
    80003c56:	e852                	sd	s4,16(sp)
    80003c58:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003c5a:	00004517          	auipc	a0,0x4
    80003c5e:	90650513          	addi	a0,a0,-1786 # 80007560 <etext+0x560>
    80003c62:	b33fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003c66:	0001f497          	auipc	s1,0x1f
    80003c6a:	d3a48493          	addi	s1,s1,-710 # 800229a0 <log>
    80003c6e:	8526                	mv	a0,s1
    80003c70:	afafe0ef          	jal	80001f6a <wakeup>
  release(&log.lock);
    80003c74:	8526                	mv	a0,s1
    80003c76:	816fd0ef          	jal	80000c8c <release>
}
    80003c7a:	70e2                	ld	ra,56(sp)
    80003c7c:	7442                	ld	s0,48(sp)
    80003c7e:	74a2                	ld	s1,40(sp)
    80003c80:	7902                	ld	s2,32(sp)
    80003c82:	6121                	addi	sp,sp,64
    80003c84:	8082                	ret
    80003c86:	ec4e                	sd	s3,24(sp)
    80003c88:	e852                	sd	s4,16(sp)
    80003c8a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c8c:	0001fa97          	auipc	s5,0x1f
    80003c90:	d44a8a93          	addi	s5,s5,-700 # 800229d0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c94:	0001fa17          	auipc	s4,0x1f
    80003c98:	d0ca0a13          	addi	s4,s4,-756 # 800229a0 <log>
    80003c9c:	018a2583          	lw	a1,24(s4)
    80003ca0:	012585bb          	addw	a1,a1,s2
    80003ca4:	2585                	addiw	a1,a1,1
    80003ca6:	028a2503          	lw	a0,40(s4)
    80003caa:	f0ffe0ef          	jal	80002bb8 <bread>
    80003cae:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cb0:	000aa583          	lw	a1,0(s5)
    80003cb4:	028a2503          	lw	a0,40(s4)
    80003cb8:	f01fe0ef          	jal	80002bb8 <bread>
    80003cbc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003cbe:	40000613          	li	a2,1024
    80003cc2:	05850593          	addi	a1,a0,88
    80003cc6:	05848513          	addi	a0,s1,88
    80003cca:	85afd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003cce:	8526                	mv	a0,s1
    80003cd0:	fbffe0ef          	jal	80002c8e <bwrite>
    brelse(from);
    80003cd4:	854e                	mv	a0,s3
    80003cd6:	febfe0ef          	jal	80002cc0 <brelse>
    brelse(to);
    80003cda:	8526                	mv	a0,s1
    80003cdc:	fe5fe0ef          	jal	80002cc0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ce0:	2905                	addiw	s2,s2,1
    80003ce2:	0a91                	addi	s5,s5,4
    80003ce4:	02ca2783          	lw	a5,44(s4)
    80003ce8:	faf94ae3          	blt	s2,a5,80003c9c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003cec:	d11ff0ef          	jal	800039fc <write_head>
    install_trans(0); // Now install writes to home locations
    80003cf0:	4501                	li	a0,0
    80003cf2:	d69ff0ef          	jal	80003a5a <install_trans>
    log.lh.n = 0;
    80003cf6:	0001f797          	auipc	a5,0x1f
    80003cfa:	cc07ab23          	sw	zero,-810(a5) # 800229cc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003cfe:	cffff0ef          	jal	800039fc <write_head>
    80003d02:	69e2                	ld	s3,24(sp)
    80003d04:	6a42                	ld	s4,16(sp)
    80003d06:	6aa2                	ld	s5,8(sp)
    80003d08:	b735                	j	80003c34 <end_op+0x44>

0000000080003d0a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d0a:	1101                	addi	sp,sp,-32
    80003d0c:	ec06                	sd	ra,24(sp)
    80003d0e:	e822                	sd	s0,16(sp)
    80003d10:	e426                	sd	s1,8(sp)
    80003d12:	e04a                	sd	s2,0(sp)
    80003d14:	1000                	addi	s0,sp,32
    80003d16:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d18:	0001f917          	auipc	s2,0x1f
    80003d1c:	c8890913          	addi	s2,s2,-888 # 800229a0 <log>
    80003d20:	854a                	mv	a0,s2
    80003d22:	ed3fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d26:	02c92603          	lw	a2,44(s2)
    80003d2a:	47f5                	li	a5,29
    80003d2c:	06c7c363          	blt	a5,a2,80003d92 <log_write+0x88>
    80003d30:	0001f797          	auipc	a5,0x1f
    80003d34:	c8c7a783          	lw	a5,-884(a5) # 800229bc <log+0x1c>
    80003d38:	37fd                	addiw	a5,a5,-1
    80003d3a:	04f65c63          	bge	a2,a5,80003d92 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d3e:	0001f797          	auipc	a5,0x1f
    80003d42:	c827a783          	lw	a5,-894(a5) # 800229c0 <log+0x20>
    80003d46:	04f05c63          	blez	a5,80003d9e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d4a:	4781                	li	a5,0
    80003d4c:	04c05f63          	blez	a2,80003daa <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d50:	44cc                	lw	a1,12(s1)
    80003d52:	0001f717          	auipc	a4,0x1f
    80003d56:	c7e70713          	addi	a4,a4,-898 # 800229d0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d5a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d5c:	4314                	lw	a3,0(a4)
    80003d5e:	04b68663          	beq	a3,a1,80003daa <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d62:	2785                	addiw	a5,a5,1
    80003d64:	0711                	addi	a4,a4,4
    80003d66:	fef61be3          	bne	a2,a5,80003d5c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d6a:	0621                	addi	a2,a2,8
    80003d6c:	060a                	slli	a2,a2,0x2
    80003d6e:	0001f797          	auipc	a5,0x1f
    80003d72:	c3278793          	addi	a5,a5,-974 # 800229a0 <log>
    80003d76:	97b2                	add	a5,a5,a2
    80003d78:	44d8                	lw	a4,12(s1)
    80003d7a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	fcbfe0ef          	jal	80002d48 <bpin>
    log.lh.n++;
    80003d82:	0001f717          	auipc	a4,0x1f
    80003d86:	c1e70713          	addi	a4,a4,-994 # 800229a0 <log>
    80003d8a:	575c                	lw	a5,44(a4)
    80003d8c:	2785                	addiw	a5,a5,1
    80003d8e:	d75c                	sw	a5,44(a4)
    80003d90:	a80d                	j	80003dc2 <log_write+0xb8>
    panic("too big a transaction");
    80003d92:	00003517          	auipc	a0,0x3
    80003d96:	7de50513          	addi	a0,a0,2014 # 80007570 <etext+0x570>
    80003d9a:	9fbfc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003d9e:	00003517          	auipc	a0,0x3
    80003da2:	7ea50513          	addi	a0,a0,2026 # 80007588 <etext+0x588>
    80003da6:	9effc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003daa:	00878693          	addi	a3,a5,8
    80003dae:	068a                	slli	a3,a3,0x2
    80003db0:	0001f717          	auipc	a4,0x1f
    80003db4:	bf070713          	addi	a4,a4,-1040 # 800229a0 <log>
    80003db8:	9736                	add	a4,a4,a3
    80003dba:	44d4                	lw	a3,12(s1)
    80003dbc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003dbe:	faf60fe3          	beq	a2,a5,80003d7c <log_write+0x72>
  }
  release(&log.lock);
    80003dc2:	0001f517          	auipc	a0,0x1f
    80003dc6:	bde50513          	addi	a0,a0,-1058 # 800229a0 <log>
    80003dca:	ec3fc0ef          	jal	80000c8c <release>
}
    80003dce:	60e2                	ld	ra,24(sp)
    80003dd0:	6442                	ld	s0,16(sp)
    80003dd2:	64a2                	ld	s1,8(sp)
    80003dd4:	6902                	ld	s2,0(sp)
    80003dd6:	6105                	addi	sp,sp,32
    80003dd8:	8082                	ret

0000000080003dda <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003dda:	1101                	addi	sp,sp,-32
    80003ddc:	ec06                	sd	ra,24(sp)
    80003dde:	e822                	sd	s0,16(sp)
    80003de0:	e426                	sd	s1,8(sp)
    80003de2:	e04a                	sd	s2,0(sp)
    80003de4:	1000                	addi	s0,sp,32
    80003de6:	84aa                	mv	s1,a0
    80003de8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003dea:	00003597          	auipc	a1,0x3
    80003dee:	7be58593          	addi	a1,a1,1982 # 800075a8 <etext+0x5a8>
    80003df2:	0521                	addi	a0,a0,8
    80003df4:	d81fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003df8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003dfc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e00:	0204a423          	sw	zero,40(s1)
}
    80003e04:	60e2                	ld	ra,24(sp)
    80003e06:	6442                	ld	s0,16(sp)
    80003e08:	64a2                	ld	s1,8(sp)
    80003e0a:	6902                	ld	s2,0(sp)
    80003e0c:	6105                	addi	sp,sp,32
    80003e0e:	8082                	ret

0000000080003e10 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e10:	1101                	addi	sp,sp,-32
    80003e12:	ec06                	sd	ra,24(sp)
    80003e14:	e822                	sd	s0,16(sp)
    80003e16:	e426                	sd	s1,8(sp)
    80003e18:	e04a                	sd	s2,0(sp)
    80003e1a:	1000                	addi	s0,sp,32
    80003e1c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e1e:	00850913          	addi	s2,a0,8
    80003e22:	854a                	mv	a0,s2
    80003e24:	dd1fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003e28:	409c                	lw	a5,0(s1)
    80003e2a:	c799                	beqz	a5,80003e38 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e2c:	85ca                	mv	a1,s2
    80003e2e:	8526                	mv	a0,s1
    80003e30:	8eefe0ef          	jal	80001f1e <sleep>
  while (lk->locked) {
    80003e34:	409c                	lw	a5,0(s1)
    80003e36:	fbfd                	bnez	a5,80003e2c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e38:	4785                	li	a5,1
    80003e3a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e3c:	aa5fd0ef          	jal	800018e0 <myproc>
    80003e40:	591c                	lw	a5,48(a0)
    80003e42:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e44:	854a                	mv	a0,s2
    80003e46:	e47fc0ef          	jal	80000c8c <release>
}
    80003e4a:	60e2                	ld	ra,24(sp)
    80003e4c:	6442                	ld	s0,16(sp)
    80003e4e:	64a2                	ld	s1,8(sp)
    80003e50:	6902                	ld	s2,0(sp)
    80003e52:	6105                	addi	sp,sp,32
    80003e54:	8082                	ret

0000000080003e56 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e56:	1101                	addi	sp,sp,-32
    80003e58:	ec06                	sd	ra,24(sp)
    80003e5a:	e822                	sd	s0,16(sp)
    80003e5c:	e426                	sd	s1,8(sp)
    80003e5e:	e04a                	sd	s2,0(sp)
    80003e60:	1000                	addi	s0,sp,32
    80003e62:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e64:	00850913          	addi	s2,a0,8
    80003e68:	854a                	mv	a0,s2
    80003e6a:	d8bfc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003e6e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e72:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e76:	8526                	mv	a0,s1
    80003e78:	8f2fe0ef          	jal	80001f6a <wakeup>
  release(&lk->lk);
    80003e7c:	854a                	mv	a0,s2
    80003e7e:	e0ffc0ef          	jal	80000c8c <release>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6902                	ld	s2,0(sp)
    80003e8a:	6105                	addi	sp,sp,32
    80003e8c:	8082                	ret

0000000080003e8e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e8e:	7179                	addi	sp,sp,-48
    80003e90:	f406                	sd	ra,40(sp)
    80003e92:	f022                	sd	s0,32(sp)
    80003e94:	ec26                	sd	s1,24(sp)
    80003e96:	e84a                	sd	s2,16(sp)
    80003e98:	1800                	addi	s0,sp,48
    80003e9a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e9c:	00850913          	addi	s2,a0,8
    80003ea0:	854a                	mv	a0,s2
    80003ea2:	d53fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ea6:	409c                	lw	a5,0(s1)
    80003ea8:	ef81                	bnez	a5,80003ec0 <holdingsleep+0x32>
    80003eaa:	4481                	li	s1,0
  release(&lk->lk);
    80003eac:	854a                	mv	a0,s2
    80003eae:	ddffc0ef          	jal	80000c8c <release>
  return r;
}
    80003eb2:	8526                	mv	a0,s1
    80003eb4:	70a2                	ld	ra,40(sp)
    80003eb6:	7402                	ld	s0,32(sp)
    80003eb8:	64e2                	ld	s1,24(sp)
    80003eba:	6942                	ld	s2,16(sp)
    80003ebc:	6145                	addi	sp,sp,48
    80003ebe:	8082                	ret
    80003ec0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ec2:	0284a983          	lw	s3,40(s1)
    80003ec6:	a1bfd0ef          	jal	800018e0 <myproc>
    80003eca:	5904                	lw	s1,48(a0)
    80003ecc:	413484b3          	sub	s1,s1,s3
    80003ed0:	0014b493          	seqz	s1,s1
    80003ed4:	69a2                	ld	s3,8(sp)
    80003ed6:	bfd9                	j	80003eac <holdingsleep+0x1e>

0000000080003ed8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ed8:	1141                	addi	sp,sp,-16
    80003eda:	e406                	sd	ra,8(sp)
    80003edc:	e022                	sd	s0,0(sp)
    80003ede:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ee0:	00003597          	auipc	a1,0x3
    80003ee4:	6d858593          	addi	a1,a1,1752 # 800075b8 <etext+0x5b8>
    80003ee8:	0001f517          	auipc	a0,0x1f
    80003eec:	c0050513          	addi	a0,a0,-1024 # 80022ae8 <ftable>
    80003ef0:	c85fc0ef          	jal	80000b74 <initlock>
}
    80003ef4:	60a2                	ld	ra,8(sp)
    80003ef6:	6402                	ld	s0,0(sp)
    80003ef8:	0141                	addi	sp,sp,16
    80003efa:	8082                	ret

0000000080003efc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	e426                	sd	s1,8(sp)
    80003f04:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f06:	0001f517          	auipc	a0,0x1f
    80003f0a:	be250513          	addi	a0,a0,-1054 # 80022ae8 <ftable>
    80003f0e:	ce7fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f12:	0001f497          	auipc	s1,0x1f
    80003f16:	bee48493          	addi	s1,s1,-1042 # 80022b00 <ftable+0x18>
    80003f1a:	00020717          	auipc	a4,0x20
    80003f1e:	b8670713          	addi	a4,a4,-1146 # 80023aa0 <disk>
    if(f->ref == 0){
    80003f22:	40dc                	lw	a5,4(s1)
    80003f24:	cf89                	beqz	a5,80003f3e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f26:	02848493          	addi	s1,s1,40
    80003f2a:	fee49ce3          	bne	s1,a4,80003f22 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f2e:	0001f517          	auipc	a0,0x1f
    80003f32:	bba50513          	addi	a0,a0,-1094 # 80022ae8 <ftable>
    80003f36:	d57fc0ef          	jal	80000c8c <release>
  return 0;
    80003f3a:	4481                	li	s1,0
    80003f3c:	a809                	j	80003f4e <filealloc+0x52>
      f->ref = 1;
    80003f3e:	4785                	li	a5,1
    80003f40:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f42:	0001f517          	auipc	a0,0x1f
    80003f46:	ba650513          	addi	a0,a0,-1114 # 80022ae8 <ftable>
    80003f4a:	d43fc0ef          	jal	80000c8c <release>
}
    80003f4e:	8526                	mv	a0,s1
    80003f50:	60e2                	ld	ra,24(sp)
    80003f52:	6442                	ld	s0,16(sp)
    80003f54:	64a2                	ld	s1,8(sp)
    80003f56:	6105                	addi	sp,sp,32
    80003f58:	8082                	ret

0000000080003f5a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f5a:	1101                	addi	sp,sp,-32
    80003f5c:	ec06                	sd	ra,24(sp)
    80003f5e:	e822                	sd	s0,16(sp)
    80003f60:	e426                	sd	s1,8(sp)
    80003f62:	1000                	addi	s0,sp,32
    80003f64:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f66:	0001f517          	auipc	a0,0x1f
    80003f6a:	b8250513          	addi	a0,a0,-1150 # 80022ae8 <ftable>
    80003f6e:	c87fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f72:	40dc                	lw	a5,4(s1)
    80003f74:	02f05063          	blez	a5,80003f94 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f78:	2785                	addiw	a5,a5,1
    80003f7a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003f7c:	0001f517          	auipc	a0,0x1f
    80003f80:	b6c50513          	addi	a0,a0,-1172 # 80022ae8 <ftable>
    80003f84:	d09fc0ef          	jal	80000c8c <release>
  return f;
}
    80003f88:	8526                	mv	a0,s1
    80003f8a:	60e2                	ld	ra,24(sp)
    80003f8c:	6442                	ld	s0,16(sp)
    80003f8e:	64a2                	ld	s1,8(sp)
    80003f90:	6105                	addi	sp,sp,32
    80003f92:	8082                	ret
    panic("filedup");
    80003f94:	00003517          	auipc	a0,0x3
    80003f98:	62c50513          	addi	a0,a0,1580 # 800075c0 <etext+0x5c0>
    80003f9c:	ff8fc0ef          	jal	80000794 <panic>

0000000080003fa0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003fa0:	7139                	addi	sp,sp,-64
    80003fa2:	fc06                	sd	ra,56(sp)
    80003fa4:	f822                	sd	s0,48(sp)
    80003fa6:	f426                	sd	s1,40(sp)
    80003fa8:	0080                	addi	s0,sp,64
    80003faa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003fac:	0001f517          	auipc	a0,0x1f
    80003fb0:	b3c50513          	addi	a0,a0,-1220 # 80022ae8 <ftable>
    80003fb4:	c41fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003fb8:	40dc                	lw	a5,4(s1)
    80003fba:	04f05a63          	blez	a5,8000400e <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003fbe:	37fd                	addiw	a5,a5,-1
    80003fc0:	0007871b          	sext.w	a4,a5
    80003fc4:	c0dc                	sw	a5,4(s1)
    80003fc6:	04e04e63          	bgtz	a4,80004022 <fileclose+0x82>
    80003fca:	f04a                	sd	s2,32(sp)
    80003fcc:	ec4e                	sd	s3,24(sp)
    80003fce:	e852                	sd	s4,16(sp)
    80003fd0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003fd2:	0004a903          	lw	s2,0(s1)
    80003fd6:	0094ca83          	lbu	s5,9(s1)
    80003fda:	0104ba03          	ld	s4,16(s1)
    80003fde:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003fe2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003fe6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003fea:	0001f517          	auipc	a0,0x1f
    80003fee:	afe50513          	addi	a0,a0,-1282 # 80022ae8 <ftable>
    80003ff2:	c9bfc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003ff6:	4785                	li	a5,1
    80003ff8:	04f90063          	beq	s2,a5,80004038 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003ffc:	3979                	addiw	s2,s2,-2
    80003ffe:	4785                	li	a5,1
    80004000:	0527f563          	bgeu	a5,s2,8000404a <fileclose+0xaa>
    80004004:	7902                	ld	s2,32(sp)
    80004006:	69e2                	ld	s3,24(sp)
    80004008:	6a42                	ld	s4,16(sp)
    8000400a:	6aa2                	ld	s5,8(sp)
    8000400c:	a00d                	j	8000402e <fileclose+0x8e>
    8000400e:	f04a                	sd	s2,32(sp)
    80004010:	ec4e                	sd	s3,24(sp)
    80004012:	e852                	sd	s4,16(sp)
    80004014:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004016:	00003517          	auipc	a0,0x3
    8000401a:	5b250513          	addi	a0,a0,1458 # 800075c8 <etext+0x5c8>
    8000401e:	f76fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004022:	0001f517          	auipc	a0,0x1f
    80004026:	ac650513          	addi	a0,a0,-1338 # 80022ae8 <ftable>
    8000402a:	c63fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000402e:	70e2                	ld	ra,56(sp)
    80004030:	7442                	ld	s0,48(sp)
    80004032:	74a2                	ld	s1,40(sp)
    80004034:	6121                	addi	sp,sp,64
    80004036:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004038:	85d6                	mv	a1,s5
    8000403a:	8552                	mv	a0,s4
    8000403c:	336000ef          	jal	80004372 <pipeclose>
    80004040:	7902                	ld	s2,32(sp)
    80004042:	69e2                	ld	s3,24(sp)
    80004044:	6a42                	ld	s4,16(sp)
    80004046:	6aa2                	ld	s5,8(sp)
    80004048:	b7dd                	j	8000402e <fileclose+0x8e>
    begin_op();
    8000404a:	b3dff0ef          	jal	80003b86 <begin_op>
    iput(ff.ip);
    8000404e:	854e                	mv	a0,s3
    80004050:	c22ff0ef          	jal	80003472 <iput>
    end_op();
    80004054:	b9dff0ef          	jal	80003bf0 <end_op>
    80004058:	7902                	ld	s2,32(sp)
    8000405a:	69e2                	ld	s3,24(sp)
    8000405c:	6a42                	ld	s4,16(sp)
    8000405e:	6aa2                	ld	s5,8(sp)
    80004060:	b7f9                	j	8000402e <fileclose+0x8e>

0000000080004062 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004062:	715d                	addi	sp,sp,-80
    80004064:	e486                	sd	ra,72(sp)
    80004066:	e0a2                	sd	s0,64(sp)
    80004068:	fc26                	sd	s1,56(sp)
    8000406a:	f44e                	sd	s3,40(sp)
    8000406c:	0880                	addi	s0,sp,80
    8000406e:	84aa                	mv	s1,a0
    80004070:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004072:	86ffd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004076:	409c                	lw	a5,0(s1)
    80004078:	37f9                	addiw	a5,a5,-2
    8000407a:	4705                	li	a4,1
    8000407c:	04f76063          	bltu	a4,a5,800040bc <filestat+0x5a>
    80004080:	f84a                	sd	s2,48(sp)
    80004082:	892a                	mv	s2,a0
    ilock(f->ip);
    80004084:	6c88                	ld	a0,24(s1)
    80004086:	a6aff0ef          	jal	800032f0 <ilock>
    stati(f->ip, &st);
    8000408a:	fb840593          	addi	a1,s0,-72
    8000408e:	6c88                	ld	a0,24(s1)
    80004090:	c8aff0ef          	jal	8000351a <stati>
    iunlock(f->ip);
    80004094:	6c88                	ld	a0,24(s1)
    80004096:	b08ff0ef          	jal	8000339e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000409a:	46e1                	li	a3,24
    8000409c:	fb840613          	addi	a2,s0,-72
    800040a0:	85ce                	mv	a1,s3
    800040a2:	05093503          	ld	a0,80(s2)
    800040a6:	cacfd0ef          	jal	80001552 <copyout>
    800040aa:	41f5551b          	sraiw	a0,a0,0x1f
    800040ae:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040b0:	60a6                	ld	ra,72(sp)
    800040b2:	6406                	ld	s0,64(sp)
    800040b4:	74e2                	ld	s1,56(sp)
    800040b6:	79a2                	ld	s3,40(sp)
    800040b8:	6161                	addi	sp,sp,80
    800040ba:	8082                	ret
  return -1;
    800040bc:	557d                	li	a0,-1
    800040be:	bfcd                	j	800040b0 <filestat+0x4e>

00000000800040c0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040c0:	7179                	addi	sp,sp,-48
    800040c2:	f406                	sd	ra,40(sp)
    800040c4:	f022                	sd	s0,32(sp)
    800040c6:	e84a                	sd	s2,16(sp)
    800040c8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800040ca:	00854783          	lbu	a5,8(a0)
    800040ce:	cfd1                	beqz	a5,8000416a <fileread+0xaa>
    800040d0:	ec26                	sd	s1,24(sp)
    800040d2:	e44e                	sd	s3,8(sp)
    800040d4:	84aa                	mv	s1,a0
    800040d6:	89ae                	mv	s3,a1
    800040d8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800040da:	411c                	lw	a5,0(a0)
    800040dc:	4705                	li	a4,1
    800040de:	04e78363          	beq	a5,a4,80004124 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040e2:	470d                	li	a4,3
    800040e4:	04e78763          	beq	a5,a4,80004132 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800040e8:	4709                	li	a4,2
    800040ea:	06e79a63          	bne	a5,a4,8000415e <fileread+0x9e>
    ilock(f->ip);
    800040ee:	6d08                	ld	a0,24(a0)
    800040f0:	a00ff0ef          	jal	800032f0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800040f4:	874a                	mv	a4,s2
    800040f6:	5094                	lw	a3,32(s1)
    800040f8:	864e                	mv	a2,s3
    800040fa:	4585                	li	a1,1
    800040fc:	6c88                	ld	a0,24(s1)
    800040fe:	c46ff0ef          	jal	80003544 <readi>
    80004102:	892a                	mv	s2,a0
    80004104:	00a05563          	blez	a0,8000410e <fileread+0x4e>
      f->off += r;
    80004108:	509c                	lw	a5,32(s1)
    8000410a:	9fa9                	addw	a5,a5,a0
    8000410c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000410e:	6c88                	ld	a0,24(s1)
    80004110:	a8eff0ef          	jal	8000339e <iunlock>
    80004114:	64e2                	ld	s1,24(sp)
    80004116:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004118:	854a                	mv	a0,s2
    8000411a:	70a2                	ld	ra,40(sp)
    8000411c:	7402                	ld	s0,32(sp)
    8000411e:	6942                	ld	s2,16(sp)
    80004120:	6145                	addi	sp,sp,48
    80004122:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004124:	6908                	ld	a0,16(a0)
    80004126:	388000ef          	jal	800044ae <piperead>
    8000412a:	892a                	mv	s2,a0
    8000412c:	64e2                	ld	s1,24(sp)
    8000412e:	69a2                	ld	s3,8(sp)
    80004130:	b7e5                	j	80004118 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004132:	02451783          	lh	a5,36(a0)
    80004136:	03079693          	slli	a3,a5,0x30
    8000413a:	92c1                	srli	a3,a3,0x30
    8000413c:	4725                	li	a4,9
    8000413e:	02d76863          	bltu	a4,a3,8000416e <fileread+0xae>
    80004142:	0792                	slli	a5,a5,0x4
    80004144:	0001f717          	auipc	a4,0x1f
    80004148:	90470713          	addi	a4,a4,-1788 # 80022a48 <devsw>
    8000414c:	97ba                	add	a5,a5,a4
    8000414e:	639c                	ld	a5,0(a5)
    80004150:	c39d                	beqz	a5,80004176 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004152:	4505                	li	a0,1
    80004154:	9782                	jalr	a5
    80004156:	892a                	mv	s2,a0
    80004158:	64e2                	ld	s1,24(sp)
    8000415a:	69a2                	ld	s3,8(sp)
    8000415c:	bf75                	j	80004118 <fileread+0x58>
    panic("fileread");
    8000415e:	00003517          	auipc	a0,0x3
    80004162:	47a50513          	addi	a0,a0,1146 # 800075d8 <etext+0x5d8>
    80004166:	e2efc0ef          	jal	80000794 <panic>
    return -1;
    8000416a:	597d                	li	s2,-1
    8000416c:	b775                	j	80004118 <fileread+0x58>
      return -1;
    8000416e:	597d                	li	s2,-1
    80004170:	64e2                	ld	s1,24(sp)
    80004172:	69a2                	ld	s3,8(sp)
    80004174:	b755                	j	80004118 <fileread+0x58>
    80004176:	597d                	li	s2,-1
    80004178:	64e2                	ld	s1,24(sp)
    8000417a:	69a2                	ld	s3,8(sp)
    8000417c:	bf71                	j	80004118 <fileread+0x58>

000000008000417e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000417e:	00954783          	lbu	a5,9(a0)
    80004182:	10078b63          	beqz	a5,80004298 <filewrite+0x11a>
{
    80004186:	715d                	addi	sp,sp,-80
    80004188:	e486                	sd	ra,72(sp)
    8000418a:	e0a2                	sd	s0,64(sp)
    8000418c:	f84a                	sd	s2,48(sp)
    8000418e:	f052                	sd	s4,32(sp)
    80004190:	e85a                	sd	s6,16(sp)
    80004192:	0880                	addi	s0,sp,80
    80004194:	892a                	mv	s2,a0
    80004196:	8b2e                	mv	s6,a1
    80004198:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000419a:	411c                	lw	a5,0(a0)
    8000419c:	4705                	li	a4,1
    8000419e:	02e78763          	beq	a5,a4,800041cc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041a2:	470d                	li	a4,3
    800041a4:	02e78863          	beq	a5,a4,800041d4 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800041a8:	4709                	li	a4,2
    800041aa:	0ce79c63          	bne	a5,a4,80004282 <filewrite+0x104>
    800041ae:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041b0:	0ac05863          	blez	a2,80004260 <filewrite+0xe2>
    800041b4:	fc26                	sd	s1,56(sp)
    800041b6:	ec56                	sd	s5,24(sp)
    800041b8:	e45e                	sd	s7,8(sp)
    800041ba:	e062                	sd	s8,0(sp)
    int i = 0;
    800041bc:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800041be:	6b85                	lui	s7,0x1
    800041c0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041c4:	6c05                	lui	s8,0x1
    800041c6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800041ca:	a8b5                	j	80004246 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800041cc:	6908                	ld	a0,16(a0)
    800041ce:	1fc000ef          	jal	800043ca <pipewrite>
    800041d2:	a04d                	j	80004274 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800041d4:	02451783          	lh	a5,36(a0)
    800041d8:	03079693          	slli	a3,a5,0x30
    800041dc:	92c1                	srli	a3,a3,0x30
    800041de:	4725                	li	a4,9
    800041e0:	0ad76e63          	bltu	a4,a3,8000429c <filewrite+0x11e>
    800041e4:	0792                	slli	a5,a5,0x4
    800041e6:	0001f717          	auipc	a4,0x1f
    800041ea:	86270713          	addi	a4,a4,-1950 # 80022a48 <devsw>
    800041ee:	97ba                	add	a5,a5,a4
    800041f0:	679c                	ld	a5,8(a5)
    800041f2:	c7dd                	beqz	a5,800042a0 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800041f4:	4505                	li	a0,1
    800041f6:	9782                	jalr	a5
    800041f8:	a8b5                	j	80004274 <filewrite+0xf6>
      if(n1 > max)
    800041fa:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800041fe:	989ff0ef          	jal	80003b86 <begin_op>
      ilock(f->ip);
    80004202:	01893503          	ld	a0,24(s2)
    80004206:	8eaff0ef          	jal	800032f0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000420a:	8756                	mv	a4,s5
    8000420c:	02092683          	lw	a3,32(s2)
    80004210:	01698633          	add	a2,s3,s6
    80004214:	4585                	li	a1,1
    80004216:	01893503          	ld	a0,24(s2)
    8000421a:	c26ff0ef          	jal	80003640 <writei>
    8000421e:	84aa                	mv	s1,a0
    80004220:	00a05763          	blez	a0,8000422e <filewrite+0xb0>
        f->off += r;
    80004224:	02092783          	lw	a5,32(s2)
    80004228:	9fa9                	addw	a5,a5,a0
    8000422a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000422e:	01893503          	ld	a0,24(s2)
    80004232:	96cff0ef          	jal	8000339e <iunlock>
      end_op();
    80004236:	9bbff0ef          	jal	80003bf0 <end_op>

      if(r != n1){
    8000423a:	029a9563          	bne	s5,s1,80004264 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000423e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004242:	0149da63          	bge	s3,s4,80004256 <filewrite+0xd8>
      int n1 = n - i;
    80004246:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000424a:	0004879b          	sext.w	a5,s1
    8000424e:	fafbd6e3          	bge	s7,a5,800041fa <filewrite+0x7c>
    80004252:	84e2                	mv	s1,s8
    80004254:	b75d                	j	800041fa <filewrite+0x7c>
    80004256:	74e2                	ld	s1,56(sp)
    80004258:	6ae2                	ld	s5,24(sp)
    8000425a:	6ba2                	ld	s7,8(sp)
    8000425c:	6c02                	ld	s8,0(sp)
    8000425e:	a039                	j	8000426c <filewrite+0xee>
    int i = 0;
    80004260:	4981                	li	s3,0
    80004262:	a029                	j	8000426c <filewrite+0xee>
    80004264:	74e2                	ld	s1,56(sp)
    80004266:	6ae2                	ld	s5,24(sp)
    80004268:	6ba2                	ld	s7,8(sp)
    8000426a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000426c:	033a1c63          	bne	s4,s3,800042a4 <filewrite+0x126>
    80004270:	8552                	mv	a0,s4
    80004272:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004274:	60a6                	ld	ra,72(sp)
    80004276:	6406                	ld	s0,64(sp)
    80004278:	7942                	ld	s2,48(sp)
    8000427a:	7a02                	ld	s4,32(sp)
    8000427c:	6b42                	ld	s6,16(sp)
    8000427e:	6161                	addi	sp,sp,80
    80004280:	8082                	ret
    80004282:	fc26                	sd	s1,56(sp)
    80004284:	f44e                	sd	s3,40(sp)
    80004286:	ec56                	sd	s5,24(sp)
    80004288:	e45e                	sd	s7,8(sp)
    8000428a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000428c:	00003517          	auipc	a0,0x3
    80004290:	35c50513          	addi	a0,a0,860 # 800075e8 <etext+0x5e8>
    80004294:	d00fc0ef          	jal	80000794 <panic>
    return -1;
    80004298:	557d                	li	a0,-1
}
    8000429a:	8082                	ret
      return -1;
    8000429c:	557d                	li	a0,-1
    8000429e:	bfd9                	j	80004274 <filewrite+0xf6>
    800042a0:	557d                	li	a0,-1
    800042a2:	bfc9                	j	80004274 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800042a4:	557d                	li	a0,-1
    800042a6:	79a2                	ld	s3,40(sp)
    800042a8:	b7f1                	j	80004274 <filewrite+0xf6>

00000000800042aa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800042aa:	7179                	addi	sp,sp,-48
    800042ac:	f406                	sd	ra,40(sp)
    800042ae:	f022                	sd	s0,32(sp)
    800042b0:	ec26                	sd	s1,24(sp)
    800042b2:	e052                	sd	s4,0(sp)
    800042b4:	1800                	addi	s0,sp,48
    800042b6:	84aa                	mv	s1,a0
    800042b8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800042ba:	0005b023          	sd	zero,0(a1)
    800042be:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042c2:	c3bff0ef          	jal	80003efc <filealloc>
    800042c6:	e088                	sd	a0,0(s1)
    800042c8:	c549                	beqz	a0,80004352 <pipealloc+0xa8>
    800042ca:	c33ff0ef          	jal	80003efc <filealloc>
    800042ce:	00aa3023          	sd	a0,0(s4)
    800042d2:	cd25                	beqz	a0,8000434a <pipealloc+0xa0>
    800042d4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800042d6:	84ffc0ef          	jal	80000b24 <kalloc>
    800042da:	892a                	mv	s2,a0
    800042dc:	c12d                	beqz	a0,8000433e <pipealloc+0x94>
    800042de:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800042e0:	4985                	li	s3,1
    800042e2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800042e6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800042ea:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800042ee:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800042f2:	00003597          	auipc	a1,0x3
    800042f6:	30658593          	addi	a1,a1,774 # 800075f8 <etext+0x5f8>
    800042fa:	87bfc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800042fe:	609c                	ld	a5,0(s1)
    80004300:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004304:	609c                	ld	a5,0(s1)
    80004306:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000430a:	609c                	ld	a5,0(s1)
    8000430c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004310:	609c                	ld	a5,0(s1)
    80004312:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004316:	000a3783          	ld	a5,0(s4)
    8000431a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000431e:	000a3783          	ld	a5,0(s4)
    80004322:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004326:	000a3783          	ld	a5,0(s4)
    8000432a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000432e:	000a3783          	ld	a5,0(s4)
    80004332:	0127b823          	sd	s2,16(a5)
  return 0;
    80004336:	4501                	li	a0,0
    80004338:	6942                	ld	s2,16(sp)
    8000433a:	69a2                	ld	s3,8(sp)
    8000433c:	a01d                	j	80004362 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000433e:	6088                	ld	a0,0(s1)
    80004340:	c119                	beqz	a0,80004346 <pipealloc+0x9c>
    80004342:	6942                	ld	s2,16(sp)
    80004344:	a029                	j	8000434e <pipealloc+0xa4>
    80004346:	6942                	ld	s2,16(sp)
    80004348:	a029                	j	80004352 <pipealloc+0xa8>
    8000434a:	6088                	ld	a0,0(s1)
    8000434c:	c10d                	beqz	a0,8000436e <pipealloc+0xc4>
    fileclose(*f0);
    8000434e:	c53ff0ef          	jal	80003fa0 <fileclose>
  if(*f1)
    80004352:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004356:	557d                	li	a0,-1
  if(*f1)
    80004358:	c789                	beqz	a5,80004362 <pipealloc+0xb8>
    fileclose(*f1);
    8000435a:	853e                	mv	a0,a5
    8000435c:	c45ff0ef          	jal	80003fa0 <fileclose>
  return -1;
    80004360:	557d                	li	a0,-1
}
    80004362:	70a2                	ld	ra,40(sp)
    80004364:	7402                	ld	s0,32(sp)
    80004366:	64e2                	ld	s1,24(sp)
    80004368:	6a02                	ld	s4,0(sp)
    8000436a:	6145                	addi	sp,sp,48
    8000436c:	8082                	ret
  return -1;
    8000436e:	557d                	li	a0,-1
    80004370:	bfcd                	j	80004362 <pipealloc+0xb8>

0000000080004372 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004372:	1101                	addi	sp,sp,-32
    80004374:	ec06                	sd	ra,24(sp)
    80004376:	e822                	sd	s0,16(sp)
    80004378:	e426                	sd	s1,8(sp)
    8000437a:	e04a                	sd	s2,0(sp)
    8000437c:	1000                	addi	s0,sp,32
    8000437e:	84aa                	mv	s1,a0
    80004380:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004382:	873fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004386:	02090763          	beqz	s2,800043b4 <pipeclose+0x42>
    pi->writeopen = 0;
    8000438a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000438e:	21848513          	addi	a0,s1,536
    80004392:	bd9fd0ef          	jal	80001f6a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004396:	2204b783          	ld	a5,544(s1)
    8000439a:	e785                	bnez	a5,800043c2 <pipeclose+0x50>
    release(&pi->lock);
    8000439c:	8526                	mv	a0,s1
    8000439e:	8effc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800043a2:	8526                	mv	a0,s1
    800043a4:	e9efc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    800043a8:	60e2                	ld	ra,24(sp)
    800043aa:	6442                	ld	s0,16(sp)
    800043ac:	64a2                	ld	s1,8(sp)
    800043ae:	6902                	ld	s2,0(sp)
    800043b0:	6105                	addi	sp,sp,32
    800043b2:	8082                	ret
    pi->readopen = 0;
    800043b4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800043b8:	21c48513          	addi	a0,s1,540
    800043bc:	baffd0ef          	jal	80001f6a <wakeup>
    800043c0:	bfd9                	j	80004396 <pipeclose+0x24>
    release(&pi->lock);
    800043c2:	8526                	mv	a0,s1
    800043c4:	8c9fc0ef          	jal	80000c8c <release>
}
    800043c8:	b7c5                	j	800043a8 <pipeclose+0x36>

00000000800043ca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800043ca:	711d                	addi	sp,sp,-96
    800043cc:	ec86                	sd	ra,88(sp)
    800043ce:	e8a2                	sd	s0,80(sp)
    800043d0:	e4a6                	sd	s1,72(sp)
    800043d2:	e0ca                	sd	s2,64(sp)
    800043d4:	fc4e                	sd	s3,56(sp)
    800043d6:	f852                	sd	s4,48(sp)
    800043d8:	f456                	sd	s5,40(sp)
    800043da:	1080                	addi	s0,sp,96
    800043dc:	84aa                	mv	s1,a0
    800043de:	8aae                	mv	s5,a1
    800043e0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800043e2:	cfefd0ef          	jal	800018e0 <myproc>
    800043e6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800043e8:	8526                	mv	a0,s1
    800043ea:	80bfc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800043ee:	0b405a63          	blez	s4,800044a2 <pipewrite+0xd8>
    800043f2:	f05a                	sd	s6,32(sp)
    800043f4:	ec5e                	sd	s7,24(sp)
    800043f6:	e862                	sd	s8,16(sp)
  int i = 0;
    800043f8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043fa:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800043fc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004400:	21c48b93          	addi	s7,s1,540
    80004404:	a81d                	j	8000443a <pipewrite+0x70>
      release(&pi->lock);
    80004406:	8526                	mv	a0,s1
    80004408:	885fc0ef          	jal	80000c8c <release>
      return -1;
    8000440c:	597d                	li	s2,-1
    8000440e:	7b02                	ld	s6,32(sp)
    80004410:	6be2                	ld	s7,24(sp)
    80004412:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004414:	854a                	mv	a0,s2
    80004416:	60e6                	ld	ra,88(sp)
    80004418:	6446                	ld	s0,80(sp)
    8000441a:	64a6                	ld	s1,72(sp)
    8000441c:	6906                	ld	s2,64(sp)
    8000441e:	79e2                	ld	s3,56(sp)
    80004420:	7a42                	ld	s4,48(sp)
    80004422:	7aa2                	ld	s5,40(sp)
    80004424:	6125                	addi	sp,sp,96
    80004426:	8082                	ret
      wakeup(&pi->nread);
    80004428:	8562                	mv	a0,s8
    8000442a:	b41fd0ef          	jal	80001f6a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000442e:	85a6                	mv	a1,s1
    80004430:	855e                	mv	a0,s7
    80004432:	aedfd0ef          	jal	80001f1e <sleep>
  while(i < n){
    80004436:	05495b63          	bge	s2,s4,8000448c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000443a:	2204a783          	lw	a5,544(s1)
    8000443e:	d7e1                	beqz	a5,80004406 <pipewrite+0x3c>
    80004440:	854e                	mv	a0,s3
    80004442:	d15fd0ef          	jal	80002156 <killed>
    80004446:	f161                	bnez	a0,80004406 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004448:	2184a783          	lw	a5,536(s1)
    8000444c:	21c4a703          	lw	a4,540(s1)
    80004450:	2007879b          	addiw	a5,a5,512
    80004454:	fcf70ae3          	beq	a4,a5,80004428 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004458:	4685                	li	a3,1
    8000445a:	01590633          	add	a2,s2,s5
    8000445e:	faf40593          	addi	a1,s0,-81
    80004462:	0509b503          	ld	a0,80(s3)
    80004466:	9c2fd0ef          	jal	80001628 <copyin>
    8000446a:	03650e63          	beq	a0,s6,800044a6 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000446e:	21c4a783          	lw	a5,540(s1)
    80004472:	0017871b          	addiw	a4,a5,1
    80004476:	20e4ae23          	sw	a4,540(s1)
    8000447a:	1ff7f793          	andi	a5,a5,511
    8000447e:	97a6                	add	a5,a5,s1
    80004480:	faf44703          	lbu	a4,-81(s0)
    80004484:	00e78c23          	sb	a4,24(a5)
      i++;
    80004488:	2905                	addiw	s2,s2,1
    8000448a:	b775                	j	80004436 <pipewrite+0x6c>
    8000448c:	7b02                	ld	s6,32(sp)
    8000448e:	6be2                	ld	s7,24(sp)
    80004490:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004492:	21848513          	addi	a0,s1,536
    80004496:	ad5fd0ef          	jal	80001f6a <wakeup>
  release(&pi->lock);
    8000449a:	8526                	mv	a0,s1
    8000449c:	ff0fc0ef          	jal	80000c8c <release>
  return i;
    800044a0:	bf95                	j	80004414 <pipewrite+0x4a>
  int i = 0;
    800044a2:	4901                	li	s2,0
    800044a4:	b7fd                	j	80004492 <pipewrite+0xc8>
    800044a6:	7b02                	ld	s6,32(sp)
    800044a8:	6be2                	ld	s7,24(sp)
    800044aa:	6c42                	ld	s8,16(sp)
    800044ac:	b7dd                	j	80004492 <pipewrite+0xc8>

00000000800044ae <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800044ae:	715d                	addi	sp,sp,-80
    800044b0:	e486                	sd	ra,72(sp)
    800044b2:	e0a2                	sd	s0,64(sp)
    800044b4:	fc26                	sd	s1,56(sp)
    800044b6:	f84a                	sd	s2,48(sp)
    800044b8:	f44e                	sd	s3,40(sp)
    800044ba:	f052                	sd	s4,32(sp)
    800044bc:	ec56                	sd	s5,24(sp)
    800044be:	0880                	addi	s0,sp,80
    800044c0:	84aa                	mv	s1,a0
    800044c2:	892e                	mv	s2,a1
    800044c4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800044c6:	c1afd0ef          	jal	800018e0 <myproc>
    800044ca:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800044cc:	8526                	mv	a0,s1
    800044ce:	f26fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044d2:	2184a703          	lw	a4,536(s1)
    800044d6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044da:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044de:	02f71563          	bne	a4,a5,80004508 <piperead+0x5a>
    800044e2:	2244a783          	lw	a5,548(s1)
    800044e6:	cb85                	beqz	a5,80004516 <piperead+0x68>
    if(killed(pr)){
    800044e8:	8552                	mv	a0,s4
    800044ea:	c6dfd0ef          	jal	80002156 <killed>
    800044ee:	ed19                	bnez	a0,8000450c <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044f0:	85a6                	mv	a1,s1
    800044f2:	854e                	mv	a0,s3
    800044f4:	a2bfd0ef          	jal	80001f1e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044f8:	2184a703          	lw	a4,536(s1)
    800044fc:	21c4a783          	lw	a5,540(s1)
    80004500:	fef701e3          	beq	a4,a5,800044e2 <piperead+0x34>
    80004504:	e85a                	sd	s6,16(sp)
    80004506:	a809                	j	80004518 <piperead+0x6a>
    80004508:	e85a                	sd	s6,16(sp)
    8000450a:	a039                	j	80004518 <piperead+0x6a>
      release(&pi->lock);
    8000450c:	8526                	mv	a0,s1
    8000450e:	f7efc0ef          	jal	80000c8c <release>
      return -1;
    80004512:	59fd                	li	s3,-1
    80004514:	a8b1                	j	80004570 <piperead+0xc2>
    80004516:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004518:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000451a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000451c:	05505263          	blez	s5,80004560 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004520:	2184a783          	lw	a5,536(s1)
    80004524:	21c4a703          	lw	a4,540(s1)
    80004528:	02f70c63          	beq	a4,a5,80004560 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000452c:	0017871b          	addiw	a4,a5,1
    80004530:	20e4ac23          	sw	a4,536(s1)
    80004534:	1ff7f793          	andi	a5,a5,511
    80004538:	97a6                	add	a5,a5,s1
    8000453a:	0187c783          	lbu	a5,24(a5)
    8000453e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004542:	4685                	li	a3,1
    80004544:	fbf40613          	addi	a2,s0,-65
    80004548:	85ca                	mv	a1,s2
    8000454a:	050a3503          	ld	a0,80(s4)
    8000454e:	804fd0ef          	jal	80001552 <copyout>
    80004552:	01650763          	beq	a0,s6,80004560 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004556:	2985                	addiw	s3,s3,1
    80004558:	0905                	addi	s2,s2,1
    8000455a:	fd3a93e3          	bne	s5,s3,80004520 <piperead+0x72>
    8000455e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004560:	21c48513          	addi	a0,s1,540
    80004564:	a07fd0ef          	jal	80001f6a <wakeup>
  release(&pi->lock);
    80004568:	8526                	mv	a0,s1
    8000456a:	f22fc0ef          	jal	80000c8c <release>
    8000456e:	6b42                	ld	s6,16(sp)
  return i;
}
    80004570:	854e                	mv	a0,s3
    80004572:	60a6                	ld	ra,72(sp)
    80004574:	6406                	ld	s0,64(sp)
    80004576:	74e2                	ld	s1,56(sp)
    80004578:	7942                	ld	s2,48(sp)
    8000457a:	79a2                	ld	s3,40(sp)
    8000457c:	7a02                	ld	s4,32(sp)
    8000457e:	6ae2                	ld	s5,24(sp)
    80004580:	6161                	addi	sp,sp,80
    80004582:	8082                	ret

0000000080004584 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004584:	1141                	addi	sp,sp,-16
    80004586:	e422                	sd	s0,8(sp)
    80004588:	0800                	addi	s0,sp,16
    8000458a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000458c:	8905                	andi	a0,a0,1
    8000458e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004590:	8b89                	andi	a5,a5,2
    80004592:	c399                	beqz	a5,80004598 <flags2perm+0x14>
      perm |= PTE_W;
    80004594:	00456513          	ori	a0,a0,4
    return perm;
}
    80004598:	6422                	ld	s0,8(sp)
    8000459a:	0141                	addi	sp,sp,16
    8000459c:	8082                	ret

000000008000459e <exec>:

int
exec(char *path, char **argv)
{
    8000459e:	df010113          	addi	sp,sp,-528
    800045a2:	20113423          	sd	ra,520(sp)
    800045a6:	20813023          	sd	s0,512(sp)
    800045aa:	ffa6                	sd	s1,504(sp)
    800045ac:	fbca                	sd	s2,496(sp)
    800045ae:	0c00                	addi	s0,sp,528
    800045b0:	892a                	mv	s2,a0
    800045b2:	dea43c23          	sd	a0,-520(s0)
    800045b6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800045ba:	b26fd0ef          	jal	800018e0 <myproc>
    800045be:	84aa                	mv	s1,a0

  begin_op();
    800045c0:	dc6ff0ef          	jal	80003b86 <begin_op>

  if((ip = namei(path)) == 0){
    800045c4:	854a                	mv	a0,s2
    800045c6:	c04ff0ef          	jal	800039ca <namei>
    800045ca:	c931                	beqz	a0,8000461e <exec+0x80>
    800045cc:	f3d2                	sd	s4,480(sp)
    800045ce:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800045d0:	d21fe0ef          	jal	800032f0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800045d4:	04000713          	li	a4,64
    800045d8:	4681                	li	a3,0
    800045da:	e5040613          	addi	a2,s0,-432
    800045de:	4581                	li	a1,0
    800045e0:	8552                	mv	a0,s4
    800045e2:	f63fe0ef          	jal	80003544 <readi>
    800045e6:	04000793          	li	a5,64
    800045ea:	00f51a63          	bne	a0,a5,800045fe <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800045ee:	e5042703          	lw	a4,-432(s0)
    800045f2:	464c47b7          	lui	a5,0x464c4
    800045f6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800045fa:	02f70663          	beq	a4,a5,80004626 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800045fe:	8552                	mv	a0,s4
    80004600:	efbfe0ef          	jal	800034fa <iunlockput>
    end_op();
    80004604:	decff0ef          	jal	80003bf0 <end_op>
  }
  return -1;
    80004608:	557d                	li	a0,-1
    8000460a:	7a1e                	ld	s4,480(sp)
}
    8000460c:	20813083          	ld	ra,520(sp)
    80004610:	20013403          	ld	s0,512(sp)
    80004614:	74fe                	ld	s1,504(sp)
    80004616:	795e                	ld	s2,496(sp)
    80004618:	21010113          	addi	sp,sp,528
    8000461c:	8082                	ret
    end_op();
    8000461e:	dd2ff0ef          	jal	80003bf0 <end_op>
    return -1;
    80004622:	557d                	li	a0,-1
    80004624:	b7e5                	j	8000460c <exec+0x6e>
    80004626:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004628:	8526                	mv	a0,s1
    8000462a:	b5efd0ef          	jal	80001988 <proc_pagetable>
    8000462e:	8b2a                	mv	s6,a0
    80004630:	2c050b63          	beqz	a0,80004906 <exec+0x368>
    80004634:	f7ce                	sd	s3,488(sp)
    80004636:	efd6                	sd	s5,472(sp)
    80004638:	e7de                	sd	s7,456(sp)
    8000463a:	e3e2                	sd	s8,448(sp)
    8000463c:	ff66                	sd	s9,440(sp)
    8000463e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004640:	e7042d03          	lw	s10,-400(s0)
    80004644:	e8845783          	lhu	a5,-376(s0)
    80004648:	12078963          	beqz	a5,8000477a <exec+0x1dc>
    8000464c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000464e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004650:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004652:	6c85                	lui	s9,0x1
    80004654:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004658:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000465c:	6a85                	lui	s5,0x1
    8000465e:	a085                	j	800046be <exec+0x120>
      panic("loadseg: address should exist");
    80004660:	00003517          	auipc	a0,0x3
    80004664:	fa050513          	addi	a0,a0,-96 # 80007600 <etext+0x600>
    80004668:	92cfc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    8000466c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000466e:	8726                	mv	a4,s1
    80004670:	012c06bb          	addw	a3,s8,s2
    80004674:	4581                	li	a1,0
    80004676:	8552                	mv	a0,s4
    80004678:	ecdfe0ef          	jal	80003544 <readi>
    8000467c:	2501                	sext.w	a0,a0
    8000467e:	24a49a63          	bne	s1,a0,800048d2 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004682:	012a893b          	addw	s2,s5,s2
    80004686:	03397363          	bgeu	s2,s3,800046ac <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000468a:	02091593          	slli	a1,s2,0x20
    8000468e:	9181                	srli	a1,a1,0x20
    80004690:	95de                	add	a1,a1,s7
    80004692:	855a                	mv	a0,s6
    80004694:	943fc0ef          	jal	80000fd6 <walkaddr>
    80004698:	862a                	mv	a2,a0
    if(pa == 0)
    8000469a:	d179                	beqz	a0,80004660 <exec+0xc2>
    if(sz - i < PGSIZE)
    8000469c:	412984bb          	subw	s1,s3,s2
    800046a0:	0004879b          	sext.w	a5,s1
    800046a4:	fcfcf4e3          	bgeu	s9,a5,8000466c <exec+0xce>
    800046a8:	84d6                	mv	s1,s5
    800046aa:	b7c9                	j	8000466c <exec+0xce>
    sz = sz1;
    800046ac:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046b0:	2d85                	addiw	s11,s11,1
    800046b2:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800046b6:	e8845783          	lhu	a5,-376(s0)
    800046ba:	08fdd063          	bge	s11,a5,8000473a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046be:	2d01                	sext.w	s10,s10
    800046c0:	03800713          	li	a4,56
    800046c4:	86ea                	mv	a3,s10
    800046c6:	e1840613          	addi	a2,s0,-488
    800046ca:	4581                	li	a1,0
    800046cc:	8552                	mv	a0,s4
    800046ce:	e77fe0ef          	jal	80003544 <readi>
    800046d2:	03800793          	li	a5,56
    800046d6:	1cf51663          	bne	a0,a5,800048a2 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800046da:	e1842783          	lw	a5,-488(s0)
    800046de:	4705                	li	a4,1
    800046e0:	fce798e3          	bne	a5,a4,800046b0 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800046e4:	e4043483          	ld	s1,-448(s0)
    800046e8:	e3843783          	ld	a5,-456(s0)
    800046ec:	1af4ef63          	bltu	s1,a5,800048aa <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800046f0:	e2843783          	ld	a5,-472(s0)
    800046f4:	94be                	add	s1,s1,a5
    800046f6:	1af4ee63          	bltu	s1,a5,800048b2 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800046fa:	df043703          	ld	a4,-528(s0)
    800046fe:	8ff9                	and	a5,a5,a4
    80004700:	1a079d63          	bnez	a5,800048ba <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004704:	e1c42503          	lw	a0,-484(s0)
    80004708:	e7dff0ef          	jal	80004584 <flags2perm>
    8000470c:	86aa                	mv	a3,a0
    8000470e:	8626                	mv	a2,s1
    80004710:	85ca                	mv	a1,s2
    80004712:	855a                	mv	a0,s6
    80004714:	c2bfc0ef          	jal	8000133e <uvmalloc>
    80004718:	e0a43423          	sd	a0,-504(s0)
    8000471c:	1a050363          	beqz	a0,800048c2 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004720:	e2843b83          	ld	s7,-472(s0)
    80004724:	e2042c03          	lw	s8,-480(s0)
    80004728:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000472c:	00098463          	beqz	s3,80004734 <exec+0x196>
    80004730:	4901                	li	s2,0
    80004732:	bfa1                	j	8000468a <exec+0xec>
    sz = sz1;
    80004734:	e0843903          	ld	s2,-504(s0)
    80004738:	bfa5                	j	800046b0 <exec+0x112>
    8000473a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000473c:	8552                	mv	a0,s4
    8000473e:	dbdfe0ef          	jal	800034fa <iunlockput>
  end_op();
    80004742:	caeff0ef          	jal	80003bf0 <end_op>
  p = myproc();
    80004746:	99afd0ef          	jal	800018e0 <myproc>
    8000474a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000474c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004750:	6985                	lui	s3,0x1
    80004752:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004754:	99ca                	add	s3,s3,s2
    80004756:	77fd                	lui	a5,0xfffff
    80004758:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000475c:	4691                	li	a3,4
    8000475e:	6609                	lui	a2,0x2
    80004760:	964e                	add	a2,a2,s3
    80004762:	85ce                	mv	a1,s3
    80004764:	855a                	mv	a0,s6
    80004766:	bd9fc0ef          	jal	8000133e <uvmalloc>
    8000476a:	892a                	mv	s2,a0
    8000476c:	e0a43423          	sd	a0,-504(s0)
    80004770:	e519                	bnez	a0,8000477e <exec+0x1e0>
  if(pagetable)
    80004772:	e1343423          	sd	s3,-504(s0)
    80004776:	4a01                	li	s4,0
    80004778:	aab1                	j	800048d4 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000477a:	4901                	li	s2,0
    8000477c:	b7c1                	j	8000473c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000477e:	75f9                	lui	a1,0xffffe
    80004780:	95aa                	add	a1,a1,a0
    80004782:	855a                	mv	a0,s6
    80004784:	da5fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004788:	7bfd                	lui	s7,0xfffff
    8000478a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000478c:	e0043783          	ld	a5,-512(s0)
    80004790:	6388                	ld	a0,0(a5)
    80004792:	cd39                	beqz	a0,800047f0 <exec+0x252>
    80004794:	e9040993          	addi	s3,s0,-368
    80004798:	f9040c13          	addi	s8,s0,-112
    8000479c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000479e:	e9afc0ef          	jal	80000e38 <strlen>
    800047a2:	0015079b          	addiw	a5,a0,1
    800047a6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800047aa:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800047ae:	11796e63          	bltu	s2,s7,800048ca <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800047b2:	e0043d03          	ld	s10,-512(s0)
    800047b6:	000d3a03          	ld	s4,0(s10)
    800047ba:	8552                	mv	a0,s4
    800047bc:	e7cfc0ef          	jal	80000e38 <strlen>
    800047c0:	0015069b          	addiw	a3,a0,1
    800047c4:	8652                	mv	a2,s4
    800047c6:	85ca                	mv	a1,s2
    800047c8:	855a                	mv	a0,s6
    800047ca:	d89fc0ef          	jal	80001552 <copyout>
    800047ce:	10054063          	bltz	a0,800048ce <exec+0x330>
    ustack[argc] = sp;
    800047d2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800047d6:	0485                	addi	s1,s1,1
    800047d8:	008d0793          	addi	a5,s10,8
    800047dc:	e0f43023          	sd	a5,-512(s0)
    800047e0:	008d3503          	ld	a0,8(s10)
    800047e4:	c909                	beqz	a0,800047f6 <exec+0x258>
    if(argc >= MAXARG)
    800047e6:	09a1                	addi	s3,s3,8
    800047e8:	fb899be3          	bne	s3,s8,8000479e <exec+0x200>
  ip = 0;
    800047ec:	4a01                	li	s4,0
    800047ee:	a0dd                	j	800048d4 <exec+0x336>
  sp = sz;
    800047f0:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800047f4:	4481                	li	s1,0
  ustack[argc] = 0;
    800047f6:	00349793          	slli	a5,s1,0x3
    800047fa:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb3b0>
    800047fe:	97a2                	add	a5,a5,s0
    80004800:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004804:	00148693          	addi	a3,s1,1
    80004808:	068e                	slli	a3,a3,0x3
    8000480a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000480e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004812:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004816:	f5796ee3          	bltu	s2,s7,80004772 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000481a:	e9040613          	addi	a2,s0,-368
    8000481e:	85ca                	mv	a1,s2
    80004820:	855a                	mv	a0,s6
    80004822:	d31fc0ef          	jal	80001552 <copyout>
    80004826:	0e054263          	bltz	a0,8000490a <exec+0x36c>
  p->trapframe->a1 = sp;
    8000482a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000482e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004832:	df843783          	ld	a5,-520(s0)
    80004836:	0007c703          	lbu	a4,0(a5)
    8000483a:	cf11                	beqz	a4,80004856 <exec+0x2b8>
    8000483c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000483e:	02f00693          	li	a3,47
    80004842:	a039                	j	80004850 <exec+0x2b2>
      last = s+1;
    80004844:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004848:	0785                	addi	a5,a5,1
    8000484a:	fff7c703          	lbu	a4,-1(a5)
    8000484e:	c701                	beqz	a4,80004856 <exec+0x2b8>
    if(*s == '/')
    80004850:	fed71ce3          	bne	a4,a3,80004848 <exec+0x2aa>
    80004854:	bfc5                	j	80004844 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004856:	4641                	li	a2,16
    80004858:	df843583          	ld	a1,-520(s0)
    8000485c:	158a8513          	addi	a0,s5,344
    80004860:	da6fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004864:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004868:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000486c:	e0843783          	ld	a5,-504(s0)
    80004870:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004874:	058ab783          	ld	a5,88(s5)
    80004878:	e6843703          	ld	a4,-408(s0)
    8000487c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000487e:	058ab783          	ld	a5,88(s5)
    80004882:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004886:	85e6                	mv	a1,s9
    80004888:	984fd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000488c:	0004851b          	sext.w	a0,s1
    80004890:	79be                	ld	s3,488(sp)
    80004892:	7a1e                	ld	s4,480(sp)
    80004894:	6afe                	ld	s5,472(sp)
    80004896:	6b5e                	ld	s6,464(sp)
    80004898:	6bbe                	ld	s7,456(sp)
    8000489a:	6c1e                	ld	s8,448(sp)
    8000489c:	7cfa                	ld	s9,440(sp)
    8000489e:	7d5a                	ld	s10,432(sp)
    800048a0:	b3b5                	j	8000460c <exec+0x6e>
    800048a2:	e1243423          	sd	s2,-504(s0)
    800048a6:	7dba                	ld	s11,424(sp)
    800048a8:	a035                	j	800048d4 <exec+0x336>
    800048aa:	e1243423          	sd	s2,-504(s0)
    800048ae:	7dba                	ld	s11,424(sp)
    800048b0:	a015                	j	800048d4 <exec+0x336>
    800048b2:	e1243423          	sd	s2,-504(s0)
    800048b6:	7dba                	ld	s11,424(sp)
    800048b8:	a831                	j	800048d4 <exec+0x336>
    800048ba:	e1243423          	sd	s2,-504(s0)
    800048be:	7dba                	ld	s11,424(sp)
    800048c0:	a811                	j	800048d4 <exec+0x336>
    800048c2:	e1243423          	sd	s2,-504(s0)
    800048c6:	7dba                	ld	s11,424(sp)
    800048c8:	a031                	j	800048d4 <exec+0x336>
  ip = 0;
    800048ca:	4a01                	li	s4,0
    800048cc:	a021                	j	800048d4 <exec+0x336>
    800048ce:	4a01                	li	s4,0
  if(pagetable)
    800048d0:	a011                	j	800048d4 <exec+0x336>
    800048d2:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800048d4:	e0843583          	ld	a1,-504(s0)
    800048d8:	855a                	mv	a0,s6
    800048da:	932fd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    800048de:	557d                	li	a0,-1
  if(ip){
    800048e0:	000a1b63          	bnez	s4,800048f6 <exec+0x358>
    800048e4:	79be                	ld	s3,488(sp)
    800048e6:	7a1e                	ld	s4,480(sp)
    800048e8:	6afe                	ld	s5,472(sp)
    800048ea:	6b5e                	ld	s6,464(sp)
    800048ec:	6bbe                	ld	s7,456(sp)
    800048ee:	6c1e                	ld	s8,448(sp)
    800048f0:	7cfa                	ld	s9,440(sp)
    800048f2:	7d5a                	ld	s10,432(sp)
    800048f4:	bb21                	j	8000460c <exec+0x6e>
    800048f6:	79be                	ld	s3,488(sp)
    800048f8:	6afe                	ld	s5,472(sp)
    800048fa:	6b5e                	ld	s6,464(sp)
    800048fc:	6bbe                	ld	s7,456(sp)
    800048fe:	6c1e                	ld	s8,448(sp)
    80004900:	7cfa                	ld	s9,440(sp)
    80004902:	7d5a                	ld	s10,432(sp)
    80004904:	b9ed                	j	800045fe <exec+0x60>
    80004906:	6b5e                	ld	s6,464(sp)
    80004908:	b9dd                	j	800045fe <exec+0x60>
  sz = sz1;
    8000490a:	e0843983          	ld	s3,-504(s0)
    8000490e:	b595                	j	80004772 <exec+0x1d4>

0000000080004910 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004910:	7179                	addi	sp,sp,-48
    80004912:	f406                	sd	ra,40(sp)
    80004914:	f022                	sd	s0,32(sp)
    80004916:	ec26                	sd	s1,24(sp)
    80004918:	e84a                	sd	s2,16(sp)
    8000491a:	1800                	addi	s0,sp,48
    8000491c:	892e                	mv	s2,a1
    8000491e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004920:	fdc40593          	addi	a1,s0,-36
    80004924:	f27fd0ef          	jal	8000284a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004928:	fdc42703          	lw	a4,-36(s0)
    8000492c:	47bd                	li	a5,15
    8000492e:	02e7e963          	bltu	a5,a4,80004960 <argfd+0x50>
    80004932:	faffc0ef          	jal	800018e0 <myproc>
    80004936:	fdc42703          	lw	a4,-36(s0)
    8000493a:	01a70793          	addi	a5,a4,26
    8000493e:	078e                	slli	a5,a5,0x3
    80004940:	953e                	add	a0,a0,a5
    80004942:	611c                	ld	a5,0(a0)
    80004944:	c385                	beqz	a5,80004964 <argfd+0x54>
    return -1;
  if(pfd)
    80004946:	00090463          	beqz	s2,8000494e <argfd+0x3e>
    *pfd = fd;
    8000494a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000494e:	4501                	li	a0,0
  if(pf)
    80004950:	c091                	beqz	s1,80004954 <argfd+0x44>
    *pf = f;
    80004952:	e09c                	sd	a5,0(s1)
}
    80004954:	70a2                	ld	ra,40(sp)
    80004956:	7402                	ld	s0,32(sp)
    80004958:	64e2                	ld	s1,24(sp)
    8000495a:	6942                	ld	s2,16(sp)
    8000495c:	6145                	addi	sp,sp,48
    8000495e:	8082                	ret
    return -1;
    80004960:	557d                	li	a0,-1
    80004962:	bfcd                	j	80004954 <argfd+0x44>
    80004964:	557d                	li	a0,-1
    80004966:	b7fd                	j	80004954 <argfd+0x44>

0000000080004968 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004968:	1101                	addi	sp,sp,-32
    8000496a:	ec06                	sd	ra,24(sp)
    8000496c:	e822                	sd	s0,16(sp)
    8000496e:	e426                	sd	s1,8(sp)
    80004970:	1000                	addi	s0,sp,32
    80004972:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004974:	f6dfc0ef          	jal	800018e0 <myproc>
    80004978:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000497a:	0d050793          	addi	a5,a0,208
    8000497e:	4501                	li	a0,0
    80004980:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004982:	6398                	ld	a4,0(a5)
    80004984:	cb19                	beqz	a4,8000499a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004986:	2505                	addiw	a0,a0,1
    80004988:	07a1                	addi	a5,a5,8
    8000498a:	fed51ce3          	bne	a0,a3,80004982 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000498e:	557d                	li	a0,-1
}
    80004990:	60e2                	ld	ra,24(sp)
    80004992:	6442                	ld	s0,16(sp)
    80004994:	64a2                	ld	s1,8(sp)
    80004996:	6105                	addi	sp,sp,32
    80004998:	8082                	ret
      p->ofile[fd] = f;
    8000499a:	01a50793          	addi	a5,a0,26
    8000499e:	078e                	slli	a5,a5,0x3
    800049a0:	963e                	add	a2,a2,a5
    800049a2:	e204                	sd	s1,0(a2)
      return fd;
    800049a4:	b7f5                	j	80004990 <fdalloc+0x28>

00000000800049a6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800049a6:	715d                	addi	sp,sp,-80
    800049a8:	e486                	sd	ra,72(sp)
    800049aa:	e0a2                	sd	s0,64(sp)
    800049ac:	fc26                	sd	s1,56(sp)
    800049ae:	f84a                	sd	s2,48(sp)
    800049b0:	f44e                	sd	s3,40(sp)
    800049b2:	ec56                	sd	s5,24(sp)
    800049b4:	e85a                	sd	s6,16(sp)
    800049b6:	0880                	addi	s0,sp,80
    800049b8:	8b2e                	mv	s6,a1
    800049ba:	89b2                	mv	s3,a2
    800049bc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800049be:	fb040593          	addi	a1,s0,-80
    800049c2:	822ff0ef          	jal	800039e4 <nameiparent>
    800049c6:	84aa                	mv	s1,a0
    800049c8:	10050a63          	beqz	a0,80004adc <create+0x136>
    return 0;

  ilock(dp);
    800049cc:	925fe0ef          	jal	800032f0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800049d0:	4601                	li	a2,0
    800049d2:	fb040593          	addi	a1,s0,-80
    800049d6:	8526                	mv	a0,s1
    800049d8:	d8dfe0ef          	jal	80003764 <dirlookup>
    800049dc:	8aaa                	mv	s5,a0
    800049de:	c129                	beqz	a0,80004a20 <create+0x7a>
    iunlockput(dp);
    800049e0:	8526                	mv	a0,s1
    800049e2:	b19fe0ef          	jal	800034fa <iunlockput>
    ilock(ip);
    800049e6:	8556                	mv	a0,s5
    800049e8:	909fe0ef          	jal	800032f0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800049ec:	4789                	li	a5,2
    800049ee:	02fb1463          	bne	s6,a5,80004a16 <create+0x70>
    800049f2:	044ad783          	lhu	a5,68(s5)
    800049f6:	37f9                	addiw	a5,a5,-2
    800049f8:	17c2                	slli	a5,a5,0x30
    800049fa:	93c1                	srli	a5,a5,0x30
    800049fc:	4705                	li	a4,1
    800049fe:	00f76c63          	bltu	a4,a5,80004a16 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a02:	8556                	mv	a0,s5
    80004a04:	60a6                	ld	ra,72(sp)
    80004a06:	6406                	ld	s0,64(sp)
    80004a08:	74e2                	ld	s1,56(sp)
    80004a0a:	7942                	ld	s2,48(sp)
    80004a0c:	79a2                	ld	s3,40(sp)
    80004a0e:	6ae2                	ld	s5,24(sp)
    80004a10:	6b42                	ld	s6,16(sp)
    80004a12:	6161                	addi	sp,sp,80
    80004a14:	8082                	ret
    iunlockput(ip);
    80004a16:	8556                	mv	a0,s5
    80004a18:	ae3fe0ef          	jal	800034fa <iunlockput>
    return 0;
    80004a1c:	4a81                	li	s5,0
    80004a1e:	b7d5                	j	80004a02 <create+0x5c>
    80004a20:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a22:	85da                	mv	a1,s6
    80004a24:	4088                	lw	a0,0(s1)
    80004a26:	f5afe0ef          	jal	80003180 <ialloc>
    80004a2a:	8a2a                	mv	s4,a0
    80004a2c:	cd15                	beqz	a0,80004a68 <create+0xc2>
  ilock(ip);
    80004a2e:	8c3fe0ef          	jal	800032f0 <ilock>
  ip->major = major;
    80004a32:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a36:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a3a:	4905                	li	s2,1
    80004a3c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a40:	8552                	mv	a0,s4
    80004a42:	ffafe0ef          	jal	8000323c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a46:	032b0763          	beq	s6,s2,80004a74 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a4a:	004a2603          	lw	a2,4(s4)
    80004a4e:	fb040593          	addi	a1,s0,-80
    80004a52:	8526                	mv	a0,s1
    80004a54:	eddfe0ef          	jal	80003930 <dirlink>
    80004a58:	06054563          	bltz	a0,80004ac2 <create+0x11c>
  iunlockput(dp);
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	a9dfe0ef          	jal	800034fa <iunlockput>
  return ip;
    80004a62:	8ad2                	mv	s5,s4
    80004a64:	7a02                	ld	s4,32(sp)
    80004a66:	bf71                	j	80004a02 <create+0x5c>
    iunlockput(dp);
    80004a68:	8526                	mv	a0,s1
    80004a6a:	a91fe0ef          	jal	800034fa <iunlockput>
    return 0;
    80004a6e:	8ad2                	mv	s5,s4
    80004a70:	7a02                	ld	s4,32(sp)
    80004a72:	bf41                	j	80004a02 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004a74:	004a2603          	lw	a2,4(s4)
    80004a78:	00003597          	auipc	a1,0x3
    80004a7c:	ba858593          	addi	a1,a1,-1112 # 80007620 <etext+0x620>
    80004a80:	8552                	mv	a0,s4
    80004a82:	eaffe0ef          	jal	80003930 <dirlink>
    80004a86:	02054e63          	bltz	a0,80004ac2 <create+0x11c>
    80004a8a:	40d0                	lw	a2,4(s1)
    80004a8c:	00003597          	auipc	a1,0x3
    80004a90:	b9c58593          	addi	a1,a1,-1124 # 80007628 <etext+0x628>
    80004a94:	8552                	mv	a0,s4
    80004a96:	e9bfe0ef          	jal	80003930 <dirlink>
    80004a9a:	02054463          	bltz	a0,80004ac2 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a9e:	004a2603          	lw	a2,4(s4)
    80004aa2:	fb040593          	addi	a1,s0,-80
    80004aa6:	8526                	mv	a0,s1
    80004aa8:	e89fe0ef          	jal	80003930 <dirlink>
    80004aac:	00054b63          	bltz	a0,80004ac2 <create+0x11c>
    dp->nlink++;  // for ".."
    80004ab0:	04a4d783          	lhu	a5,74(s1)
    80004ab4:	2785                	addiw	a5,a5,1
    80004ab6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004aba:	8526                	mv	a0,s1
    80004abc:	f80fe0ef          	jal	8000323c <iupdate>
    80004ac0:	bf71                	j	80004a5c <create+0xb6>
  ip->nlink = 0;
    80004ac2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004ac6:	8552                	mv	a0,s4
    80004ac8:	f74fe0ef          	jal	8000323c <iupdate>
  iunlockput(ip);
    80004acc:	8552                	mv	a0,s4
    80004ace:	a2dfe0ef          	jal	800034fa <iunlockput>
  iunlockput(dp);
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	a27fe0ef          	jal	800034fa <iunlockput>
  return 0;
    80004ad8:	7a02                	ld	s4,32(sp)
    80004ada:	b725                	j	80004a02 <create+0x5c>
    return 0;
    80004adc:	8aaa                	mv	s5,a0
    80004ade:	b715                	j	80004a02 <create+0x5c>

0000000080004ae0 <sys_dup>:
{
    80004ae0:	7179                	addi	sp,sp,-48
    80004ae2:	f406                	sd	ra,40(sp)
    80004ae4:	f022                	sd	s0,32(sp)
    80004ae6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ae8:	fd840613          	addi	a2,s0,-40
    80004aec:	4581                	li	a1,0
    80004aee:	4501                	li	a0,0
    80004af0:	e21ff0ef          	jal	80004910 <argfd>
    return -1;
    80004af4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004af6:	02054363          	bltz	a0,80004b1c <sys_dup+0x3c>
    80004afa:	ec26                	sd	s1,24(sp)
    80004afc:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004afe:	fd843903          	ld	s2,-40(s0)
    80004b02:	854a                	mv	a0,s2
    80004b04:	e65ff0ef          	jal	80004968 <fdalloc>
    80004b08:	84aa                	mv	s1,a0
    return -1;
    80004b0a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b0c:	00054d63          	bltz	a0,80004b26 <sys_dup+0x46>
  filedup(f);
    80004b10:	854a                	mv	a0,s2
    80004b12:	c48ff0ef          	jal	80003f5a <filedup>
  return fd;
    80004b16:	87a6                	mv	a5,s1
    80004b18:	64e2                	ld	s1,24(sp)
    80004b1a:	6942                	ld	s2,16(sp)
}
    80004b1c:	853e                	mv	a0,a5
    80004b1e:	70a2                	ld	ra,40(sp)
    80004b20:	7402                	ld	s0,32(sp)
    80004b22:	6145                	addi	sp,sp,48
    80004b24:	8082                	ret
    80004b26:	64e2                	ld	s1,24(sp)
    80004b28:	6942                	ld	s2,16(sp)
    80004b2a:	bfcd                	j	80004b1c <sys_dup+0x3c>

0000000080004b2c <sys_read>:
{
    80004b2c:	7179                	addi	sp,sp,-48
    80004b2e:	f406                	sd	ra,40(sp)
    80004b30:	f022                	sd	s0,32(sp)
    80004b32:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b34:	fd840593          	addi	a1,s0,-40
    80004b38:	4505                	li	a0,1
    80004b3a:	d2dfd0ef          	jal	80002866 <argaddr>
  argint(2, &n);
    80004b3e:	fe440593          	addi	a1,s0,-28
    80004b42:	4509                	li	a0,2
    80004b44:	d07fd0ef          	jal	8000284a <argint>
  if(argfd(0, 0, &f) < 0)
    80004b48:	fe840613          	addi	a2,s0,-24
    80004b4c:	4581                	li	a1,0
    80004b4e:	4501                	li	a0,0
    80004b50:	dc1ff0ef          	jal	80004910 <argfd>
    80004b54:	87aa                	mv	a5,a0
    return -1;
    80004b56:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b58:	0007ca63          	bltz	a5,80004b6c <sys_read+0x40>
  return fileread(f, p, n);
    80004b5c:	fe442603          	lw	a2,-28(s0)
    80004b60:	fd843583          	ld	a1,-40(s0)
    80004b64:	fe843503          	ld	a0,-24(s0)
    80004b68:	d58ff0ef          	jal	800040c0 <fileread>
}
    80004b6c:	70a2                	ld	ra,40(sp)
    80004b6e:	7402                	ld	s0,32(sp)
    80004b70:	6145                	addi	sp,sp,48
    80004b72:	8082                	ret

0000000080004b74 <sys_write>:
{
    80004b74:	7179                	addi	sp,sp,-48
    80004b76:	f406                	sd	ra,40(sp)
    80004b78:	f022                	sd	s0,32(sp)
    80004b7a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b7c:	fd840593          	addi	a1,s0,-40
    80004b80:	4505                	li	a0,1
    80004b82:	ce5fd0ef          	jal	80002866 <argaddr>
  argint(2, &n);
    80004b86:	fe440593          	addi	a1,s0,-28
    80004b8a:	4509                	li	a0,2
    80004b8c:	cbffd0ef          	jal	8000284a <argint>
  if(argfd(0, 0, &f) < 0)
    80004b90:	fe840613          	addi	a2,s0,-24
    80004b94:	4581                	li	a1,0
    80004b96:	4501                	li	a0,0
    80004b98:	d79ff0ef          	jal	80004910 <argfd>
    80004b9c:	87aa                	mv	a5,a0
    return -1;
    80004b9e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ba0:	0007ca63          	bltz	a5,80004bb4 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ba4:	fe442603          	lw	a2,-28(s0)
    80004ba8:	fd843583          	ld	a1,-40(s0)
    80004bac:	fe843503          	ld	a0,-24(s0)
    80004bb0:	dceff0ef          	jal	8000417e <filewrite>
}
    80004bb4:	70a2                	ld	ra,40(sp)
    80004bb6:	7402                	ld	s0,32(sp)
    80004bb8:	6145                	addi	sp,sp,48
    80004bba:	8082                	ret

0000000080004bbc <sys_close>:
{
    80004bbc:	1101                	addi	sp,sp,-32
    80004bbe:	ec06                	sd	ra,24(sp)
    80004bc0:	e822                	sd	s0,16(sp)
    80004bc2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004bc4:	fe040613          	addi	a2,s0,-32
    80004bc8:	fec40593          	addi	a1,s0,-20
    80004bcc:	4501                	li	a0,0
    80004bce:	d43ff0ef          	jal	80004910 <argfd>
    return -1;
    80004bd2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004bd4:	02054063          	bltz	a0,80004bf4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004bd8:	d09fc0ef          	jal	800018e0 <myproc>
    80004bdc:	fec42783          	lw	a5,-20(s0)
    80004be0:	07e9                	addi	a5,a5,26
    80004be2:	078e                	slli	a5,a5,0x3
    80004be4:	953e                	add	a0,a0,a5
    80004be6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004bea:	fe043503          	ld	a0,-32(s0)
    80004bee:	bb2ff0ef          	jal	80003fa0 <fileclose>
  return 0;
    80004bf2:	4781                	li	a5,0
}
    80004bf4:	853e                	mv	a0,a5
    80004bf6:	60e2                	ld	ra,24(sp)
    80004bf8:	6442                	ld	s0,16(sp)
    80004bfa:	6105                	addi	sp,sp,32
    80004bfc:	8082                	ret

0000000080004bfe <sys_fstat>:
{
    80004bfe:	1101                	addi	sp,sp,-32
    80004c00:	ec06                	sd	ra,24(sp)
    80004c02:	e822                	sd	s0,16(sp)
    80004c04:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c06:	fe040593          	addi	a1,s0,-32
    80004c0a:	4505                	li	a0,1
    80004c0c:	c5bfd0ef          	jal	80002866 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c10:	fe840613          	addi	a2,s0,-24
    80004c14:	4581                	li	a1,0
    80004c16:	4501                	li	a0,0
    80004c18:	cf9ff0ef          	jal	80004910 <argfd>
    80004c1c:	87aa                	mv	a5,a0
    return -1;
    80004c1e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c20:	0007c863          	bltz	a5,80004c30 <sys_fstat+0x32>
  return filestat(f, st);
    80004c24:	fe043583          	ld	a1,-32(s0)
    80004c28:	fe843503          	ld	a0,-24(s0)
    80004c2c:	c36ff0ef          	jal	80004062 <filestat>
}
    80004c30:	60e2                	ld	ra,24(sp)
    80004c32:	6442                	ld	s0,16(sp)
    80004c34:	6105                	addi	sp,sp,32
    80004c36:	8082                	ret

0000000080004c38 <sys_link>:
{
    80004c38:	7169                	addi	sp,sp,-304
    80004c3a:	f606                	sd	ra,296(sp)
    80004c3c:	f222                	sd	s0,288(sp)
    80004c3e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c40:	08000613          	li	a2,128
    80004c44:	ed040593          	addi	a1,s0,-304
    80004c48:	4501                	li	a0,0
    80004c4a:	c39fd0ef          	jal	80002882 <argstr>
    return -1;
    80004c4e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c50:	0c054e63          	bltz	a0,80004d2c <sys_link+0xf4>
    80004c54:	08000613          	li	a2,128
    80004c58:	f5040593          	addi	a1,s0,-176
    80004c5c:	4505                	li	a0,1
    80004c5e:	c25fd0ef          	jal	80002882 <argstr>
    return -1;
    80004c62:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c64:	0c054463          	bltz	a0,80004d2c <sys_link+0xf4>
    80004c68:	ee26                	sd	s1,280(sp)
  begin_op();
    80004c6a:	f1dfe0ef          	jal	80003b86 <begin_op>
  if((ip = namei(old)) == 0){
    80004c6e:	ed040513          	addi	a0,s0,-304
    80004c72:	d59fe0ef          	jal	800039ca <namei>
    80004c76:	84aa                	mv	s1,a0
    80004c78:	c53d                	beqz	a0,80004ce6 <sys_link+0xae>
  ilock(ip);
    80004c7a:	e76fe0ef          	jal	800032f0 <ilock>
  if(ip->type == T_DIR){
    80004c7e:	04449703          	lh	a4,68(s1)
    80004c82:	4785                	li	a5,1
    80004c84:	06f70663          	beq	a4,a5,80004cf0 <sys_link+0xb8>
    80004c88:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004c8a:	04a4d783          	lhu	a5,74(s1)
    80004c8e:	2785                	addiw	a5,a5,1
    80004c90:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c94:	8526                	mv	a0,s1
    80004c96:	da6fe0ef          	jal	8000323c <iupdate>
  iunlock(ip);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	f02fe0ef          	jal	8000339e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ca0:	fd040593          	addi	a1,s0,-48
    80004ca4:	f5040513          	addi	a0,s0,-176
    80004ca8:	d3dfe0ef          	jal	800039e4 <nameiparent>
    80004cac:	892a                	mv	s2,a0
    80004cae:	cd21                	beqz	a0,80004d06 <sys_link+0xce>
  ilock(dp);
    80004cb0:	e40fe0ef          	jal	800032f0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004cb4:	00092703          	lw	a4,0(s2)
    80004cb8:	409c                	lw	a5,0(s1)
    80004cba:	04f71363          	bne	a4,a5,80004d00 <sys_link+0xc8>
    80004cbe:	40d0                	lw	a2,4(s1)
    80004cc0:	fd040593          	addi	a1,s0,-48
    80004cc4:	854a                	mv	a0,s2
    80004cc6:	c6bfe0ef          	jal	80003930 <dirlink>
    80004cca:	02054b63          	bltz	a0,80004d00 <sys_link+0xc8>
  iunlockput(dp);
    80004cce:	854a                	mv	a0,s2
    80004cd0:	82bfe0ef          	jal	800034fa <iunlockput>
  iput(ip);
    80004cd4:	8526                	mv	a0,s1
    80004cd6:	f9cfe0ef          	jal	80003472 <iput>
  end_op();
    80004cda:	f17fe0ef          	jal	80003bf0 <end_op>
  return 0;
    80004cde:	4781                	li	a5,0
    80004ce0:	64f2                	ld	s1,280(sp)
    80004ce2:	6952                	ld	s2,272(sp)
    80004ce4:	a0a1                	j	80004d2c <sys_link+0xf4>
    end_op();
    80004ce6:	f0bfe0ef          	jal	80003bf0 <end_op>
    return -1;
    80004cea:	57fd                	li	a5,-1
    80004cec:	64f2                	ld	s1,280(sp)
    80004cee:	a83d                	j	80004d2c <sys_link+0xf4>
    iunlockput(ip);
    80004cf0:	8526                	mv	a0,s1
    80004cf2:	809fe0ef          	jal	800034fa <iunlockput>
    end_op();
    80004cf6:	efbfe0ef          	jal	80003bf0 <end_op>
    return -1;
    80004cfa:	57fd                	li	a5,-1
    80004cfc:	64f2                	ld	s1,280(sp)
    80004cfe:	a03d                	j	80004d2c <sys_link+0xf4>
    iunlockput(dp);
    80004d00:	854a                	mv	a0,s2
    80004d02:	ff8fe0ef          	jal	800034fa <iunlockput>
  ilock(ip);
    80004d06:	8526                	mv	a0,s1
    80004d08:	de8fe0ef          	jal	800032f0 <ilock>
  ip->nlink--;
    80004d0c:	04a4d783          	lhu	a5,74(s1)
    80004d10:	37fd                	addiw	a5,a5,-1
    80004d12:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d16:	8526                	mv	a0,s1
    80004d18:	d24fe0ef          	jal	8000323c <iupdate>
  iunlockput(ip);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	fdcfe0ef          	jal	800034fa <iunlockput>
  end_op();
    80004d22:	ecffe0ef          	jal	80003bf0 <end_op>
  return -1;
    80004d26:	57fd                	li	a5,-1
    80004d28:	64f2                	ld	s1,280(sp)
    80004d2a:	6952                	ld	s2,272(sp)
}
    80004d2c:	853e                	mv	a0,a5
    80004d2e:	70b2                	ld	ra,296(sp)
    80004d30:	7412                	ld	s0,288(sp)
    80004d32:	6155                	addi	sp,sp,304
    80004d34:	8082                	ret

0000000080004d36 <sys_unlink>:
{
    80004d36:	7151                	addi	sp,sp,-240
    80004d38:	f586                	sd	ra,232(sp)
    80004d3a:	f1a2                	sd	s0,224(sp)
    80004d3c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004d3e:	08000613          	li	a2,128
    80004d42:	f3040593          	addi	a1,s0,-208
    80004d46:	4501                	li	a0,0
    80004d48:	b3bfd0ef          	jal	80002882 <argstr>
    80004d4c:	16054063          	bltz	a0,80004eac <sys_unlink+0x176>
    80004d50:	eda6                	sd	s1,216(sp)
  begin_op();
    80004d52:	e35fe0ef          	jal	80003b86 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d56:	fb040593          	addi	a1,s0,-80
    80004d5a:	f3040513          	addi	a0,s0,-208
    80004d5e:	c87fe0ef          	jal	800039e4 <nameiparent>
    80004d62:	84aa                	mv	s1,a0
    80004d64:	c945                	beqz	a0,80004e14 <sys_unlink+0xde>
  ilock(dp);
    80004d66:	d8afe0ef          	jal	800032f0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004d6a:	00003597          	auipc	a1,0x3
    80004d6e:	8b658593          	addi	a1,a1,-1866 # 80007620 <etext+0x620>
    80004d72:	fb040513          	addi	a0,s0,-80
    80004d76:	9d9fe0ef          	jal	8000374e <namecmp>
    80004d7a:	10050e63          	beqz	a0,80004e96 <sys_unlink+0x160>
    80004d7e:	00003597          	auipc	a1,0x3
    80004d82:	8aa58593          	addi	a1,a1,-1878 # 80007628 <etext+0x628>
    80004d86:	fb040513          	addi	a0,s0,-80
    80004d8a:	9c5fe0ef          	jal	8000374e <namecmp>
    80004d8e:	10050463          	beqz	a0,80004e96 <sys_unlink+0x160>
    80004d92:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d94:	f2c40613          	addi	a2,s0,-212
    80004d98:	fb040593          	addi	a1,s0,-80
    80004d9c:	8526                	mv	a0,s1
    80004d9e:	9c7fe0ef          	jal	80003764 <dirlookup>
    80004da2:	892a                	mv	s2,a0
    80004da4:	0e050863          	beqz	a0,80004e94 <sys_unlink+0x15e>
  ilock(ip);
    80004da8:	d48fe0ef          	jal	800032f0 <ilock>
  if(ip->nlink < 1)
    80004dac:	04a91783          	lh	a5,74(s2)
    80004db0:	06f05763          	blez	a5,80004e1e <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004db4:	04491703          	lh	a4,68(s2)
    80004db8:	4785                	li	a5,1
    80004dba:	06f70963          	beq	a4,a5,80004e2c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004dbe:	4641                	li	a2,16
    80004dc0:	4581                	li	a1,0
    80004dc2:	fc040513          	addi	a0,s0,-64
    80004dc6:	f03fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004dca:	4741                	li	a4,16
    80004dcc:	f2c42683          	lw	a3,-212(s0)
    80004dd0:	fc040613          	addi	a2,s0,-64
    80004dd4:	4581                	li	a1,0
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	869fe0ef          	jal	80003640 <writei>
    80004ddc:	47c1                	li	a5,16
    80004dde:	08f51b63          	bne	a0,a5,80004e74 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004de2:	04491703          	lh	a4,68(s2)
    80004de6:	4785                	li	a5,1
    80004de8:	08f70d63          	beq	a4,a5,80004e82 <sys_unlink+0x14c>
  iunlockput(dp);
    80004dec:	8526                	mv	a0,s1
    80004dee:	f0cfe0ef          	jal	800034fa <iunlockput>
  ip->nlink--;
    80004df2:	04a95783          	lhu	a5,74(s2)
    80004df6:	37fd                	addiw	a5,a5,-1
    80004df8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004dfc:	854a                	mv	a0,s2
    80004dfe:	c3efe0ef          	jal	8000323c <iupdate>
  iunlockput(ip);
    80004e02:	854a                	mv	a0,s2
    80004e04:	ef6fe0ef          	jal	800034fa <iunlockput>
  end_op();
    80004e08:	de9fe0ef          	jal	80003bf0 <end_op>
  return 0;
    80004e0c:	4501                	li	a0,0
    80004e0e:	64ee                	ld	s1,216(sp)
    80004e10:	694e                	ld	s2,208(sp)
    80004e12:	a849                	j	80004ea4 <sys_unlink+0x16e>
    end_op();
    80004e14:	dddfe0ef          	jal	80003bf0 <end_op>
    return -1;
    80004e18:	557d                	li	a0,-1
    80004e1a:	64ee                	ld	s1,216(sp)
    80004e1c:	a061                	j	80004ea4 <sys_unlink+0x16e>
    80004e1e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e20:	00003517          	auipc	a0,0x3
    80004e24:	81050513          	addi	a0,a0,-2032 # 80007630 <etext+0x630>
    80004e28:	96dfb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e2c:	04c92703          	lw	a4,76(s2)
    80004e30:	02000793          	li	a5,32
    80004e34:	f8e7f5e3          	bgeu	a5,a4,80004dbe <sys_unlink+0x88>
    80004e38:	e5ce                	sd	s3,200(sp)
    80004e3a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e3e:	4741                	li	a4,16
    80004e40:	86ce                	mv	a3,s3
    80004e42:	f1840613          	addi	a2,s0,-232
    80004e46:	4581                	li	a1,0
    80004e48:	854a                	mv	a0,s2
    80004e4a:	efafe0ef          	jal	80003544 <readi>
    80004e4e:	47c1                	li	a5,16
    80004e50:	00f51c63          	bne	a0,a5,80004e68 <sys_unlink+0x132>
    if(de.inum != 0)
    80004e54:	f1845783          	lhu	a5,-232(s0)
    80004e58:	efa1                	bnez	a5,80004eb0 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e5a:	29c1                	addiw	s3,s3,16
    80004e5c:	04c92783          	lw	a5,76(s2)
    80004e60:	fcf9efe3          	bltu	s3,a5,80004e3e <sys_unlink+0x108>
    80004e64:	69ae                	ld	s3,200(sp)
    80004e66:	bfa1                	j	80004dbe <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004e68:	00002517          	auipc	a0,0x2
    80004e6c:	7e050513          	addi	a0,a0,2016 # 80007648 <etext+0x648>
    80004e70:	925fb0ef          	jal	80000794 <panic>
    80004e74:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004e76:	00002517          	auipc	a0,0x2
    80004e7a:	7ea50513          	addi	a0,a0,2026 # 80007660 <etext+0x660>
    80004e7e:	917fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004e82:	04a4d783          	lhu	a5,74(s1)
    80004e86:	37fd                	addiw	a5,a5,-1
    80004e88:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	baefe0ef          	jal	8000323c <iupdate>
    80004e92:	bfa9                	j	80004dec <sys_unlink+0xb6>
    80004e94:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004e96:	8526                	mv	a0,s1
    80004e98:	e62fe0ef          	jal	800034fa <iunlockput>
  end_op();
    80004e9c:	d55fe0ef          	jal	80003bf0 <end_op>
  return -1;
    80004ea0:	557d                	li	a0,-1
    80004ea2:	64ee                	ld	s1,216(sp)
}
    80004ea4:	70ae                	ld	ra,232(sp)
    80004ea6:	740e                	ld	s0,224(sp)
    80004ea8:	616d                	addi	sp,sp,240
    80004eaa:	8082                	ret
    return -1;
    80004eac:	557d                	li	a0,-1
    80004eae:	bfdd                	j	80004ea4 <sys_unlink+0x16e>
    iunlockput(ip);
    80004eb0:	854a                	mv	a0,s2
    80004eb2:	e48fe0ef          	jal	800034fa <iunlockput>
    goto bad;
    80004eb6:	694e                	ld	s2,208(sp)
    80004eb8:	69ae                	ld	s3,200(sp)
    80004eba:	bff1                	j	80004e96 <sys_unlink+0x160>

0000000080004ebc <sys_open>:

uint64
sys_open(void)
{
    80004ebc:	7131                	addi	sp,sp,-192
    80004ebe:	fd06                	sd	ra,184(sp)
    80004ec0:	f922                	sd	s0,176(sp)
    80004ec2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004ec4:	f4c40593          	addi	a1,s0,-180
    80004ec8:	4505                	li	a0,1
    80004eca:	981fd0ef          	jal	8000284a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ece:	08000613          	li	a2,128
    80004ed2:	f5040593          	addi	a1,s0,-176
    80004ed6:	4501                	li	a0,0
    80004ed8:	9abfd0ef          	jal	80002882 <argstr>
    80004edc:	87aa                	mv	a5,a0
    return -1;
    80004ede:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ee0:	0a07c263          	bltz	a5,80004f84 <sys_open+0xc8>
    80004ee4:	f526                	sd	s1,168(sp)

  begin_op();
    80004ee6:	ca1fe0ef          	jal	80003b86 <begin_op>

  if(omode & O_CREATE){
    80004eea:	f4c42783          	lw	a5,-180(s0)
    80004eee:	2007f793          	andi	a5,a5,512
    80004ef2:	c3d5                	beqz	a5,80004f96 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004ef4:	4681                	li	a3,0
    80004ef6:	4601                	li	a2,0
    80004ef8:	4589                	li	a1,2
    80004efa:	f5040513          	addi	a0,s0,-176
    80004efe:	aa9ff0ef          	jal	800049a6 <create>
    80004f02:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f04:	c541                	beqz	a0,80004f8c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f06:	04449703          	lh	a4,68(s1)
    80004f0a:	478d                	li	a5,3
    80004f0c:	00f71763          	bne	a4,a5,80004f1a <sys_open+0x5e>
    80004f10:	0464d703          	lhu	a4,70(s1)
    80004f14:	47a5                	li	a5,9
    80004f16:	0ae7ed63          	bltu	a5,a4,80004fd0 <sys_open+0x114>
    80004f1a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f1c:	fe1fe0ef          	jal	80003efc <filealloc>
    80004f20:	892a                	mv	s2,a0
    80004f22:	c179                	beqz	a0,80004fe8 <sys_open+0x12c>
    80004f24:	ed4e                	sd	s3,152(sp)
    80004f26:	a43ff0ef          	jal	80004968 <fdalloc>
    80004f2a:	89aa                	mv	s3,a0
    80004f2c:	0a054a63          	bltz	a0,80004fe0 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f30:	04449703          	lh	a4,68(s1)
    80004f34:	478d                	li	a5,3
    80004f36:	0cf70263          	beq	a4,a5,80004ffa <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f3a:	4789                	li	a5,2
    80004f3c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f40:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f44:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f48:	f4c42783          	lw	a5,-180(s0)
    80004f4c:	0017c713          	xori	a4,a5,1
    80004f50:	8b05                	andi	a4,a4,1
    80004f52:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f56:	0037f713          	andi	a4,a5,3
    80004f5a:	00e03733          	snez	a4,a4
    80004f5e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f62:	4007f793          	andi	a5,a5,1024
    80004f66:	c791                	beqz	a5,80004f72 <sys_open+0xb6>
    80004f68:	04449703          	lh	a4,68(s1)
    80004f6c:	4789                	li	a5,2
    80004f6e:	08f70d63          	beq	a4,a5,80005008 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004f72:	8526                	mv	a0,s1
    80004f74:	c2afe0ef          	jal	8000339e <iunlock>
  end_op();
    80004f78:	c79fe0ef          	jal	80003bf0 <end_op>

  return fd;
    80004f7c:	854e                	mv	a0,s3
    80004f7e:	74aa                	ld	s1,168(sp)
    80004f80:	790a                	ld	s2,160(sp)
    80004f82:	69ea                	ld	s3,152(sp)
}
    80004f84:	70ea                	ld	ra,184(sp)
    80004f86:	744a                	ld	s0,176(sp)
    80004f88:	6129                	addi	sp,sp,192
    80004f8a:	8082                	ret
      end_op();
    80004f8c:	c65fe0ef          	jal	80003bf0 <end_op>
      return -1;
    80004f90:	557d                	li	a0,-1
    80004f92:	74aa                	ld	s1,168(sp)
    80004f94:	bfc5                	j	80004f84 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004f96:	f5040513          	addi	a0,s0,-176
    80004f9a:	a31fe0ef          	jal	800039ca <namei>
    80004f9e:	84aa                	mv	s1,a0
    80004fa0:	c11d                	beqz	a0,80004fc6 <sys_open+0x10a>
    ilock(ip);
    80004fa2:	b4efe0ef          	jal	800032f0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004fa6:	04449703          	lh	a4,68(s1)
    80004faa:	4785                	li	a5,1
    80004fac:	f4f71de3          	bne	a4,a5,80004f06 <sys_open+0x4a>
    80004fb0:	f4c42783          	lw	a5,-180(s0)
    80004fb4:	d3bd                	beqz	a5,80004f1a <sys_open+0x5e>
      iunlockput(ip);
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	d42fe0ef          	jal	800034fa <iunlockput>
      end_op();
    80004fbc:	c35fe0ef          	jal	80003bf0 <end_op>
      return -1;
    80004fc0:	557d                	li	a0,-1
    80004fc2:	74aa                	ld	s1,168(sp)
    80004fc4:	b7c1                	j	80004f84 <sys_open+0xc8>
      end_op();
    80004fc6:	c2bfe0ef          	jal	80003bf0 <end_op>
      return -1;
    80004fca:	557d                	li	a0,-1
    80004fcc:	74aa                	ld	s1,168(sp)
    80004fce:	bf5d                	j	80004f84 <sys_open+0xc8>
    iunlockput(ip);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	d28fe0ef          	jal	800034fa <iunlockput>
    end_op();
    80004fd6:	c1bfe0ef          	jal	80003bf0 <end_op>
    return -1;
    80004fda:	557d                	li	a0,-1
    80004fdc:	74aa                	ld	s1,168(sp)
    80004fde:	b75d                	j	80004f84 <sys_open+0xc8>
      fileclose(f);
    80004fe0:	854a                	mv	a0,s2
    80004fe2:	fbffe0ef          	jal	80003fa0 <fileclose>
    80004fe6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	d10fe0ef          	jal	800034fa <iunlockput>
    end_op();
    80004fee:	c03fe0ef          	jal	80003bf0 <end_op>
    return -1;
    80004ff2:	557d                	li	a0,-1
    80004ff4:	74aa                	ld	s1,168(sp)
    80004ff6:	790a                	ld	s2,160(sp)
    80004ff8:	b771                	j	80004f84 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004ffa:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004ffe:	04649783          	lh	a5,70(s1)
    80005002:	02f91223          	sh	a5,36(s2)
    80005006:	bf3d                	j	80004f44 <sys_open+0x88>
    itrunc(ip);
    80005008:	8526                	mv	a0,s1
    8000500a:	bd4fe0ef          	jal	800033de <itrunc>
    8000500e:	b795                	j	80004f72 <sys_open+0xb6>

0000000080005010 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005010:	7175                	addi	sp,sp,-144
    80005012:	e506                	sd	ra,136(sp)
    80005014:	e122                	sd	s0,128(sp)
    80005016:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005018:	b6ffe0ef          	jal	80003b86 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000501c:	08000613          	li	a2,128
    80005020:	f7040593          	addi	a1,s0,-144
    80005024:	4501                	li	a0,0
    80005026:	85dfd0ef          	jal	80002882 <argstr>
    8000502a:	02054363          	bltz	a0,80005050 <sys_mkdir+0x40>
    8000502e:	4681                	li	a3,0
    80005030:	4601                	li	a2,0
    80005032:	4585                	li	a1,1
    80005034:	f7040513          	addi	a0,s0,-144
    80005038:	96fff0ef          	jal	800049a6 <create>
    8000503c:	c911                	beqz	a0,80005050 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000503e:	cbcfe0ef          	jal	800034fa <iunlockput>
  end_op();
    80005042:	baffe0ef          	jal	80003bf0 <end_op>
  return 0;
    80005046:	4501                	li	a0,0
}
    80005048:	60aa                	ld	ra,136(sp)
    8000504a:	640a                	ld	s0,128(sp)
    8000504c:	6149                	addi	sp,sp,144
    8000504e:	8082                	ret
    end_op();
    80005050:	ba1fe0ef          	jal	80003bf0 <end_op>
    return -1;
    80005054:	557d                	li	a0,-1
    80005056:	bfcd                	j	80005048 <sys_mkdir+0x38>

0000000080005058 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005058:	7135                	addi	sp,sp,-160
    8000505a:	ed06                	sd	ra,152(sp)
    8000505c:	e922                	sd	s0,144(sp)
    8000505e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005060:	b27fe0ef          	jal	80003b86 <begin_op>
  argint(1, &major);
    80005064:	f6c40593          	addi	a1,s0,-148
    80005068:	4505                	li	a0,1
    8000506a:	fe0fd0ef          	jal	8000284a <argint>
  argint(2, &minor);
    8000506e:	f6840593          	addi	a1,s0,-152
    80005072:	4509                	li	a0,2
    80005074:	fd6fd0ef          	jal	8000284a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005078:	08000613          	li	a2,128
    8000507c:	f7040593          	addi	a1,s0,-144
    80005080:	4501                	li	a0,0
    80005082:	801fd0ef          	jal	80002882 <argstr>
    80005086:	02054563          	bltz	a0,800050b0 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000508a:	f6841683          	lh	a3,-152(s0)
    8000508e:	f6c41603          	lh	a2,-148(s0)
    80005092:	458d                	li	a1,3
    80005094:	f7040513          	addi	a0,s0,-144
    80005098:	90fff0ef          	jal	800049a6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000509c:	c911                	beqz	a0,800050b0 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000509e:	c5cfe0ef          	jal	800034fa <iunlockput>
  end_op();
    800050a2:	b4ffe0ef          	jal	80003bf0 <end_op>
  return 0;
    800050a6:	4501                	li	a0,0
}
    800050a8:	60ea                	ld	ra,152(sp)
    800050aa:	644a                	ld	s0,144(sp)
    800050ac:	610d                	addi	sp,sp,160
    800050ae:	8082                	ret
    end_op();
    800050b0:	b41fe0ef          	jal	80003bf0 <end_op>
    return -1;
    800050b4:	557d                	li	a0,-1
    800050b6:	bfcd                	j	800050a8 <sys_mknod+0x50>

00000000800050b8 <sys_chdir>:

uint64
sys_chdir(void)
{
    800050b8:	7135                	addi	sp,sp,-160
    800050ba:	ed06                	sd	ra,152(sp)
    800050bc:	e922                	sd	s0,144(sp)
    800050be:	e14a                	sd	s2,128(sp)
    800050c0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800050c2:	81ffc0ef          	jal	800018e0 <myproc>
    800050c6:	892a                	mv	s2,a0
  
  begin_op();
    800050c8:	abffe0ef          	jal	80003b86 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800050cc:	08000613          	li	a2,128
    800050d0:	f6040593          	addi	a1,s0,-160
    800050d4:	4501                	li	a0,0
    800050d6:	facfd0ef          	jal	80002882 <argstr>
    800050da:	04054363          	bltz	a0,80005120 <sys_chdir+0x68>
    800050de:	e526                	sd	s1,136(sp)
    800050e0:	f6040513          	addi	a0,s0,-160
    800050e4:	8e7fe0ef          	jal	800039ca <namei>
    800050e8:	84aa                	mv	s1,a0
    800050ea:	c915                	beqz	a0,8000511e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800050ec:	a04fe0ef          	jal	800032f0 <ilock>
  if(ip->type != T_DIR){
    800050f0:	04449703          	lh	a4,68(s1)
    800050f4:	4785                	li	a5,1
    800050f6:	02f71963          	bne	a4,a5,80005128 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800050fa:	8526                	mv	a0,s1
    800050fc:	aa2fe0ef          	jal	8000339e <iunlock>
  iput(p->cwd);
    80005100:	15093503          	ld	a0,336(s2)
    80005104:	b6efe0ef          	jal	80003472 <iput>
  end_op();
    80005108:	ae9fe0ef          	jal	80003bf0 <end_op>
  p->cwd = ip;
    8000510c:	14993823          	sd	s1,336(s2)
  return 0;
    80005110:	4501                	li	a0,0
    80005112:	64aa                	ld	s1,136(sp)
}
    80005114:	60ea                	ld	ra,152(sp)
    80005116:	644a                	ld	s0,144(sp)
    80005118:	690a                	ld	s2,128(sp)
    8000511a:	610d                	addi	sp,sp,160
    8000511c:	8082                	ret
    8000511e:	64aa                	ld	s1,136(sp)
    end_op();
    80005120:	ad1fe0ef          	jal	80003bf0 <end_op>
    return -1;
    80005124:	557d                	li	a0,-1
    80005126:	b7fd                	j	80005114 <sys_chdir+0x5c>
    iunlockput(ip);
    80005128:	8526                	mv	a0,s1
    8000512a:	bd0fe0ef          	jal	800034fa <iunlockput>
    end_op();
    8000512e:	ac3fe0ef          	jal	80003bf0 <end_op>
    return -1;
    80005132:	557d                	li	a0,-1
    80005134:	64aa                	ld	s1,136(sp)
    80005136:	bff9                	j	80005114 <sys_chdir+0x5c>

0000000080005138 <sys_exec>:

uint64
sys_exec(void)
{
    80005138:	7121                	addi	sp,sp,-448
    8000513a:	ff06                	sd	ra,440(sp)
    8000513c:	fb22                	sd	s0,432(sp)
    8000513e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005140:	e4840593          	addi	a1,s0,-440
    80005144:	4505                	li	a0,1
    80005146:	f20fd0ef          	jal	80002866 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000514a:	08000613          	li	a2,128
    8000514e:	f5040593          	addi	a1,s0,-176
    80005152:	4501                	li	a0,0
    80005154:	f2efd0ef          	jal	80002882 <argstr>
    80005158:	87aa                	mv	a5,a0
    return -1;
    8000515a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000515c:	0c07c463          	bltz	a5,80005224 <sys_exec+0xec>
    80005160:	f726                	sd	s1,424(sp)
    80005162:	f34a                	sd	s2,416(sp)
    80005164:	ef4e                	sd	s3,408(sp)
    80005166:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005168:	10000613          	li	a2,256
    8000516c:	4581                	li	a1,0
    8000516e:	e5040513          	addi	a0,s0,-432
    80005172:	b57fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005176:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000517a:	89a6                	mv	s3,s1
    8000517c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000517e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005182:	00391513          	slli	a0,s2,0x3
    80005186:	e4040593          	addi	a1,s0,-448
    8000518a:	e4843783          	ld	a5,-440(s0)
    8000518e:	953e                	add	a0,a0,a5
    80005190:	e30fd0ef          	jal	800027c0 <fetchaddr>
    80005194:	02054663          	bltz	a0,800051c0 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005198:	e4043783          	ld	a5,-448(s0)
    8000519c:	c3a9                	beqz	a5,800051de <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000519e:	987fb0ef          	jal	80000b24 <kalloc>
    800051a2:	85aa                	mv	a1,a0
    800051a4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800051a8:	cd01                	beqz	a0,800051c0 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051aa:	6605                	lui	a2,0x1
    800051ac:	e4043503          	ld	a0,-448(s0)
    800051b0:	e5afd0ef          	jal	8000280a <fetchstr>
    800051b4:	00054663          	bltz	a0,800051c0 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800051b8:	0905                	addi	s2,s2,1
    800051ba:	09a1                	addi	s3,s3,8
    800051bc:	fd4913e3          	bne	s2,s4,80005182 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051c0:	f5040913          	addi	s2,s0,-176
    800051c4:	6088                	ld	a0,0(s1)
    800051c6:	c931                	beqz	a0,8000521a <sys_exec+0xe2>
    kfree(argv[i]);
    800051c8:	87bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051cc:	04a1                	addi	s1,s1,8
    800051ce:	ff249be3          	bne	s1,s2,800051c4 <sys_exec+0x8c>
  return -1;
    800051d2:	557d                	li	a0,-1
    800051d4:	74ba                	ld	s1,424(sp)
    800051d6:	791a                	ld	s2,416(sp)
    800051d8:	69fa                	ld	s3,408(sp)
    800051da:	6a5a                	ld	s4,400(sp)
    800051dc:	a0a1                	j	80005224 <sys_exec+0xec>
      argv[i] = 0;
    800051de:	0009079b          	sext.w	a5,s2
    800051e2:	078e                	slli	a5,a5,0x3
    800051e4:	fd078793          	addi	a5,a5,-48
    800051e8:	97a2                	add	a5,a5,s0
    800051ea:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800051ee:	e5040593          	addi	a1,s0,-432
    800051f2:	f5040513          	addi	a0,s0,-176
    800051f6:	ba8ff0ef          	jal	8000459e <exec>
    800051fa:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051fc:	f5040993          	addi	s3,s0,-176
    80005200:	6088                	ld	a0,0(s1)
    80005202:	c511                	beqz	a0,8000520e <sys_exec+0xd6>
    kfree(argv[i]);
    80005204:	83ffb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005208:	04a1                	addi	s1,s1,8
    8000520a:	ff349be3          	bne	s1,s3,80005200 <sys_exec+0xc8>
  return ret;
    8000520e:	854a                	mv	a0,s2
    80005210:	74ba                	ld	s1,424(sp)
    80005212:	791a                	ld	s2,416(sp)
    80005214:	69fa                	ld	s3,408(sp)
    80005216:	6a5a                	ld	s4,400(sp)
    80005218:	a031                	j	80005224 <sys_exec+0xec>
  return -1;
    8000521a:	557d                	li	a0,-1
    8000521c:	74ba                	ld	s1,424(sp)
    8000521e:	791a                	ld	s2,416(sp)
    80005220:	69fa                	ld	s3,408(sp)
    80005222:	6a5a                	ld	s4,400(sp)
}
    80005224:	70fa                	ld	ra,440(sp)
    80005226:	745a                	ld	s0,432(sp)
    80005228:	6139                	addi	sp,sp,448
    8000522a:	8082                	ret

000000008000522c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000522c:	7139                	addi	sp,sp,-64
    8000522e:	fc06                	sd	ra,56(sp)
    80005230:	f822                	sd	s0,48(sp)
    80005232:	f426                	sd	s1,40(sp)
    80005234:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005236:	eaafc0ef          	jal	800018e0 <myproc>
    8000523a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000523c:	fd840593          	addi	a1,s0,-40
    80005240:	4501                	li	a0,0
    80005242:	e24fd0ef          	jal	80002866 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005246:	fc840593          	addi	a1,s0,-56
    8000524a:	fd040513          	addi	a0,s0,-48
    8000524e:	85cff0ef          	jal	800042aa <pipealloc>
    return -1;
    80005252:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005254:	0a054463          	bltz	a0,800052fc <sys_pipe+0xd0>
  fd0 = -1;
    80005258:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000525c:	fd043503          	ld	a0,-48(s0)
    80005260:	f08ff0ef          	jal	80004968 <fdalloc>
    80005264:	fca42223          	sw	a0,-60(s0)
    80005268:	08054163          	bltz	a0,800052ea <sys_pipe+0xbe>
    8000526c:	fc843503          	ld	a0,-56(s0)
    80005270:	ef8ff0ef          	jal	80004968 <fdalloc>
    80005274:	fca42023          	sw	a0,-64(s0)
    80005278:	06054063          	bltz	a0,800052d8 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000527c:	4691                	li	a3,4
    8000527e:	fc440613          	addi	a2,s0,-60
    80005282:	fd843583          	ld	a1,-40(s0)
    80005286:	68a8                	ld	a0,80(s1)
    80005288:	acafc0ef          	jal	80001552 <copyout>
    8000528c:	00054e63          	bltz	a0,800052a8 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005290:	4691                	li	a3,4
    80005292:	fc040613          	addi	a2,s0,-64
    80005296:	fd843583          	ld	a1,-40(s0)
    8000529a:	0591                	addi	a1,a1,4
    8000529c:	68a8                	ld	a0,80(s1)
    8000529e:	ab4fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052a2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052a4:	04055c63          	bgez	a0,800052fc <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800052a8:	fc442783          	lw	a5,-60(s0)
    800052ac:	07e9                	addi	a5,a5,26
    800052ae:	078e                	slli	a5,a5,0x3
    800052b0:	97a6                	add	a5,a5,s1
    800052b2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052b6:	fc042783          	lw	a5,-64(s0)
    800052ba:	07e9                	addi	a5,a5,26
    800052bc:	078e                	slli	a5,a5,0x3
    800052be:	94be                	add	s1,s1,a5
    800052c0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800052c4:	fd043503          	ld	a0,-48(s0)
    800052c8:	cd9fe0ef          	jal	80003fa0 <fileclose>
    fileclose(wf);
    800052cc:	fc843503          	ld	a0,-56(s0)
    800052d0:	cd1fe0ef          	jal	80003fa0 <fileclose>
    return -1;
    800052d4:	57fd                	li	a5,-1
    800052d6:	a01d                	j	800052fc <sys_pipe+0xd0>
    if(fd0 >= 0)
    800052d8:	fc442783          	lw	a5,-60(s0)
    800052dc:	0007c763          	bltz	a5,800052ea <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800052e0:	07e9                	addi	a5,a5,26
    800052e2:	078e                	slli	a5,a5,0x3
    800052e4:	97a6                	add	a5,a5,s1
    800052e6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800052ea:	fd043503          	ld	a0,-48(s0)
    800052ee:	cb3fe0ef          	jal	80003fa0 <fileclose>
    fileclose(wf);
    800052f2:	fc843503          	ld	a0,-56(s0)
    800052f6:	cabfe0ef          	jal	80003fa0 <fileclose>
    return -1;
    800052fa:	57fd                	li	a5,-1
}
    800052fc:	853e                	mv	a0,a5
    800052fe:	70e2                	ld	ra,56(sp)
    80005300:	7442                	ld	s0,48(sp)
    80005302:	74a2                	ld	s1,40(sp)
    80005304:	6121                	addi	sp,sp,64
    80005306:	8082                	ret
	...

0000000080005310 <kernelvec>:
    80005310:	7111                	addi	sp,sp,-256
    80005312:	e006                	sd	ra,0(sp)
    80005314:	e40a                	sd	sp,8(sp)
    80005316:	e80e                	sd	gp,16(sp)
    80005318:	ec12                	sd	tp,24(sp)
    8000531a:	f016                	sd	t0,32(sp)
    8000531c:	f41a                	sd	t1,40(sp)
    8000531e:	f81e                	sd	t2,48(sp)
    80005320:	e4aa                	sd	a0,72(sp)
    80005322:	e8ae                	sd	a1,80(sp)
    80005324:	ecb2                	sd	a2,88(sp)
    80005326:	f0b6                	sd	a3,96(sp)
    80005328:	f4ba                	sd	a4,104(sp)
    8000532a:	f8be                	sd	a5,112(sp)
    8000532c:	fcc2                	sd	a6,120(sp)
    8000532e:	e146                	sd	a7,128(sp)
    80005330:	edf2                	sd	t3,216(sp)
    80005332:	f1f6                	sd	t4,224(sp)
    80005334:	f5fa                	sd	t5,232(sp)
    80005336:	f9fe                	sd	t6,240(sp)
    80005338:	b98fd0ef          	jal	800026d0 <kerneltrap>
    8000533c:	6082                	ld	ra,0(sp)
    8000533e:	6122                	ld	sp,8(sp)
    80005340:	61c2                	ld	gp,16(sp)
    80005342:	7282                	ld	t0,32(sp)
    80005344:	7322                	ld	t1,40(sp)
    80005346:	73c2                	ld	t2,48(sp)
    80005348:	6526                	ld	a0,72(sp)
    8000534a:	65c6                	ld	a1,80(sp)
    8000534c:	6666                	ld	a2,88(sp)
    8000534e:	7686                	ld	a3,96(sp)
    80005350:	7726                	ld	a4,104(sp)
    80005352:	77c6                	ld	a5,112(sp)
    80005354:	7866                	ld	a6,120(sp)
    80005356:	688a                	ld	a7,128(sp)
    80005358:	6e6e                	ld	t3,216(sp)
    8000535a:	7e8e                	ld	t4,224(sp)
    8000535c:	7f2e                	ld	t5,232(sp)
    8000535e:	7fce                	ld	t6,240(sp)
    80005360:	6111                	addi	sp,sp,256
    80005362:	10200073          	sret
	...

000000008000536e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000536e:	1141                	addi	sp,sp,-16
    80005370:	e422                	sd	s0,8(sp)
    80005372:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005374:	0c0007b7          	lui	a5,0xc000
    80005378:	4705                	li	a4,1
    8000537a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000537c:	0c0007b7          	lui	a5,0xc000
    80005380:	c3d8                	sw	a4,4(a5)
}
    80005382:	6422                	ld	s0,8(sp)
    80005384:	0141                	addi	sp,sp,16
    80005386:	8082                	ret

0000000080005388 <plicinithart>:

void
plicinithart(void)
{
    80005388:	1141                	addi	sp,sp,-16
    8000538a:	e406                	sd	ra,8(sp)
    8000538c:	e022                	sd	s0,0(sp)
    8000538e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005390:	d24fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005394:	0085171b          	slliw	a4,a0,0x8
    80005398:	0c0027b7          	lui	a5,0xc002
    8000539c:	97ba                	add	a5,a5,a4
    8000539e:	40200713          	li	a4,1026
    800053a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800053a6:	00d5151b          	slliw	a0,a0,0xd
    800053aa:	0c2017b7          	lui	a5,0xc201
    800053ae:	97aa                	add	a5,a5,a0
    800053b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800053b4:	60a2                	ld	ra,8(sp)
    800053b6:	6402                	ld	s0,0(sp)
    800053b8:	0141                	addi	sp,sp,16
    800053ba:	8082                	ret

00000000800053bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053bc:	1141                	addi	sp,sp,-16
    800053be:	e406                	sd	ra,8(sp)
    800053c0:	e022                	sd	s0,0(sp)
    800053c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053c4:	cf0fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800053c8:	00d5151b          	slliw	a0,a0,0xd
    800053cc:	0c2017b7          	lui	a5,0xc201
    800053d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800053d2:	43c8                	lw	a0,4(a5)
    800053d4:	60a2                	ld	ra,8(sp)
    800053d6:	6402                	ld	s0,0(sp)
    800053d8:	0141                	addi	sp,sp,16
    800053da:	8082                	ret

00000000800053dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800053dc:	1101                	addi	sp,sp,-32
    800053de:	ec06                	sd	ra,24(sp)
    800053e0:	e822                	sd	s0,16(sp)
    800053e2:	e426                	sd	s1,8(sp)
    800053e4:	1000                	addi	s0,sp,32
    800053e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800053e8:	cccfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800053ec:	00d5151b          	slliw	a0,a0,0xd
    800053f0:	0c2017b7          	lui	a5,0xc201
    800053f4:	97aa                	add	a5,a5,a0
    800053f6:	c3c4                	sw	s1,4(a5)
}
    800053f8:	60e2                	ld	ra,24(sp)
    800053fa:	6442                	ld	s0,16(sp)
    800053fc:	64a2                	ld	s1,8(sp)
    800053fe:	6105                	addi	sp,sp,32
    80005400:	8082                	ret

0000000080005402 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005402:	1141                	addi	sp,sp,-16
    80005404:	e406                	sd	ra,8(sp)
    80005406:	e022                	sd	s0,0(sp)
    80005408:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000540a:	479d                	li	a5,7
    8000540c:	04a7ca63          	blt	a5,a0,80005460 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005410:	0001e797          	auipc	a5,0x1e
    80005414:	69078793          	addi	a5,a5,1680 # 80023aa0 <disk>
    80005418:	97aa                	add	a5,a5,a0
    8000541a:	0187c783          	lbu	a5,24(a5)
    8000541e:	e7b9                	bnez	a5,8000546c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005420:	00451693          	slli	a3,a0,0x4
    80005424:	0001e797          	auipc	a5,0x1e
    80005428:	67c78793          	addi	a5,a5,1660 # 80023aa0 <disk>
    8000542c:	6398                	ld	a4,0(a5)
    8000542e:	9736                	add	a4,a4,a3
    80005430:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005434:	6398                	ld	a4,0(a5)
    80005436:	9736                	add	a4,a4,a3
    80005438:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000543c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005440:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005444:	97aa                	add	a5,a5,a0
    80005446:	4705                	li	a4,1
    80005448:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000544c:	0001e517          	auipc	a0,0x1e
    80005450:	66c50513          	addi	a0,a0,1644 # 80023ab8 <disk+0x18>
    80005454:	b17fc0ef          	jal	80001f6a <wakeup>
}
    80005458:	60a2                	ld	ra,8(sp)
    8000545a:	6402                	ld	s0,0(sp)
    8000545c:	0141                	addi	sp,sp,16
    8000545e:	8082                	ret
    panic("free_desc 1");
    80005460:	00002517          	auipc	a0,0x2
    80005464:	21050513          	addi	a0,a0,528 # 80007670 <etext+0x670>
    80005468:	b2cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000546c:	00002517          	auipc	a0,0x2
    80005470:	21450513          	addi	a0,a0,532 # 80007680 <etext+0x680>
    80005474:	b20fb0ef          	jal	80000794 <panic>

0000000080005478 <virtio_disk_init>:
{
    80005478:	1101                	addi	sp,sp,-32
    8000547a:	ec06                	sd	ra,24(sp)
    8000547c:	e822                	sd	s0,16(sp)
    8000547e:	e426                	sd	s1,8(sp)
    80005480:	e04a                	sd	s2,0(sp)
    80005482:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005484:	00002597          	auipc	a1,0x2
    80005488:	20c58593          	addi	a1,a1,524 # 80007690 <etext+0x690>
    8000548c:	0001e517          	auipc	a0,0x1e
    80005490:	73c50513          	addi	a0,a0,1852 # 80023bc8 <disk+0x128>
    80005494:	ee0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005498:	100017b7          	lui	a5,0x10001
    8000549c:	4398                	lw	a4,0(a5)
    8000549e:	2701                	sext.w	a4,a4
    800054a0:	747277b7          	lui	a5,0x74727
    800054a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054a8:	18f71063          	bne	a4,a5,80005628 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054ac:	100017b7          	lui	a5,0x10001
    800054b0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800054b2:	439c                	lw	a5,0(a5)
    800054b4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054b6:	4709                	li	a4,2
    800054b8:	16e79863          	bne	a5,a4,80005628 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054bc:	100017b7          	lui	a5,0x10001
    800054c0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800054c2:	439c                	lw	a5,0(a5)
    800054c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054c6:	16e79163          	bne	a5,a4,80005628 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054ca:	100017b7          	lui	a5,0x10001
    800054ce:	47d8                	lw	a4,12(a5)
    800054d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054d2:	554d47b7          	lui	a5,0x554d4
    800054d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800054da:	14f71763          	bne	a4,a5,80005628 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054de:	100017b7          	lui	a5,0x10001
    800054e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054e6:	4705                	li	a4,1
    800054e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054ea:	470d                	li	a4,3
    800054ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800054ee:	10001737          	lui	a4,0x10001
    800054f2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800054f4:	c7ffe737          	lui	a4,0xc7ffe
    800054f8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdab7f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800054fc:	8ef9                	and	a3,a3,a4
    800054fe:	10001737          	lui	a4,0x10001
    80005502:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005504:	472d                	li	a4,11
    80005506:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005508:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000550c:	439c                	lw	a5,0(a5)
    8000550e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005512:	8ba1                	andi	a5,a5,8
    80005514:	12078063          	beqz	a5,80005634 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005518:	100017b7          	lui	a5,0x10001
    8000551c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005520:	100017b7          	lui	a5,0x10001
    80005524:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005528:	439c                	lw	a5,0(a5)
    8000552a:	2781                	sext.w	a5,a5
    8000552c:	10079a63          	bnez	a5,80005640 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005530:	100017b7          	lui	a5,0x10001
    80005534:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005538:	439c                	lw	a5,0(a5)
    8000553a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000553c:	10078863          	beqz	a5,8000564c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005540:	471d                	li	a4,7
    80005542:	10f77b63          	bgeu	a4,a5,80005658 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005546:	ddefb0ef          	jal	80000b24 <kalloc>
    8000554a:	0001e497          	auipc	s1,0x1e
    8000554e:	55648493          	addi	s1,s1,1366 # 80023aa0 <disk>
    80005552:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005554:	dd0fb0ef          	jal	80000b24 <kalloc>
    80005558:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000555a:	dcafb0ef          	jal	80000b24 <kalloc>
    8000555e:	87aa                	mv	a5,a0
    80005560:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005562:	6088                	ld	a0,0(s1)
    80005564:	10050063          	beqz	a0,80005664 <virtio_disk_init+0x1ec>
    80005568:	0001e717          	auipc	a4,0x1e
    8000556c:	54073703          	ld	a4,1344(a4) # 80023aa8 <disk+0x8>
    80005570:	0e070a63          	beqz	a4,80005664 <virtio_disk_init+0x1ec>
    80005574:	0e078863          	beqz	a5,80005664 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005578:	6605                	lui	a2,0x1
    8000557a:	4581                	li	a1,0
    8000557c:	f4cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005580:	0001e497          	auipc	s1,0x1e
    80005584:	52048493          	addi	s1,s1,1312 # 80023aa0 <disk>
    80005588:	6605                	lui	a2,0x1
    8000558a:	4581                	li	a1,0
    8000558c:	6488                	ld	a0,8(s1)
    8000558e:	f3afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005592:	6605                	lui	a2,0x1
    80005594:	4581                	li	a1,0
    80005596:	6888                	ld	a0,16(s1)
    80005598:	f30fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000559c:	100017b7          	lui	a5,0x10001
    800055a0:	4721                	li	a4,8
    800055a2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055a4:	4098                	lw	a4,0(s1)
    800055a6:	100017b7          	lui	a5,0x10001
    800055aa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055ae:	40d8                	lw	a4,4(s1)
    800055b0:	100017b7          	lui	a5,0x10001
    800055b4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055b8:	649c                	ld	a5,8(s1)
    800055ba:	0007869b          	sext.w	a3,a5
    800055be:	10001737          	lui	a4,0x10001
    800055c2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055c6:	9781                	srai	a5,a5,0x20
    800055c8:	10001737          	lui	a4,0x10001
    800055cc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055d0:	689c                	ld	a5,16(s1)
    800055d2:	0007869b          	sext.w	a3,a5
    800055d6:	10001737          	lui	a4,0x10001
    800055da:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055de:	9781                	srai	a5,a5,0x20
    800055e0:	10001737          	lui	a4,0x10001
    800055e4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055e8:	10001737          	lui	a4,0x10001
    800055ec:	4785                	li	a5,1
    800055ee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800055f0:	00f48c23          	sb	a5,24(s1)
    800055f4:	00f48ca3          	sb	a5,25(s1)
    800055f8:	00f48d23          	sb	a5,26(s1)
    800055fc:	00f48da3          	sb	a5,27(s1)
    80005600:	00f48e23          	sb	a5,28(s1)
    80005604:	00f48ea3          	sb	a5,29(s1)
    80005608:	00f48f23          	sb	a5,30(s1)
    8000560c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005610:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005614:	100017b7          	lui	a5,0x10001
    80005618:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000561c:	60e2                	ld	ra,24(sp)
    8000561e:	6442                	ld	s0,16(sp)
    80005620:	64a2                	ld	s1,8(sp)
    80005622:	6902                	ld	s2,0(sp)
    80005624:	6105                	addi	sp,sp,32
    80005626:	8082                	ret
    panic("could not find virtio disk");
    80005628:	00002517          	auipc	a0,0x2
    8000562c:	07850513          	addi	a0,a0,120 # 800076a0 <etext+0x6a0>
    80005630:	964fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005634:	00002517          	auipc	a0,0x2
    80005638:	08c50513          	addi	a0,a0,140 # 800076c0 <etext+0x6c0>
    8000563c:	958fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005640:	00002517          	auipc	a0,0x2
    80005644:	0a050513          	addi	a0,a0,160 # 800076e0 <etext+0x6e0>
    80005648:	94cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000564c:	00002517          	auipc	a0,0x2
    80005650:	0b450513          	addi	a0,a0,180 # 80007700 <etext+0x700>
    80005654:	940fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005658:	00002517          	auipc	a0,0x2
    8000565c:	0c850513          	addi	a0,a0,200 # 80007720 <etext+0x720>
    80005660:	934fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005664:	00002517          	auipc	a0,0x2
    80005668:	0dc50513          	addi	a0,a0,220 # 80007740 <etext+0x740>
    8000566c:	928fb0ef          	jal	80000794 <panic>

0000000080005670 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005670:	7159                	addi	sp,sp,-112
    80005672:	f486                	sd	ra,104(sp)
    80005674:	f0a2                	sd	s0,96(sp)
    80005676:	eca6                	sd	s1,88(sp)
    80005678:	e8ca                	sd	s2,80(sp)
    8000567a:	e4ce                	sd	s3,72(sp)
    8000567c:	e0d2                	sd	s4,64(sp)
    8000567e:	fc56                	sd	s5,56(sp)
    80005680:	f85a                	sd	s6,48(sp)
    80005682:	f45e                	sd	s7,40(sp)
    80005684:	f062                	sd	s8,32(sp)
    80005686:	ec66                	sd	s9,24(sp)
    80005688:	1880                	addi	s0,sp,112
    8000568a:	8a2a                	mv	s4,a0
    8000568c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000568e:	00c52c83          	lw	s9,12(a0)
    80005692:	001c9c9b          	slliw	s9,s9,0x1
    80005696:	1c82                	slli	s9,s9,0x20
    80005698:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000569c:	0001e517          	auipc	a0,0x1e
    800056a0:	52c50513          	addi	a0,a0,1324 # 80023bc8 <disk+0x128>
    800056a4:	d50fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    800056a8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800056aa:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056ac:	0001eb17          	auipc	s6,0x1e
    800056b0:	3f4b0b13          	addi	s6,s6,1012 # 80023aa0 <disk>
  for(int i = 0; i < 3; i++){
    800056b4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056b6:	0001ec17          	auipc	s8,0x1e
    800056ba:	512c0c13          	addi	s8,s8,1298 # 80023bc8 <disk+0x128>
    800056be:	a8b9                	j	8000571c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800056c0:	00fb0733          	add	a4,s6,a5
    800056c4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800056c8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056ca:	0207c563          	bltz	a5,800056f4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800056ce:	2905                	addiw	s2,s2,1
    800056d0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056d2:	05590963          	beq	s2,s5,80005724 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800056d6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056d8:	0001e717          	auipc	a4,0x1e
    800056dc:	3c870713          	addi	a4,a4,968 # 80023aa0 <disk>
    800056e0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800056e2:	01874683          	lbu	a3,24(a4)
    800056e6:	fee9                	bnez	a3,800056c0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800056e8:	2785                	addiw	a5,a5,1
    800056ea:	0705                	addi	a4,a4,1
    800056ec:	fe979be3          	bne	a5,s1,800056e2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800056f0:	57fd                	li	a5,-1
    800056f2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800056f4:	01205d63          	blez	s2,8000570e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800056f8:	f9042503          	lw	a0,-112(s0)
    800056fc:	d07ff0ef          	jal	80005402 <free_desc>
      for(int j = 0; j < i; j++)
    80005700:	4785                	li	a5,1
    80005702:	0127d663          	bge	a5,s2,8000570e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005706:	f9442503          	lw	a0,-108(s0)
    8000570a:	cf9ff0ef          	jal	80005402 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000570e:	85e2                	mv	a1,s8
    80005710:	0001e517          	auipc	a0,0x1e
    80005714:	3a850513          	addi	a0,a0,936 # 80023ab8 <disk+0x18>
    80005718:	807fc0ef          	jal	80001f1e <sleep>
  for(int i = 0; i < 3; i++){
    8000571c:	f9040613          	addi	a2,s0,-112
    80005720:	894e                	mv	s2,s3
    80005722:	bf55                	j	800056d6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005724:	f9042503          	lw	a0,-112(s0)
    80005728:	00451693          	slli	a3,a0,0x4

  if(write)
    8000572c:	0001e797          	auipc	a5,0x1e
    80005730:	37478793          	addi	a5,a5,884 # 80023aa0 <disk>
    80005734:	00a50713          	addi	a4,a0,10
    80005738:	0712                	slli	a4,a4,0x4
    8000573a:	973e                	add	a4,a4,a5
    8000573c:	01703633          	snez	a2,s7
    80005740:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005742:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005746:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000574a:	6398                	ld	a4,0(a5)
    8000574c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000574e:	0a868613          	addi	a2,a3,168
    80005752:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005754:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005756:	6390                	ld	a2,0(a5)
    80005758:	00d605b3          	add	a1,a2,a3
    8000575c:	4741                	li	a4,16
    8000575e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005760:	4805                	li	a6,1
    80005762:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005766:	f9442703          	lw	a4,-108(s0)
    8000576a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000576e:	0712                	slli	a4,a4,0x4
    80005770:	963a                	add	a2,a2,a4
    80005772:	058a0593          	addi	a1,s4,88
    80005776:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005778:	0007b883          	ld	a7,0(a5)
    8000577c:	9746                	add	a4,a4,a7
    8000577e:	40000613          	li	a2,1024
    80005782:	c710                	sw	a2,8(a4)
  if(write)
    80005784:	001bb613          	seqz	a2,s7
    80005788:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000578c:	00166613          	ori	a2,a2,1
    80005790:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005794:	f9842583          	lw	a1,-104(s0)
    80005798:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000579c:	00250613          	addi	a2,a0,2
    800057a0:	0612                	slli	a2,a2,0x4
    800057a2:	963e                	add	a2,a2,a5
    800057a4:	577d                	li	a4,-1
    800057a6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057aa:	0592                	slli	a1,a1,0x4
    800057ac:	98ae                	add	a7,a7,a1
    800057ae:	03068713          	addi	a4,a3,48
    800057b2:	973e                	add	a4,a4,a5
    800057b4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057b8:	6398                	ld	a4,0(a5)
    800057ba:	972e                	add	a4,a4,a1
    800057bc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057c0:	4689                	li	a3,2
    800057c2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057c6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057ca:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800057ce:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057d2:	6794                	ld	a3,8(a5)
    800057d4:	0026d703          	lhu	a4,2(a3)
    800057d8:	8b1d                	andi	a4,a4,7
    800057da:	0706                	slli	a4,a4,0x1
    800057dc:	96ba                	add	a3,a3,a4
    800057de:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800057e2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057e6:	6798                	ld	a4,8(a5)
    800057e8:	00275783          	lhu	a5,2(a4)
    800057ec:	2785                	addiw	a5,a5,1
    800057ee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057f2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800057f6:	100017b7          	lui	a5,0x10001
    800057fa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800057fe:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005802:	0001e917          	auipc	s2,0x1e
    80005806:	3c690913          	addi	s2,s2,966 # 80023bc8 <disk+0x128>
  while(b->disk == 1) {
    8000580a:	4485                	li	s1,1
    8000580c:	01079a63          	bne	a5,a6,80005820 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005810:	85ca                	mv	a1,s2
    80005812:	8552                	mv	a0,s4
    80005814:	f0afc0ef          	jal	80001f1e <sleep>
  while(b->disk == 1) {
    80005818:	004a2783          	lw	a5,4(s4)
    8000581c:	fe978ae3          	beq	a5,s1,80005810 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005820:	f9042903          	lw	s2,-112(s0)
    80005824:	00290713          	addi	a4,s2,2
    80005828:	0712                	slli	a4,a4,0x4
    8000582a:	0001e797          	auipc	a5,0x1e
    8000582e:	27678793          	addi	a5,a5,630 # 80023aa0 <disk>
    80005832:	97ba                	add	a5,a5,a4
    80005834:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005838:	0001e997          	auipc	s3,0x1e
    8000583c:	26898993          	addi	s3,s3,616 # 80023aa0 <disk>
    80005840:	00491713          	slli	a4,s2,0x4
    80005844:	0009b783          	ld	a5,0(s3)
    80005848:	97ba                	add	a5,a5,a4
    8000584a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000584e:	854a                	mv	a0,s2
    80005850:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005854:	bafff0ef          	jal	80005402 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005858:	8885                	andi	s1,s1,1
    8000585a:	f0fd                	bnez	s1,80005840 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000585c:	0001e517          	auipc	a0,0x1e
    80005860:	36c50513          	addi	a0,a0,876 # 80023bc8 <disk+0x128>
    80005864:	c28fb0ef          	jal	80000c8c <release>
}
    80005868:	70a6                	ld	ra,104(sp)
    8000586a:	7406                	ld	s0,96(sp)
    8000586c:	64e6                	ld	s1,88(sp)
    8000586e:	6946                	ld	s2,80(sp)
    80005870:	69a6                	ld	s3,72(sp)
    80005872:	6a06                	ld	s4,64(sp)
    80005874:	7ae2                	ld	s5,56(sp)
    80005876:	7b42                	ld	s6,48(sp)
    80005878:	7ba2                	ld	s7,40(sp)
    8000587a:	7c02                	ld	s8,32(sp)
    8000587c:	6ce2                	ld	s9,24(sp)
    8000587e:	6165                	addi	sp,sp,112
    80005880:	8082                	ret

0000000080005882 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005882:	1101                	addi	sp,sp,-32
    80005884:	ec06                	sd	ra,24(sp)
    80005886:	e822                	sd	s0,16(sp)
    80005888:	e426                	sd	s1,8(sp)
    8000588a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000588c:	0001e497          	auipc	s1,0x1e
    80005890:	21448493          	addi	s1,s1,532 # 80023aa0 <disk>
    80005894:	0001e517          	auipc	a0,0x1e
    80005898:	33450513          	addi	a0,a0,820 # 80023bc8 <disk+0x128>
    8000589c:	b58fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058a0:	100017b7          	lui	a5,0x10001
    800058a4:	53b8                	lw	a4,96(a5)
    800058a6:	8b0d                	andi	a4,a4,3
    800058a8:	100017b7          	lui	a5,0x10001
    800058ac:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800058ae:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058b2:	689c                	ld	a5,16(s1)
    800058b4:	0204d703          	lhu	a4,32(s1)
    800058b8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058bc:	04f70663          	beq	a4,a5,80005908 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058c0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058c4:	6898                	ld	a4,16(s1)
    800058c6:	0204d783          	lhu	a5,32(s1)
    800058ca:	8b9d                	andi	a5,a5,7
    800058cc:	078e                	slli	a5,a5,0x3
    800058ce:	97ba                	add	a5,a5,a4
    800058d0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058d2:	00278713          	addi	a4,a5,2
    800058d6:	0712                	slli	a4,a4,0x4
    800058d8:	9726                	add	a4,a4,s1
    800058da:	01074703          	lbu	a4,16(a4)
    800058de:	e321                	bnez	a4,8000591e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058e0:	0789                	addi	a5,a5,2
    800058e2:	0792                	slli	a5,a5,0x4
    800058e4:	97a6                	add	a5,a5,s1
    800058e6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800058e8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058ec:	e7efc0ef          	jal	80001f6a <wakeup>

    disk.used_idx += 1;
    800058f0:	0204d783          	lhu	a5,32(s1)
    800058f4:	2785                	addiw	a5,a5,1
    800058f6:	17c2                	slli	a5,a5,0x30
    800058f8:	93c1                	srli	a5,a5,0x30
    800058fa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800058fe:	6898                	ld	a4,16(s1)
    80005900:	00275703          	lhu	a4,2(a4)
    80005904:	faf71ee3          	bne	a4,a5,800058c0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005908:	0001e517          	auipc	a0,0x1e
    8000590c:	2c050513          	addi	a0,a0,704 # 80023bc8 <disk+0x128>
    80005910:	b7cfb0ef          	jal	80000c8c <release>
}
    80005914:	60e2                	ld	ra,24(sp)
    80005916:	6442                	ld	s0,16(sp)
    80005918:	64a2                	ld	s1,8(sp)
    8000591a:	6105                	addi	sp,sp,32
    8000591c:	8082                	ret
      panic("virtio_disk_intr status");
    8000591e:	00002517          	auipc	a0,0x2
    80005922:	e3a50513          	addi	a0,a0,-454 # 80007758 <etext+0x758>
    80005926:	e6ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
