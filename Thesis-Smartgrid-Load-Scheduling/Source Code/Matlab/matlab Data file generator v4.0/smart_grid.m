%Smartgrid Thesis data file by Shuvangkar
clc;
close all;
clear all;
n=50; %no. of family
a=6; %no of appliance at each family
h=24;
%Opening a file  in write mode
fid = fopen('smartgrid.dat','w');
%declaring set
N=1:n;
AMPLset(fid,'N',N);
A=1:a;
AMPLset(fid,'A',A);
day=[6 7 8 9 10 11 12 13 14 15 16 17 18];
AMPLset(fid,'Hday',day);
night=[19 20 21 22 23 24 1 2 3 4 5];
AMPLset(fid,'Hnight',night);
H=1:h;
AMPLset(fid,'H',H);
%Scalar parameters
b= 0.1875;
c= b/2;

AMPLscalar(fid,'B',b);
AMPLscalar(fid,'C',c);
%AMPLscalar(fid,'rho',rho);
%AMPLscalar(fid,'pi',pi);
% All the Matrix parameters will be declared below
%--------------------------------------------------
 %Appliance current
 I = rand(n,a);   
 AMPLmatrix(fid,'Ina',I);
 %User Voltage
 vlow = 200;
 vhigh = 220;
 V = ((vhigh-vlow).*rand(n,1) + vlow);
 AMPLmatrix_nx1(fid,'V',V);
 %Appliance Power factor angle
 Theta = deg2rad(20*rand(n,a));
 pf_cos=cos(Theta);
 AMPLmatrix(fid,'pf_cos',pf_cos);
 pf_sin=sin(Theta);
 AMPLmatrix(fid,'pf_sin',pf_sin);
 %Operating time of each appliance
 T = int8(3*rand(n,a));
 AMPLmatrix(fid,'T',T);
 %User wire length(in meter)
 Llow = 100;
 Lhigh = 2000;
 wire_length = ((Lhigh-Llow).*rand(n,1) + Llow);
 %AMPLmatrix_nx1(fid,'l',wire_length);
 %Wire radius (in meter)
 rho = 1.68e-8;
 pi = 3.1416;
 wire_radius = 10e-3*rand(n,1);
 %AMPLmatrix_nx1(fid,'r',wire_radius);
 R = (rho/pi)*wire_length./(wire_radius.^2);

 AMPLmatrix_nx1(fid,'R',R);
 fclose(fid); %Closing the file after writing 
 
%Calculation of the total cost in normal condition
%randomly generate binary decision variable whether appliance will be
%turned on or off
x=zeros(n,a,h);
for n=1:n
    for a=1:a
        index=randperm(h);
        x(n,a,index(1:T(n,a))) = 1;
    end
end
%Current real component of each appliance
I_3d_real=zeros(n,a,h);
I_real= I.*pf_cos;

for h=1:h
    I_3d_real(:,:,h)=x(:,:,h).*I_real;
end
%Current Imagainary component of each appliance
I_3d_img=zeros(n,a,h);
I_img= I.*pf_sin;
for h=1:h
    I_3d_img(:,:,h)=x(:,:,h).*I_img;
end
%Squared of current of each user for each hour 
Inh_squared=(sum(I_3d_real,2)).^2+(sum(I_3d_img,2)).^2;
%Line loss calculation for each hour
Lnh=zeros(n,h);
for h=1:h
    Lnh(:,h) = Inh_squared(:,h).*R;
end
Lh=sum(Lnh,1);
%Energy consumption calculation for each appliance
Ena=zeros(n,a);
for a=1:a
    Ena(:,a)  = I_real(:,a).*V;
end

Enah=zeros(n,a,h);
I_img= I.*pf_sin;
for h=1:h
    Enah(:,:,h)=x(:,:,h).*Ena;
end
Enh=sum(Enah,2);
Eh=sum(Enh,1);
Lh=Lh';
for h=1:h
   Eh(:,:,h) =  Eh(:,:,h) + Lh(h);
end
%Transformer loss calculation

%%%%%%%%%%%%%%%%%%%
%cost calculation
cost=0;
for h=1:h
    if (h>=5)&(h<18)
        Eh(:,:,h) = b*Eh(:,:,h);
    else
        Eh(:,:,h) = c*Eh(:,:,h);
    end
end
cost = sum(Eh,3)



 