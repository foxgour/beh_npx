behFiles = dir('*session.mat'); %or whatever the end of the sess files is

slopesLicksRew = [];
slopesVelocityRew = [];
rsqLicksRew = [];
rsqVelocityRew = [];
slopesFirst20LicksRew = [];
slopesLast20LicksRew = [];
slopesFirst20VelRew = [];
slopesLast20VelRew = [];

slopesLicksRC = [];
slopesVelocityRC = [];
rsqLicksRC = [];
rsqVelocityRC = [];
slopesFirst20LicksRC = [];
slopesLast20LicksRC = [];
slopesFirst20VelRC = [];
slopesLast20VelRC = [];


for i = 1:length(behFiles)
    fileName = behFiles(i).name;
    [rearranged_licks_rew, rearranged_speed_rew, rearranged_licks_FC, rearranged_speed_FC,rearranged_licks_RC, rearranged_speed_RC, lightCues] = getBehGraphs(fileName);
    %the reward or cue bin is 50

    meanLicksRew = mean(rearranged_licks_rew);
    [pLicks,sLicks] = polyfit(1:16, meanLicksRew(35:50), 1); %selecting 30cm before or about 16 bins
    meanSpeedsRew = mean(rearranged_speed_rew);
    [pVel,sVel] = polyfit(1:16, meanSpeedsRew(35:50), 1);

    slopesLicksRew(end+1) = pLicks(1)/1.86;
    slopesVelocityRew(end+1) = pVel(1)/1.86 * 100;
    rsqLicksRew(end+1) = sLicks.rsquared;
    rsqVelocityRew(end+1) = sVel.rsquared;

    meanLicksFirst20Rew = mean(rearranged_licks_rew(5:35,:));
    [pLicksFirst20,sLicksFirst20] = polyfit(1:16, meanLicksFirst20Rew(35:50), 1);

    meanSpeedsFirst20Rew = mean(rearranged_speed_rew(5:35,:));
    [pVelFirst20,sVelFirst20] = polyfit(1:16, meanSpeedsFirst20Rew(35:50), 1);

    meanLicksLast20Rew = mean(rearranged_licks_all(70:100,:)); %ideally there are over 100 laps, otherwise move window
    [pLicksLast20,sLicksLast20] = polyfit(1:16, meanLicksLast20Rew(35:50), 1);

    meanSpeedsLast20Rew = mean(rearranged_speed_rew(70:100,:));
    [pVelLast20,sVelLast20] = polyfit(1:16, meanSpeedsLast20Rew(35:50), 1);

    slopesFirst20LicksRew(end+1) = pLicksFirst20(1)/1.86;
    slopesLast20LicksRew(end+1) = pLicksLast20(1)/1.86;
    slopesFirst20VelRew(end+1) = pVelFirst20(1)/1.86 * 100;
    slopesLast20VelRew(end+1) = pVelLast20(1)/1.86 * 100;

    if lightCues
        %also to random
        meanLicksRC = mean(rearranged_licks_RC);
        [pLicks,sLicks] = polyfit(1:16, meanLicksRC(35:50), 1); %selecting 30cm before or about 16 bins
        meanSpeedsRC = mean(rearranged_speed_RC);
        [pVel,sVel] = polyfit(1:16, meanSpeedsRC(35:50), 1);
    
        slopesLicksRC(end+1) = pLicks(1)/1.86;
        slopesVelocityRC(end+1) = pVel(1)/1.86 * 100;
        rsqLicksRC(end+1) = sLicks.rsquared;
        rsqVelocityRC(end+1) = sVel.rsquared;
    
        meanLicksFirst20RC = mean(rearranged_licks_RC(5:35,:));
        [pLicksFirst20,sLicksFirst20] = polyfit(1:16, meanLicksFirst20RC(35:50), 1);
    
        meanSpeedsFirst20RC = mean(rearranged_speed_RC(5:35,:));
        [pVelFirst20,sVelFirst20] = polyfit(1:16, meanSpeedsFirst20RC(35:50), 1);
    
        meanLicksLast20RC = mean(rearranged_licks_RC(70:100,:)); %ideally there are over 100 laps, otherwise move window
        [pLicksLast20,sLicksLast20] = polyfit(1:16, meanLicksLast20RC(35:50), 1);
    
        meanSpeedsLast20RC = mean(rearranged_speed_all(70:100,:));
        [pVelLast20,sVelLast20] = polyfit(1:16, meanSpeedsLast20RC(35:50), 1);
    
        slopesFirst20LicksRC(end+1) = pLicksFirst20(1)/1.86;
        slopesLast20LicksRC(end+1) = pLicksLast20(1)/1.86;
        slopesFirst20VelRC(end+1) = pVelFirst20(1)/1.86 * 100;
        slopesLast20VelRC(end+1) = pVelLast20(1)/1.86 * 100;
    end
end


%%
%graph