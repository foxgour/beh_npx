function [slope, rsquared] = getSlope(valSpatiallyBinned, binRange, lapRange)
%GETSLOPE 
% returns slope and rsquared for fit for val in binRange in laprange
% lap range and bin range should be arrays with 2 values
%
meanVal = mean(valSpatiallyBinned(lapRange(1):lapRange(2)));
[p,s] = polyfit(1:16, meanVal(binRange(1):binRange(2)), 1); 

slope = p(1);
rsquared = s.rsquared;

end

