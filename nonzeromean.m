function average = nonzeromean(data)
%NONZEROMEAN Take the average of values greater than zero
%   data is a vector of real numbers

roundedData = floor(data*100)/100;
nonZeroIdx = roundedData > 0;
nonZeroData = data(nonZeroIdx);
average = mean(nonZeroData);

end

