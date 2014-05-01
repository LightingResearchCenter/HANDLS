function plotnotes(Phasor,Average,position,units)
%PLOTNOTES Summary of this function goes here
%   hFigure = figure handle

% Create axes to plot on
hAxes = axes;
set(hAxes,'Units',units);
set(hAxes,'ActivePositionProperty','position');
set(hAxes,'Position',position);
set(hAxes,'XLim',[0,position(3)]);
set(hAxes,'YLim',[0,position(4)]);
set(hAxes,'Visible','off'); % 'on' or 'off'

% Create text
precision = '%.2f';

label1 = {...
                   'Phasor Magnitude: ';...
                       'Phasor Angle: ';...
                                     '';...
          'Interdaily Stability (IS): ';...
        'Intradaily Variability (IV): ';...
                                     '';...
                   'Average Activity: ';...
	'Average Circadian Stimulus (CS): ';...
       'Average Photopic Illuminance: ';};

data1 = {...
    num2str(Phasor.magnitude, precision);...
   [num2str(Phasor.angleHrs, precision), ' hours'];...
    '';...
    num2str(Phasor.interdailyStability, precision);...
    num2str(Phasor.intradailyVariability, precision);...
    '';...
    num2str(Average.activity, precision);...
	num2str(Average.cs, precision);...
   [num2str(Average.illuminance, precision), ' lux']};

top = position(4) - 0.125;
middle1 = 2.25;
fontSize = 12;

plottext(label1,data1,middle1,top,fontSize);

end


function plottext(label,data,middle,top,fontSize)

hLabel = text(middle,top,label);
formatlabel(hLabel,fontSize);
label1Extent = get(hLabel,'Extent');
label1Position = get(hLabel,'Position');

hData = text(middle,top,data);
formatdata(hData,fontSize)
data1Extent = get(hData,'Extent');
data1Position = get(hData,'Position');

newMiddle1 = 2*middle-(label1Extent(1)+(label1Extent(3)+data1Extent(3))/2);
label1Position(1) = newMiddle1;
data1Position(1) = newMiddle1;
set(hLabel,'Position',label1Position);
set(hData,'Position',data1Position);

end

function formatlabel(hLabel,fontSize)
set(hLabel,'VerticalAlignment','top');
set(hLabel,'HorizontalAlignment','right');
set(hLabel,'FontSize',fontSize);

end

function formatdata(hData,fontSize)
set(hData,'VerticalAlignment','top');
set(hData,'HorizontalAlignment','left');
set(hData,'FontSize',fontSize);

end


