function MillerPlot(datetime, AI, CS, days, Title)
%MILLERPLOT Creates overlapping area plots of activity index and circadian
%stimulus for a 24 hour period.
%   time is in MATLAB date time series format
%   AI is activity index from a Daysimeter or Dimesimeter
%   CS is Circadian Stimulus from a Daysimeter or Dimesimeter
%   days is number of days experiment ran for

TI = datetime - datetime(1); % time index in days from start

% Trim data to length of experiment
delta = find(TI <= days); % indices of data to keep
datetime = datetime(delta);
TI = TI(delta);
AI = AI(delta);
CS = CS(delta);

% Reshape data into columns of full days
% ASSUMES CONSTANT SAMPLING RATE
dayIdx = find(TI >= 1,1,'first') - 1;
extra = rem(length(TI),dayIdx)-1;
CS(end-extra:end) = [];
AI(end-extra:end) = [];
CS = reshape(CS,dayIdx,[]);
AI = reshape(AI,dayIdx,[]);

% Average data across days
mCS = mean(CS,2);
mAI = mean(AI,2);

% Trim time index
TI = TI(1:dayIdx);
% Convert time index into hours from start
hour = TI*24;

% Find start time offset from midnight
delta = -find(datetime >= ceil(datetime(1)),1,'first');
% Appropriately offset the data
mCS = circshift(mCS,delta);
mAI = circshift(mAI,delta);

% Create area plots
% Create figure
figure1 = figure;
set(figure1,'PaperUnits','inches',...
    'PaperType','usletter',...
    'PaperOrientation','landscape',...
    'PaperPositionMode','manual',...
    'PaperPosition',[0.5 0.5 10 7.5],...
    'Units','inches',...
    'Position',[0 0 11 8.5]);

% Create axes
axes1 = axes('Parent',figure1,'XTick',0:2:24,...
    'TickDir','out',...
    'DataAspectRatio',[4 1 1]);
xlim(axes1,[0 24]);
% Ymax = max([max(mAI),max(mCS)]);
% Ymax = ceil(Ymax/0.5)*0.5;
Ymax = 1.5;
ylim(axes1,[0 Ymax]);
box(axes1,'off');
hold(axes1,'all');

% Create custom grid
YgridPos = 0.5:0.5:(Ymax-.5);
XgridPos = 2:2:22;
GridColor = [0.8 0.8 0.8];
% Y grid lines
for i1 = 1:length(YgridPos)
    line([0 24],[YgridPos(i1),YgridPos(i1)],'Color',GridColor,'LineStyle',':');
end
% X grid lines
for i1 = 1:length(XgridPos)
    line([XgridPos(i1),XgridPos(i1)],[0 Ymax],'Color',GridColor,'LineStyle',':');
end

% Create areas
area1 = area(hour,[mAI,mCS],'LineStyle','none');
set(area1(1),...
    'FaceColor',[0.6 0.6 0.6],'EdgeColor','none',...
    'DisplayName','CS - Circadian Stimulus');
set(area1(2),...
    'FaceColor',[0.2 0.2 0.2],'EdgeColor','none',...
    'DisplayName','AI - Activity Index');

% Create legend
legend1 = legend(area1);
set(legend1,'Orientation','horizontal','Location','NorthOutside');

% Create x-axis label
xlabel('hour');

% Create title
StartDate = datestr(datetime(1),'mmm dd, yyyy HH:MM');
EndDate = datestr(datetime(end),'mmm dd, yyyy HH:MM');
DateRange = [StartDate,' - ',EndDate];
title({Title;DateRange});

% Close box around plot
line([0 24],[Ymax Ymax],'Color','k');
line([24 24],[0 Ymax],'Color','k');

end

