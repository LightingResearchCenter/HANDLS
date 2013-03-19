function BatchMiller
%BATCHMILLER Create Miller plots for a batch of data

load ProcessedData.mat FileDir n ProcessedData

% Make directory for plots if it does not exist
PlotDir = fullfile(FileDir,'MillerPlots');
if isdir(PlotDir) == 0
    mkdir(PlotDir);
else
    rmdir(PlotDir,'s');
    mkdir(PlotDir);
end
% Plot files
close all
for i1 = 1:n
    time = ProcessedData{i1}.time;
    CS = ProcessedData{i1}.CS;
    AI = ProcessedData{i1}.activity;
    % Check array orientation
    Dim = size(time);
    if Dim(2) > Dim(1)
        time = time';
    end
    Dim = size(CS);
    if Dim(2) > Dim(1)
        CS = CS';
    end
    Dim = size(AI);
    if Dim(2) > Dim(1)
        AI = AI';
    end
    subject = ProcessedData{i1}.subject;
    MillerPlot(time, AI, CS, 7, subject);
    FileName = [subject,'_',datestr(time(1),'yy-mm-dd')];
    print('-dpng','-r100',fullfile(PlotDir,FileName));
    close(gcf)
end

end