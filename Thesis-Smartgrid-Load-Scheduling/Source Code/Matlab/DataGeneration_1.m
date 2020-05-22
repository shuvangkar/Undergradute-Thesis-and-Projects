close all;

tic;
Ns=100;

N=30;
N1=13; 
N2=170;
%N11=20;
%N12=30;


BW=10;

capacity=BW*log2(1+1e-3*(rand(N,1)/.001).^-4./1e-13);

capacity_jt=BW*log2(1+1e-3*(rand(N,1)/.001).^-4/1e-13);

F1=4;
F2=6;
F12=8;
Fjt=3;

fid=fopen('compv2.dat','w');

%%%set Node
fprintf(fid,'set Node :=\t');
for j=1:N
    fprintf(fid,'%d\t',j);    
     j=j+1;
end

fprintf(fid,';\n');

fprintf(fid,'set Node1 :=\t');
for j=1:N1
    fprintf(fid,'%d\t',j);    
     j=j+1;
end

fprintf(fid,';\n');

fprintf(fid,'set Node2 :=\t');
for j=N1+1:N
    fprintf(fid,'%d\t',j);    
     j=j+1;
end


fprintf(fid,';\n');


fprintf(fid,'set Slots :=\t');
for j=1:Ns
     fprintf(fid,'%d\t',j);    
     j=j+1;
end

fprintf(fid,';\n');


fprintf(fid,'param Ns :=\t');
 
          fprintf(fid,'\n%d\t',Ns);
  fprintf(fid,';\n');
    

fprintf(fid,'param F1 :=\t');
 
          fprintf(fid,'\n%d\t',F1);
  fprintf(fid,';\n');
    
  fprintf(fid,'param F2 :=\t');
 
          fprintf(fid,'\n%d\t',F2);
  fprintf(fid,';\n');
    
  
fprintf(fid,'param F12 :=\t');
 
          fprintf(fid,'\n%d\t',F12);
  fprintf(fid,';\n');

  
fprintf(fid,'param Fjt :=\t');
 
          fprintf(fid,'\n%d\t',Fjt);
  fprintf(fid,';\n');

fprintf(fid,'param C :=\t');
  for i=1:N      
          fprintf(fid,'\n%d\t%.3f\t',i,capacity(i));
      end
  fprintf(fid,';\n');
    
  
fprintf(fid,'param Cjt :=\t');
  for i=1:N
       fprintf(fid,'\n%d\t%.3f\t',i,capacity_jt(i));
      end
  fprintf(fid,';\n');
    
fprintf(fid,'\n');
fclose(fid);
toc;