function test_detect_apnea()
fs=10;x=ones(1000,1);x(101:220)=0.01;x(501:650)=0.02;
r=detect_apnea(x,fs,shortestDurationSec=10,longestDurationSec=20,expectedEvents=NaN);
assert(r.nEvents==2);assert(r.start(1)==101);assert(r.end(2)==650);assert(sum(r.mask)==270);
end
