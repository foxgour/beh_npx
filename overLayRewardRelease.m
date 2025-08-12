
if overlayReward == 1


subplot(1,2,1)
hold on
for j = 1:length(timeL)
    
    rewIdx = find(rewardSpatiallyBinned(j,:)>0,1);
%     plot( rewIdx,j, 'w.', 'MarkerSize', 10 )
%     plot( rewIdx,j, 'w|', 'LineWidth', 1.25 )
    
    if ~isempty(rewIdx)
        plot(rewIdx,j, '^', 'MarkerSize', 2, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w' )
    end
    
end


end