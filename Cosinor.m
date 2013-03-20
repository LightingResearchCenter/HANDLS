function [phi,max] = Cosinor(Time,Value,Freq)
%COSINOR Fits a cosine waveform of frequency Freq to the (Time,Value) data
%	Returns the maximum (max) and phase (phi)
%	Freq is in days

omega = 2*pi*Freq;
xj = cos(omega*Time);
zj = sin(omega*Time);
n = length(Time);
A = [n sum(xj) sum(zj);...
    sum(xj) sum(xj.^2) sum(xj.*zj);...
    sum(zj) sum(xj.*zj) sum(zj.^2)];
B = [sum(Value);...
     sum(xj.*Value);...
     sum(zj.*Value)];
 
 x = A\B;
 mesor = x(1);
 amp = sqrt(x(2)^2 + x(3)^2);
 max = amp + mesor;
 phi = -atan2(x(3),x(2));
 phi = mod(phi,2*pi);
 

end