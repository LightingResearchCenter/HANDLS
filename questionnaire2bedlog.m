function [bedTimeArray,riseTimeArray] = questionnaire2bedlog(Q,HNDid,datenumArray)
%QUESTIONNAIRE2BEDLOG Summary of this function goes here
%   Detailed explanation goes here

idx = Q.HNDid == HNDid;
thisQ = Q(idx,:);

daysDatenum  = unique(floor(datenumArray));
daysDatevec  = datevec(daysDatenum(:));
daysDatetime = datetime(daysDatevec);

timeFormat = 'HH:MM:SS';
workBed  = NaN;
workRise = NaN;
freeBed  = NaN;
freeRise = NaN;
if ~strcmpi(thisQ.LMworkBed,'NA')
    workBed = datevec(thisQ.LMworkBed,timeFormat);
end
if ~strcmpi(thisQ.LMworkAwake,'NA')
    workRise = datevec(thisQ.LMworkAwake,timeFormat);
end
if ~strcmpi(thisQ.LMfreeBed,'NA')
    freeBed = datevec(thisQ.LMfreeBed,timeFormat);
end
if ~strcmpi(thisQ.LMfreeAwake,'NA')
    freeRise = datevec(thisQ.LMfreeAwake,timeFormat);
end

if (isnan(workBed(1)) && isnan(freeBed(1))) || (isnan(workRise(1)) && isnan(freeRise(1)))
    error('Insufficient questionnaire information to generate bed log.')
else
    if isnan(workBed(1))
        workBed = freeBed;
    elseif isnan(freeBed(1))
        freeBed = workBed;
    end
    if isnan(workRise(1))
        workRise = freeRise;
    elseif isnan(freeRise(1))
        freeRise = workRise;
    end
end

workBed(1:3)  = 0;
workRise(1:3) = 0;
freeBed(1:3)  = 0;
freeRise(1:3) = 0;

if workBed(4) >= workRise(4)
    workBed(3) = -1;
end
if freeBed(4) >= freeRise(4)
    freeBed(3) = -1;
end

freeIdx = isweekend(daysDatetime);
bedTimeArray  = zeros(size(daysDatetime));
riseTimeArray = zeros(size(daysDatetime));

for iDay = 1:numel(daysDatetime)
    thiDatevec = daysDatevec(iDay,:);
    if freeIdx(iDay)
        thisBed = freeBed;
        thisRise = freeRise;
    else
        thisBed = workBed;
        thisRise = workRise;
    end
    bedTimeArray(iDay) = datenum(thiDatevec + thisBed);
    riseTimeArray(iDay) = datenum(thiDatevec + thisRise);
end

end

