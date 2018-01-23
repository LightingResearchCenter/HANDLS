function Q = importQuestionnaire
%IMPORTQUESTIONNAIRE Summary of this function goes here
%   Detailed explanation goes here

% Import questionnaire
qPath = '\\root\projects\HANDLS\sleepquest.csv';
Q = readtable(qPath);

% Import descriptions
dPath = '\\root\projects\HANDLS\sleepquest_label.csv';
D = readtable(dPath);

labels = Q.Properties.VariableNames;
descriptions = cell(size(labels));

for iLabel = 1:numel(labels)
    thisLabel = labels{iLabel};
    
    idx = strcmpi(thisLabel,D.label);
    try
    thisDescription = D.description{idx};
    catch err
        display('hi')
    end
    
    if isempty(thisDescription)
        thisDescription = '';
    end
    
    descriptions{iLabel} = thisDescription;
end

Q.Properties.VariableDescriptions = descriptions;

end

