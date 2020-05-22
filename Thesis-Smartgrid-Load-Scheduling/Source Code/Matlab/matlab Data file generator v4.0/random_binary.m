clc;
close all;
clear all;
x=zeros(2,3,4);
T = int8(3*rand(2,3))
for n=1:2
    for a=1:3
         index=randperm(4);
        
        x(n,a,index(1:T(n,a))) = 1;
    end
end
x
