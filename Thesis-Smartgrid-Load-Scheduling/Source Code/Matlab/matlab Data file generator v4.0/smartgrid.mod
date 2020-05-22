set A;								#Appliance Set
set N;								#User Set
set Hday;							#Set of day hour
set Hnight;							#Set of Night Hour
param T{n in N,a in A} integer;		#operating time of the appliance
set H;								#Set of whole day
param B;							#electricity production cost during day time(USD/Unit)
param C;							#electricity production cost during night time(USD/Unit)		
param Ina{n in N,a in A}>=0;		#Average Current through each appliance
param V{n in N}>0;					#voltage across each user
param Angle{n in N,a in A};			#Power factor angle of each appliance
param pf_cos{n in N,a in A};		#Cosine ration of pf angle
param pf_sin{n in N,a in A};		#Sine ration of pf angle 
param R{n in N}>0;					#wire resistance of each user 
var x{n in N,a in A,h in H}binary;	#binary variable to decide a whether an appliance is operating or not
var e{h in H} >=0;					#an appliance power consumption
var E{h in H} >=0;					#total Electricity consumption during a particular hour
var I_squared{n in N, h in H}>=0;	#Total current of user at time h
var L{h in H}>=0;					#total copper loss

minimize cost: sum{h1 in Hday} B*E[h1] +sum{h2 in Hnight} C*E[h2];
subject to continuity{n in N,a in A}:
	sum{h in H} x[n,a,h]>=T[n,a];
subject to current {h in H, n in N}:
		I_squared[n,h]= (sum{a in A} Ina[n,a]*pf_cos[n,a]*x[n,a,h])^2+(sum{a in A} Ina[n,a]*pf_sin[n,a]*x[n,a,h])^2;
subject to consumption {h in H}:
		e[h] = sum{n in N} (sum{a in A} V[n]* Ina[n,a] *pf_cos[n,a]* x[n,a,h]);
subject to copper_loss {h in H}:
		L[h] = sum{n in N} I_squared[n,h]*R[n];
subject to total_consumption {h in H}:		  						 
		E[h] = (e[h] + L[h]);

