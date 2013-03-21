function [magnitude, angle] = phasor24(x, y, time)
%PHASOR24 returns the 24 hour phasor using x and y
%x is one data set
%y is the other data set
%time is the common timestamps (in days) for the signals
%magnitude is the phasor magnitude
%angle is the phasor angle in hours

%fits the signals using a 24 hour cosine curve
[Mx,Ax,phix] = cosinorFit(time',x',1, 1);
[My,Ay,phiy] = cosinorFit(time',y',1, 1);

%angle is just the difference in phases
angle = (phix - phiy)/(2*pi);

%pshift is the number of points to shift so that the signals line up
pshift = angle/(time(2) - time(1));

%shift one signal so that they overlap
y = circshift(y, round(pshift));

fitx = Mx + Ax*cos(2*pi*time + phix);
fity = My + Ay*cos(2*pi*time + phiy);

%magnitude is just the normalized cross covariance (from wikipedia)
magnitude = (std(fitx)*std(fity))/(std(x)*std(y));

angle = angle*24;

if(angle > 12)
    angle = angle - 24;
end
if(angle < -12)
    angle = 24 + angle;
end