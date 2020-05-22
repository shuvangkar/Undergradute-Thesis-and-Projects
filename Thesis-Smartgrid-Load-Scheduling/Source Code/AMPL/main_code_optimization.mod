set N;								#User Set
set A;								#Appliance Set
set Hday;							#Set of day hour
set Hnight;							#Set of Night Hour
set H;								#Set of whole day
param B;							#electricity prodection cost during day time(USD/Unit)
param C;							#electricity prodection cost during night time(USD/Unit)
param rho;							#resistivity of copper
param pi;							
param Ina{n in N,a in A};			#Average Current through each appliance
param V{n in N};					#voltage across each user
param Angle{n in N,a in A};			#Power factor angle of each appliance
param T{n in N,a in A};				#operating time of the appliance
param l{n in N};					#wire length of each user
param r{n in N};					#wire radius of each user

var x{n in N,a in A,h in H} binary;	#binary variable to decide a whether an appliance is operating or not
var e{h in H} >=0;					#an appliance power consumption
var E{h in H} >=0;					#total Electricity consumption during a particular hour
var I{n in N, h in H}>=0;			#Total current of user at time h
var L{h in H};						#core loss
var t{n in N, a in A, h in H}>=0; 	#starting time of a particular appliance

minimize cost: sum{h1 in Hday} B*E[h1]^2 +sum{h2 in Hnight} C*E[h2]^2;

subject to current {h in H, n in N}:
		I[h,n]= sqrt((sum{a in A}I[n,a]*cos(Angle[n,a]*x[n,a,h]))^2+(sum{a in A}I[n,a]*sin(Angle[n,a]*x[n,a,h]))^2);
subject to consumption {h in H}:
		e[h] = sum{n in N} (sum{a in A} V[n]* Ina[n,a] *cos(Angle[n,a])* x[n,a,h]);
subject to copper_loss {h in H}:
		L[h] = sum{n in N} (I[n,h]^2*rho*l[n])/(pi*r[n]^2);
subject to total_consumption {h in H}:		  						 
		E[h] = e[h] + L[h];
		   


