function [fhandle1] = graphIndividLaps(valSpatiallyBinned, clims, ylab, overlayReward, rewardSpatiallyBinned)
    fhandle1 = figure;
    subplot(1,2,1)
    imagesc(valSpatiallyBinned, clims)
    
    xticks([0 25 50 75 100])
    xticklabels({'0', '46', '93', '140', '186'})
    xlabel('Position(cm)')
    %xline(21.5, 'r')
    
    ylabel('Laps')
    colorbar
    
    subplot(1,2,2)
    plot(movmean(valSpatiallyBinned', 3), 'Color', [.5 .5 .5])
    hold on
    plot(mean(valSpatiallyBinned, 'omitnan'), 'LineWidth', 2, 'Color', 'k')
    box off
    
    xticks([0 50 100])
    xticklabels({'0', '93', '186'})
    xlabel('Position(cm)')
    
    ylabel(ylab)

    if overlayReward
        subplot(1,2,1)
        hold on
        for j = 1:length(valSpatiallyBinned)-1
            
            rewIdx = find(rewardSpatiallyBinned(j,:)>0,1);
        %     plot( rewIdx,j, 'w.', 'MarkerSize', 10 )
        %     plot( rewIdx,j, 'w|', 'LineWidth', 1.25 )
            
            if ~isempty(rewIdx)
                plot(rewIdx,j, '^', 'MarkerSize', 2, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w' )
            end
            
        end
    end

end

