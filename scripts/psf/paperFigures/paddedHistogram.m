function [bins,counts] = paddedHistogram(positions_mm,nbBins,nbZeroPad)

maxnorm = @(x)x/max(x);
mmToMicron=1e3;

% Calculate historgram
[counts,bins]=hist(mmToMicron*positions_mm,nbBins)

% Add Zero padding
[bins,counts] = addZeroPadding(bins,counts,nbZeroPad)


end

