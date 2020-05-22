function count=AMPLset(fid,pname,p)

%
%   function count=AMPLvector(fid,pname,p)
%
% Write vector of floats to AMPL data file
%
%   fid   : file handle of the data file from 'fopen' 
%   pname : name to be given to the parameter in the file (string)
%   p     : the value of the parameter (vector)
%
%   count : number of bytes written
%
% Copyright A. Richards, MIT, 2002
%
%fid=fopen('set.dat','w');
%p=[2 3 6 9 2 4];

s=size(p);

c=0;



if min(size(p))==1,

   % vector

   l=max(s);

   c = c + fprintf(fid,['set ' pname ' := ']);

   for i=[1:l-1],

      c = c + fprintf(fid,'%4.0f %20.15f,',p(i));

   end

   c = c + fprintf(fid,'%4.0f;\n',p(l));

else

   error('Not vector')

end



count=c;