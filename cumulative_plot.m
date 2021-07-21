%================================================================%
% 13.07.2021 By Amir Sarig                                       %
% - Create 3 cumulative figures of flight direction of several   %
% insects, each figure is a different wind speed category.       %
% - The function is called from the code 'flight_direction_wind'.%
%================================================================%

function [insects_name, j] = cumulative_plot(insects_amount, insect, frames_wind_speed, wind_speeds, angle, insects_name, j, name, wasp)
%% recieve data
insects_name(insect).name=name;
%accumulative_relative_trials_freq(1:3,1:(length(degrees)-1))=repmat(0,3,(length(degrees)-1)); %create matrix in order to store data
wind_speed(1).range=frames_wind_speed(:)==0; %extract row numbers of frames at wind speed 0
wind_speed(2).range=ismember(frames_wind_speed(:),wind_speeds(2:round(length(wind_speeds)/2))); %extract row numbers of frames at low wind speed
if wasp
    wind_speed(3).range=ismember(frames_wind_speed(:),wind_speeds((round(length(wind_speeds)/2)+1):(end-1))); %extract row numbers of frames at max wind speed except 0.51 m/s (Gal's decision on July 21')
else
    wind_speed(3).range=ismember(frames_wind_speed(:),wind_speeds((round(length(wind_speeds)/2)+1):end)); %extract row numbers of frames at max wind speed
end
%% create figures
for j=1:size(wind_speed,2) %for each wind category
    subplot(3,1,j)
    hold on
    h=cdfplot(abs(angle(wind_speed(j).range)).*(-1)); %plot cumulative graph
    set(h,'LineWidth',3) %increase line width
    h=get(gca); h.XLabel.String={}; h.YLabel.String={}; %delete defualt x & y labels
end

%% after all the data exists, create figures and general annotations.
if insect==insects_amount %if it is the last call for the function
    for i=1:3 %repeat once for each wind category
        subplot(3,1,i)
        set(gca, 'XTickLabelRotation', 45) %set x axis ticks rotation 
        if i==1
            t=sprintf('No wind');
            for j=1:length(insects_name)
                insects_name(j).name=common2latine_name(insects_name(j).name);
            end
            legend(insects_name(:).name, 'FontSize', 20,'Location','Northwest');  %legend
            set(gca,'XTick',[]) %delete x axis
        elseif i==2
            t=sprintf('''Low'' wind speed');
            ylabel('Cumulative frequency of occurrence (%)', 'FontSize', 24); % y axis label
            set(gca,'XTick',[]) %delete x axis
        else
            t=sprintf('''High'' wind speed');
            xlabel('Flight direction (Degrees)', 'FontSize', 24); % x axis label
        end
        title(t, 'FontSize', 18) %subplot title
        set(gca,'FontSize',20); %font size of tick axis
    end
end
end