import hashlib,time,multiprocessing as mp,subprocess,sys
BUF=b'x'*(1<<20)
def work(sec):
    n=0;c0=time.process_time();end=time.perf_counter()+sec
    while time.perf_counter()<end:
        hashlib.sha256(BUF).digest(); n+=1
    return n/sec,(time.process_time()-c0)/sec
if __name__=='__main__':
    rd=sys.argv[1]
    for k in (1,2,4,8,16):
        with mp.Pool(k) as p:
            r=p.map_async(work,[6]*k); time.sleep(3)
            s=subprocess.run([rd,"3","0.8"],capture_output=True,text=True).stdout.splitlines()[3:]
            r=r.get()
        print(k,"procs total %.0f per-proc %.0f util %.2f"%(sum(x for x,_ in r),sum(x for x,_ in r)/k,sum(u for _,u in r)/k))
        for l in s: print("   ",l)
