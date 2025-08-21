function [rearranged_licks_rew, rearranged_speed_rew,rearranged_licks_FC, rearranged_speed_FC,rearranged_licks_RC, rearranged_speed_RC, lightCue] ...
    = getBehGraphs(sess)

    
    sessName = sess.name(1:end-3);
    mkdir(pwd, "\plots" + sessName);
    cd(pwd +  "\plots" + sessName);
    try 
        sess.fixedCue;
        lightCue = 1;
    catch
        lightCue = 0;
    end
    
    %set up global variables for acquisition rate and speed threshold
    global acq;
    acq = sess.samprate;
    global speedThreshold
    speedThreshold = 4; %4cm/s
    
    recTime = length(sess.ts)/acq;
    
    % assign number of laps and bins
    numBins = 100;
    
    % extract runTimes
    runTimes = (sess.velshft >= speedThreshold);
    runTimes=double(runTimes);
    
    %%%% convert into laps
    endRec = length(sess.ts);
    numLaps = sess.nlaps;
    startLevels = sess.lapstt;
    
    speedL = splitIntoLaps(sess.velshft, numLaps, startLevels, endRec);
    distanceL = splitIntoLaps(sess.pos, numLaps, startLevels, endRec);
    
    %integrating to find distance based on speed 
    integDistanceL = cell(1,length(speedL));
    for j = 1:length(speedL)
        integDistanceL(j) = {(cumtrapz(speedL{j})/acq)/100};
    end
    
    timeL = splitIntoLaps(sess.ts, numLaps, startLevels, endRec);
    licksL = splitIntoLaps(sess.lck, numLaps, startLevels, endRec);
    rewardL = splitIntoLaps(sess.rwd, numLaps, startLevels, endRec);
    runTimesL = splitIntoLaps(runTimes, numLaps, startLevels, endRec);
    
    overlayReward = 1;
    %make zero to not overlay reward^
    %get reward field
    val = rewardL;
    scaling = 0;
    convertToRate = 0;
    ylab = '';
    rewardSpatiallyBinned = spatiallyBin(val,numBins,speedL,distanceL,scaling,convertToRate, 0);
    close
    rewardSpatiallyBinned(rewardSpatiallyBinned ==0) = nan;
    rewardSpatiallyBinned(rewardSpatiallyBinned >0) = 1;

    val = timeL;
    scaling = 0;
    convertToRate = 0;
    ylab = '';
    timeSpatiallyBinned = spatiallyBin(val,numBins,speedL,distanceL,scaling,convertToRate, 1);
    close
    
    if lightCue
        fixedCueL = splitIntoLaps(sess.fixedCue, numLaps, startLevels, endRec);
        randCueL = splitIntoLaps(sess.randCue, numLaps, startLevels, endRec);
        %get randcue field
        val = randCueL;
        scaling = 0;
        convertToRate = 0;
        ylab = '';
        randcueSpatiallyBinned = spatiallyBin(val,numBins,speedL,distanceL,scaling,ylab,convertToRate);
        close
        randcueSpatiallyBinned(randcueSpatiallyBinned < 2 ) = nan;
        randcueSpatiallyBinned(randcueSpatiallyBinned > 2) = 1;
    
        %get fixedcue field
        val = fixedCueL;
        scaling = 0;
        convertToRate = 0;
        ylab = '';
        fixedcueSpatiallyBinned = spatiallyBin(val,numBins,speedL,distanceL,scaling,ylab,convertToRate);
        close
        fixedcueSpatiallyBinned(fixedcueSpatiallyBinned < 2 ) = nan;
        fixedcueSpatiallyBinned(fixedcueSpatiallyBinned > 2) = 1;
    end
    
    %plot velocity
    val = speedL;
    scaling = 0;
    convertToRate = 0;
    ylab = 'Speed (cm/s)';
    [speedSpatiallyBinned, clims] = spatiallyBin(val,numBins,speedL,distanceL,scaling,convertToRate, 0);
    graphIndividLaps(speedSpatiallyBinned, clims, ylab, overlayReward, rewardSpatiallyBinned);
    sgtitle('Speed')
    savefig(gcf, "speed" + sessName + ".fig")
    
    %plot licking
    val = licksL;
    scaling = 0;
    convertToRate = 0;
    ylab = 'Licks';
    [licksSpatiallyBinned, clims] = spatiallyBinSum(val,numBins,speedL,distanceL,scaling,convertToRate, 0);
    graphIndividLaps(licksSpatiallyBinned, clims, ylab, overlayReward, rewardSpatiallyBinned);
    sgtitle('Licks')
    savefig(gcf, "licks" + sessName + ".fig")
    close all

    %plot licking in Hz
    scaling = 0;
    convertToRate = 0;
    ylab = 'Licks (Hz)';
    lickHzSpatiallyBinned = licksSpatiallyBinned./timeSpatiallyBinned;
    clims = [prctile(lickHzSpatiallyBinned(:),1) prctile(lickHzSpatiallyBinned(:),99)];
    graphIndividLaps(lickHzSpatiallyBinned, clims, ylab, overlayReward, rewardSpatiallyBinned);
    sgtitle('Lick Rate')
    savefig(gcf, "lickHz" + sessName + ".fig")
    close all
    
    %% plot licks/speed with SEM with reward release at zero
    [rearranged_speed_rew, rearranged_licks_rew] = normalizeToCue(rewardSpatiallyBinned, lickHzSpatiallyBinned, speedSpatiallyBinned);
    
    rearranged_speed_rew = circshift(rearranged_speed_rew, [0 49]); %rew should now be in middle
    rearranged_licks_rew = circshift(rearranged_licks_rew, [0 49]);
    
    x_axis = (-numBins/2:numBins/2-1) * 1.86; 
    
    mean_licks = nanmean(rearranged_licks_rew, 1); % Mean across rows (laps)
    sem_licks = nanstd(rearranged_licks_rew, 0, 1) ./ sqrt(sum(~isnan(rearranged_licks_rew), 1)); % SEM
    
    mean_speeds = nanmean(rearranged_speed_rew, 1); % Mean across rows (laps)
    sem_speeds = nanstd(rearranged_speed_rew, 0, 1) ./ sqrt(sum(~isnan(rearranged_speed_rew), 1)); % SEM
    
    shadedErrorBar(x_axis, mean_licks, sem_licks,'lineprops', {'-r', 'LineWidth', 1.3}, 'transparent', true);
    xline(0, '--g')
    xlim([min(x_axis) max(x_axis)])
    savefig(gcf, "licksBinSEM" + sessName + ".fig")
    close all
    
    shadedErrorBar(x_axis, mean_speeds, sem_speeds,'lineprops', {'-b', 'LineWidth', 1.3}, 'transparent', true);
    xline(0, '--g')
    xlim([min(x_axis) max(x_axis)])
    savefig(gcf, "speedsBinSEM" + sessName + ".fig")
    close all
    
    
    %% cues for light paradigm
    if lightCue
        [rearranged_speed_FC, rearranged_licks_FC] = normalizeToCue(fixedcueSpatiallyBinned, lickHzSpatiallyBinned, speedSpatiallyBinned);
        
        rearranged_speed_FC = circshift(rearranged_speed_FC, [0 49]); %rew should now be in middle
        rearranged_licks_FC = circshift(rearranged_licks_FC, [0 49]);
        
        x_axis = (-numBins/2:numBins/2-1) * 1.86; 
        
        mean_licks = nanmean(rearranged_licks_FC, 1); % Mean across rows (laps)
        sem_licks = nanstd(rearranged_licks_FC, 0, 1) ./ sqrt(sum(~isnan(rearranged_licks_rew), 1)); % SEM
        
        mean_speeds = nanmean(rearranged_speed_FC, 1); % Mean across rows (laps)
        sem_speeds = nanstd(rearranged_speed_FC, 0, 1) ./ sqrt(sum(~isnan(rearranged_speed_rew), 1)); % SEM
        
        shadedErrorBar(x_axis, mean_licks, sem_licks,'lineprops', {'-r', 'LineWidth', 1.3}, 'transparent', true);
        xline(0, '--g')
        xlim([min(x_axis) max(x_axis)])
        savefig(gcf, "licksBinSEMFixedCue_" + sessName + ".fig")
        close all
        
        shadedErrorBar(x_axis, mean_speeds, sem_speeds,'lineprops', {'-b', 'LineWidth', 1.3}, 'transparent', true);
        xline(0, '--g')
        xlim([min(x_axis) max(x_axis)])
        savefig(gcf, "speedsBinSEMFixedCue_" + sessName + ".fig")
        close all
    
        [rearranged_speed_RC, rearranged_licks_RC] = normalizeToCue(randcueSpatiallyBinned, licksSpatiallyBinned, speedSpatiallyBinned);
        
        rearranged_speed_RC = circshift(rearranged_speed_RC, [0 49]); %rew should now be in middle
        rearranged_licks_RC = circshift(rearranged_licks_RC, [0 49]);

        mean_licks = nanmean(rearranged_licks_RC, 1); % Mean across rows (laps)
        sem_licks = nanstd(rearranged_licks_RC, 0, 1) ./ sqrt(sum(~isnan(rearranged_licks_rew), 1)); % SEM
        
        mean_speeds = nanmean(rearranged_speed_RC, 1); % Mean across rows (laps)
        sem_speeds = nanstd(rearranged_speed_RC, 0, 1) ./ sqrt(sum(~isnan(rearranged_speed_rew), 1)); % SEM
        
        shadedErrorBar(x_axis, mean_licks, sem_licks,'lineprops', {'-r', 'LineWidth', 1.3}, 'transparent', true);
        xline(0, '--g')
        xlim([min(x_axis) max(x_axis)])
        savefig(gcf, "licksBinSEMRandCue_" + sessName + ".fig")
        close all
        
        shadedErrorBar(x_axis, mean_speeds, sem_speeds,'lineprops', {'-b', 'LineWidth', 1.3}, 'transparent', true);
        xline(0, '--g')
        xlim([min(x_axis) max(x_axis)])
        savefig(gcf, "speedsBinSEMRandCue_" + sessName + ".fig")
        close all
    else
        rearranged_licks_FC = 0;
        rearranged_speed_FC = 0;
        rearranged_licks_RC = 0;
        rearranged_speed_RC = 0;
    end
end