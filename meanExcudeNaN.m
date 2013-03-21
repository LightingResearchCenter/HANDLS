function MEAN = meanExcudeNaN(A)
% Removes Nan elements before taking mean
% n is equal to the number of non-NaN elements

B = A(~isnan(A));
MEAN = mean(B);
