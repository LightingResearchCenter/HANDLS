function [timeArray,dataArray] = removedata(timeArray,dataArray,removeStart,removeStop)
%REMOVEDATA Summary of this function goes here
%   Detailed explanation goes here

idx = timeArray >= removeStart & timeArray <= removeStop;

timeArray(idx) = [];
dataArray(idx) = [];

end

