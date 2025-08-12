function [rearranged_speed_all, rearranged_licks_all]... 
    = normalizeToCue(cueSpatiallyBinned, licksSpatiallyBinned, speedSpatiallyBinned)
% % 


% Initialize the matrices to hold the shifted data
rearranged_licks_all = [];  % Empty matrix to store shifted licks data
rearranged_speed_all = [];  % Empty matrix to store shifted speed data

% Loop over each lap
for i = 1:length(licksSpatiallyBinned(:,1))
    % Find the reward bin (column index where reward is located)
    cue_Bin = find(cueSpatiallyBinned(i, :) == 1, 1);
    
    % Check if a reward was found; if not, skip to the next iteration
    if isempty(cue_Bin)
        continue;
    end

    % Create an index array representing the original indices
    indices = 1:length(licksSpatiallyBinned(i, :));
    
    % Shift the indices so that the reward location becomes index 1
    shifted_indices = circshift(indices, [0, 1 - cue_Bin]);
   
    % Apply the same index shift to problicks, speed, and reward data
    rearranged_licks = licksSpatiallyBinned(i, shifted_indices);    
    rearranged_speed = speedSpatiallyBinned(i, shifted_indices);     

    rearranged_licks_all = [rearranged_licks_all; rearranged_licks];
    rearranged_speed_all = [rearranged_speed_all; rearranged_speed];
end


