#include <IOKit/IOKitLib.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
static io_connect_t c;
static kern_return_t call(uint32_t sel, uint64_t *so, uint32_t *soc, void *out, size_t *osz){
  return IOConnectCallMethod(c, sel, NULL, 0, NULL, 0, so, soc, out, osz);
}
int main(int argc,char**argv){
  io_service_t s=IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AMDRyzenCPUPowerManagement"));
  if(!s){puts("no service");return 1;}
  kern_return_t kr=IOServiceOpen(s,mach_task_self(),0,&c); if(kr){printf("open %x\n",kr);return 1;}
  float pc[8]; size_t sz=sizeof pc; uint32_t n=0;
  if(!call(1,NULL,&n,pc,&sz)){printf("PStateDef clocks MHz:");for(int i=0;i<8;i++)printf(" %.0f",pc[i]);puts("");}
  uint64_t v[2]; sz=sizeof v; if(!call(11,NULL,&n,v,&sz))printf("CPB supported=%llu enabled=%llu\n",v[0],v[1]);
  sz=8; if(!call(13,NULL,&n,v,&sz))printf("PPM=%llu ",v[0]); sz=8; if(!call(18,NULL,&n,v,&sz))printf("LPM=%llu\n",v[0]);
  int iters=argc>1?atoi(argv[1]):1; double dt=argc>2?atof(argv[2]):1;
  for(int k=0;k<iters;k++){
    float d[32]; uint64_t so[1]; uint32_t soc=1; sz=sizeof d;
    kr=call(4,so,&soc,d,&sz); if(kr){printf("call4 %x\n",kr);return 1;}
    float mx=0,sum=0; for(uint64_t i=0;i<so[0];i++){sum+=d[3+i]; if(d[3+i]>mx)mx=d[3+i];}
    printf("pwr %.1f W  temp %.1f C  pstate %.0f  avg %.0f max %.0f MHz |",d[0],d[1],d[2],sum/so[0],mx);
    for(uint64_t i=0;i<so[0];i++)printf(" %.0f",d[3+i]); puts(""); fflush(stdout);
    if(k+1<iters) usleep((useconds_t)(dt*1e6));
  }
  return 0;
}
