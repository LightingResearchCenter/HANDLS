function [LuxFix,CLAFix,CSFix,AFix] = correctbyteshift(timeArray,illuminanceArray,claArray,csArray,activityArray)

% Replace zero reset values
Anext = [activityArray(2:end);activityArray(end)];
activityArray(activityArray==0) = Anext(activityArray==0);

% figure(1)
% set(gcf,'Position',[ 15,501,1236,420]);
% semilogy(timeArray,illuminanceArray,'r-')
% hold on
% semilogy(timeArray,activityArray,'g-')
% hold off
% datetick2('x')

diffLux = diff(log2(illuminanceArray));
diffLux2 = diffLux(2:end);
diffLux = diffLux(1:end-1);

qup = find(diffLux >= 6 | (diffLux > 2 & diffLux2 > 2));
qup(illuminanceArray(qup)==0) = []; % remove zero values introduced by resets
qdn = find(diffLux < -6);

% figure(1)
% hold on
% h1 = semilogy(timeArray(qup),1,'gd');
% set(h1,'MarkerFaceColor','g')
% h2 = semilogy(timeArray(qdn),1,'kd');
% set(h2,'MarkerFaceColor','k');

LuxFix = illuminanceArray;
AFix = activityArray;
CSFix = csArray;
CLAFix = claArray;
for i1 = 1:length(qup)
    index1 = qup(i1);
    index2 = qdn(find(qdn>index1,1,'first'));
    if isempty(index2)
        break;
    end
    index1b = index1-5;
    index2b = index2+5;
    segmentLux = illuminanceArray(index1b:index2b);
    segmentA = activityArray(index1b:index2b);
    if ((timeArray(index2)-timeArray(index1)) > 5/24)
        continue;
    end
    segmentAa = activityArray(index1:index2);
    Correlation = corr([segmentLux,segmentA]);
    Correlation = Correlation(2,1); % element [2,1] of correlation matrix returned above
    STD = std(segmentAa)/mean(segmentAa);

    if (Correlation > 0.70 || mean(segmentAa) < 0.02 || min(segmentAa) ==0 || STD < 0.01)
      if (index1>10 && index2<(length(illuminanceArray)-10))
        LuxFix(index1:index2) = mean([illuminanceArray(index1-11:index1-2);illuminanceArray(index2+2:index2+11)]);
        CLAFix(index1:index2) = mean([claArray(index1-11:index1-2);claArray(index2+2:index2+11)]);
        CSFix(index1:index2) = mean([csArray(index1-11:index1-2);csArray(index2+2:index2+11)]);
        AFix(index1:index2) = mean([activityArray(index1-21:index1-2);activityArray(index2+2:index2+21)]);
      end
    end
end

% figure(1)
% hold on
% semilogy(timeArray,LuxFix,'b-')
% semilogy(timeArray,AFix,'k-')
% hold off

end