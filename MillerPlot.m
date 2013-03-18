function MillerPlot(datetime, AI, CS)
%MILLERPLOT Creates overlapping area plots of activity index and circadian
%stimulus for a 24 hour period.
%   time is in MATLAB date time series format
%   AI is activity index from a Daysimeter or Dimesimeter
%   CS is Circadian Stimulus from a Daysimeter or Dimesimeter

% Check if time period is greater than 24 hours if true trim data to first
% 24 hours
T = etime(datevec(datetime(end)),datevec(datetime(1)))/3600; % time period in hours
if T > 24
    idx = find(datetime<=addtodate(datetime(1),24,'hour')); % indices of data to keep
    datetime = datetime(idx); % trim time
    AI = AI(idx); % trim AI
    CS = CS(idx); % trim CS
end

% Convert time into hours from start
hour = (datetime - datetime(1))*24;

% Create area plots
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'XTick',0:2:24,...
    'TickDir','out',...
    'DataAspectRatio',[4 1 1]);
xlim(axes1,[0 24]);
% Ymax = ceil(max([max(AI),max(CS)]));
Ymax = 2;
ylim(axes1,[0 Ymax]);
box(axes1,'off');
hold(axes1,'all');

% Create custom grid
YgridPos = .5:.5:(Ymax-.5);
XgridPos = 2:2:22;
GridColor = [0.8 0.8 0.8];
% Y grid lines
line([0 24],[YgridPos',YgridPos'],'Color',GridColor,'LineStyle',':');
% X grid lines
line([XgridPos',XgridPos'],[0 Ymax],'Color',GridColor,'LineStyle',':');

% Close box around plot
line([0 24],[Ymax Ymax],'Color','k');
line([24 24],[0 Ymax],'Color','k');

% Create areas
area1 = area(hour,[AI,CS],'LineStyle','none');
set(area1(1),...
    'FaceColor',[0.6 0.6 0.6],'EdgeColor','none',...
    'DisplayName','CS - Circadian Stimulus');
set(area1(2),...
    'FaceColor',[0.2 0.2 0.2],'EdgeColor','none',...
    'DisplayName','AI - Activity Index');

% Create legend
legend1 = legend(area1);
set(legend1,'Orientation','horizontal','Location','NorthOutside');

end

