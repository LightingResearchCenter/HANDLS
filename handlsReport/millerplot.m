function millerplot(timeArray,activityArray,csArray,position,units)
%MILLERPLOT Creates overlapping area plots of activity index and circadian
%stimulus for a 24 hour period.
%   time is in MATLAB date time series format
%   AI is activity index from a Daysimeter or Dimesimeter
%   CS is Circadian Stimulus from a Daysimeter or Dimesimeter
%   days is number of days experiment ran for

TI = timeArray - timeArray(1); % time index in days from start

% Reshape data into columns of full days
% ASSUMES CONSTANT SAMPLING RATE
dayIdx = find(TI >= 1,1,'first') - 1;
extra = rem(length(TI),dayIdx)-1;
csArray(end-extra:end) = [];
activityArray(end-extra:end) = [];
csArray = reshape(csArray,dayIdx,[]);
activityArray = reshape(activityArray,dayIdx,[]);

% Average data across days
mCS = mean(csArray,2);
mAI = mean(activityArray,2);

% Trim time index
TI = TI(1:dayIdx);
% Convert time index into hours from start
hour = TI*24;

% Find start time offset from midnight
delta = -find(timeArray >= ceil(timeArray(1)),1,'first');
% Appropriately offset the data
mCS = circshift(mCS,delta);
mAI = circshift(mAI,delta);

% Create axes to plot on
hAxes = axes;
set(hAxes,'Units',units);
set(hAxes,'ActivePositionProperty','position');
set(hAxes,'Position',position);
set(hAxes,'Units','normalized'); % Return to default
hold('on');

set(hAxes,'XTick',0:2:24);
set(hAxes,'TickDir','out');

xlim(hAxes,[0 24]);

yMax = 0.7;
if max(activityArray) > yMax
    yMax = max(activityArray);
else
    yTick = 0:0.1:0.7;
    set(hAxes,'YTick',yTick);
end
ylim(hAxes,[0 yMax]);
box('off');

% Plot AI
area1 = area(hAxes,hour,mAI,'LineStyle','none');
set(area1,...
    'FaceColor',[180, 211, 227]/256,'EdgeColor','none',...
    'DisplayName','Activity');

% Plot CS
plot1 = plot(hAxes,hour,mCS);
set(plot1,...
    'Color','k','LineWidth',2,...
    'DisplayName','Circadian Stimulus (CS)');

% Create legend
legend1 = legend([area1,plot1]);
set(legend1,'Orientation','horizontal','Location','North');

% Create x-axis label
xlabel('Time (hours)');

% Create title
title('Average Day');

% Plot a box
z = [100,100];
hLine1 = line([0 24],[yMax yMax],z,'Color','k');
hLine2 = line([24 24],[0 yMax],z,'Color','k');
hLine3 = line([0 24],[0 0],z,'Color','k');
hLine4 = line([0 0],[0 yMax],z,'Color','k');

set(hLine1,'Clipping','off');
set(hLine2,'Clipping','off');
set(hLine3,'Clipping','off');
set(hLine4,'Clipping','off');

% Eliminate excess white space
% set(gca, 'Position', get(gca, 'OuterPosition') - ...
%     get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

end

