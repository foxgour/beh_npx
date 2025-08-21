

 function [valSpatiallyBinned,clims] = spatiallyBinSum(val,numBins,speedL,distanceL,scaling,convertToRate, timeFlag)

 %sum of crossings

    
numLaps = length(val);

global acq
global speedThreshold

% create a cell array for laps
valL = cell(1,numLaps-1); %cut off first incomplete lap

for i = 2:numLaps
    
    totalDistance = mean(distanceL{1,i}(end-100:end,1));
    binSize = totalDistance/numBins;
    
    startDistance = find(distanceL{1,i}(:,1)<0.05,1);
    distanceL{1,i}(1:startDistance-1,1)= 0;
    
    
    
    %splitting into bins and taking avg value of each bin
    for j = 1:numBins
        beginDistance = find(distanceL{1,i}(:,1)>(j-1)*binSize,1);
        endDistance = find(distanceL{1,i}(:,1)>j*binSize,1);
        
        val{i}(speedL{i} < speedThreshold)= NaN; % apply stopping filter
        valL{i} = val{i};
        
        if ~isempty(endDistance)
            if ~all(isnan(valL{i}(beginDistance : endDistance)))
                try
                    valSpatiallyBinned(i-1, j) = length(find((valL{i}(beginDistance : endDistance-1) > 1 & valL{i}(beginDistance+1 : endDistance) < 1)));
                catch
                    valSpatiallyBinned(i-1, j) = 0;
                end
            else
                valSpatiallyBinned(i-1, j) = 0;
            end
        end
    
    end
  
    
%     valSpatiallyBinnedUnscaled(i, :) = valSpatiallyBinned(i, :);
    
    if scaling == 1
        %valSpatiallyBinned(i, :) = rescale(valSpatiallyBinned(i, :)); %make values go between 0 and 1
        for j = 1:numBins
            if valSpatiallyBinned(i-1, j) > 0.5
                valSpatiallyBinned(i-1, j) = 1;
            else
                valSpatiallyBinned(i-1, j) = 0;
        end
    end
    
    if convertToRate ==1
        valSpatiallyBinned(i-1, :) = valSpatiallyBinned(i, :)*acq;
    end
        
end
  
clims = [prctile(valSpatiallyBinned(:),1) prctile(valSpatiallyBinned(:),99)];
if any(clims)==0
    clims = [min(valSpatiallyBinned(:)) max(valSpatiallyBinned(:))];
    
    if clims(1)>= clims(2)
        clims = [0 1];
    end
        
end
end