%================================================================%
% 05.05.2021 By Amir Sarig                                       %
% - Create 3 histogram figures (relative / cumulative) of flight %
%   direction of several insects, each figure is a different     %
%   wind speed category.                                         %
% * Each figure is normalize twice:                              %
% 1) Each trial is normalized to prescents.                      %
% 2) Each wind speed (figure) is normalized to precents          %
% - The code use the functions velocity.                         %
% - The function is called from the code 'flight_direction_wind'.%
%================================================================%

function [insects_name, relativefreq, bin_logger, j] = func_ang_hist(insects_amount, insect, frames_wind_speed, frames_trial_number, wind_speeds, angle, insects_name, relativefreq, bin_logger, j, name, hist_type)
%% recieve data
insects_name(insect).name=name;
if hist_type=='c' %fit variables to the cumulative histogram
    degrees=0:20:180; %create vector of angles in order to bin and display the data
    angle=abs(angle); %transform angles to absolute values
    hist_type='cdf';
elseif hist_type=='r' %fit variables to the probability histogram, meaning each bar hight it's his relative amount out of the total
    degrees=-180:20:180; %create vector of angles in order to bin and display the data
    hist_type='probability';
end
accumulative_relative_trials_freq(1:3,1:(length(degrees)-1))=repmat(0,3,(length(degrees)-1)); %create matrix in order to store data
wind_speed(1).range=frames_wind_speed(:)==0; %extract row numbers of frames at wind speed 0
wind_speed(2).range=ismember(frames_wind_speed(:),wind_speeds(2:round(length(wind_speeds)/2))); %extract row numbers of frames at low wind speed
wind_speed(3).range=ismember(frames_wind_speed(:),wind_speeds((round(length(wind_speeds)/2)+1):end)); %extract row numbers of frames at max wind speed

%% calculate data
for k=1:size(wind_speed,2)
trials=unique(frames_trial_number(wind_speed(k).range)); %extract trails numbers of this wind category
for i=1:length(trials)
    trial_range=frames_trial_number==trials(i); %extract row numbers of frames of relevant trial
    [N,edges] = histcounts(angle(trial_range),degrees,'Normalization',hist_type); %partitions flight direction values into 20 bins, and returns the hight of each bin
    bin_logger(j+1:j+length(N),1:5)=[repmat(insect,size(N))',repmat(0,size(N))',repmat(trials(i),size(N))',(1:length(N))',N']; %store bins data: insect, wind, #trial, #bin, count
    j=j+length(N);
    accumulative_relative_trials_freq(k,:) = accumulative_relative_trials_freq(k,:)+(N.*100); %calculate the relative frequency of each data range
end
relativefreq(k,insect,:) =  accumulative_relative_trials_freq(k,:)./length(trials); %calculate the relative frequency of each data range
end

%% after all the data exists, create figures and general annotations.
if insect==insects_amount %if it is the last call for the function
    MaxY=0; %will be used to define Y axis limits
    for i=1:3 %repeat once for each wind category
        subplot(3,1,i)
        bar(degrees(2:end)-20/2, reshape(relativefreq(i,:,:),size(relativefreq,2),size(relativefreq,3))',1) %plot current wind category data. BAR function centers the bars it creates on the supplied x-data. So 'degrees' has been translated by half an interval so the extents of the bar width fall on the limits of the data ranges
        xlim([min(degrees) max(degrees)]) %define x axis limits
        set(gca, 'xtick', degrees, 'XTickLabelRotation', 45) %set x axis ticks to be as in 'degrees' 
        axis tight %automatically adjust to match the range to y-coordinates
        temp = axis.*1.05; %add a little space to axis limits
        axis(temp(:)); %apply new limits
        yLimits = get(gca,'YLim'); %exr=tract Y axis limits
        if MaxY < yLimits(2)
            MaxY=yLimits(2); %record the maximal Y axis range
        end
        if i==1
            t=sprintf('Flight direction without wind');
            legend({insects_name(:).name}, 'FontSize', 20);
            set(gca,'XTick',[]) %delete x axis
        elseif i==2
            t=sprintf('Flight direction at relativy low wind speed');
            ylabel('Time (%)', 'FontSize', 24);
            set(gca,'XTick',[]) %delete x axis
        else
            t=sprintf('Flight direction at relativy max wind speed');
            xlabel('Angles (Degrees)', 'FontSize', 24);
        end
        title(t, 'FontSize', 18)
    end
    for i=1:3
        subplot(3,1,i) %for each subplot
        set(gca,'YLim',yLimits) %define the Y axis limits same as in the plot that have maximal Y range
        set(gca,'FontSize',20); %font size of tick axis
    end
end
end
