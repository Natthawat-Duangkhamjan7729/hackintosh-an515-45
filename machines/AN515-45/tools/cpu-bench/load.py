import hashlib,time,multiprocessing as mp,sys
B=b'x'*(1<<20)
def w(s):
    n=0;e=time.perf_counter()+s
    while time.perf_counter()<e: hashlib.sha256(B).digest(); n+=1
    return n
if __name__=='__main__':
    k=int(sys.argv[1]); s=float(sys.argv[2])
    with mp.Pool(k) as p: print("total MiB/s %.0f"%(sum(p.map(w,[s]*k))/s))
