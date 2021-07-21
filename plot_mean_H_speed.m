%=========================================================================%
% 13.07.2021 By Amir Sarig                                                %
%                                                                         %
% - Input: Load to workspace the data flies from projects and MSc         %
% - Outpot:                                                               %
%    - Scatter of trial's mean speed at upwind flight Vs. wind. Insects   %
%      are distinguish by uniqe color.                                    %
%    - Flight speed data in variables: 'mean_upwind_speed_data' and       %
%      'abs_aerial_Vxy_Mean_Var_logger'.                                  %
%                                                                         %
% Notes:                                                                  %
% - Variable 'mean_upwind_speed_data' store all the data                  %
% - Look better with Matlab 2019. There is compatible code line for V2014 %
% - Use 'velocity.m', 'func_calc_ang_n_speed.m' and 'common2latine_name.m'%
%=========================================================================%
addpath('D:\GalR10\Desktop\PhD\From Projects_n_MSc\Flight direction in wind\code') %load 'velocity' function
h=helpdlg('Manually load data files (type: struct) to workspace');
uiwait(h)
addpath('D:\GalR10\Desktop\Sapir\Codes') %load 'velocity' function
insects_amount=input('How many insects species are in the study?   \n');
figure
hold on
% set(gca,'ColorOrder',[0.2081 0.1663 0.5292; 0.19855 0.7214 0.63095; 0.9763 0.8 0; 0 0.5 1; 1 0 0.3; 0 0.7 0; 0 0 0]); %define color for 4 data sets - purple, greenish-blue, yellow, light blue, light red, green, black
ymax=0; %will be used to set axis limit
xmax=0; %will be used to set axis limit
logger_i=1; %index for speed mean&var. logger
for j=1:insects_amount %repeat for each insect
    %ind=1; %index for 'ground_speed_logger'
    insect_name=input('Wasp / Bemisia / Thrips\n'); %user enter insect name
    legend_names(j).names=common2latine_name(insect_name); %prepare insects names for legend
    data=eval(sprintf('%s_data',lower(insect_name))); %choose the data variable from workspace according to user selection
    r=size(data,2); %recieve amount of rows
    wasp=strcmp('wasp',lower(insect_name)); %wasp data is from my M.Sc and is different
    [frames_wind_speed, frames_trial_number, wind_speeds, V, horizontal_angle, vertical_angle, angles_mean_var, frames_wind_category, max_speed] = func_calc_ang_n_speed(data,j,wasp,0,0); %Create a matrix variable of flight directio in each frame, in addition extract wind speeds list, and vertical speed
    clear wind_speeds vertical_angle angles_mean_var frames_wind_category max_speed %variables that the above function create for another code
    Vxy=sqrt((V(:,4).^2)+(V(:,2).^2)); %calculate horizontal flight speed
    trial_names=unique(frames_trial_number); %extract trial names
    temp={data(:).wind}; %extract all trial's wind speeds
    wind_speeds=unique(cell2mat(temp)); %record each wind speed once
    
%% calculate and store
    for i=1:r %repeat once for each trial
        logger(i,:)=[unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))), trial_names(i), mean(Vxy(frames_trial_number==trial_names(i) & abs(horizontal_angle)<45))]; %store wind, trial data and mean speed while flying upwind
        if any(unique(frames_wind_speed(find(frames_trial_number==trial_names(i))))==wind_speeds((round(length(wind_speeds)/2)+1):end)) %divid wind speeds into 3 categories
            wind_category=2; %storng wind
        elseif any(unique(frames_wind_speed(find(frames_trial_number==trial_names(i))))==wind_speeds(2:round(length(wind_speeds)/2)))
            wind_category=1; %low wind
        else
            wind_category=0; %no wind
        end
        abs_aerial_Vxy_Mean_Var_logger(logger_i,:)=[j, unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))), wind_category, mean(Vxy(frames_trial_number==trial_names(i))), var(Vxy(frames_trial_number==trial_names(i)))]; %store trial's Vxy mean%var. with insect, wind, and trial data. Intended for external use, not for the figure.
        logger_i=logger_i+1;
        %ground_X_speed_logger(j,ind:(ind+sum(frames_trial_number==trial_names(i))-1),:)=[repmat(j,sum(frames_trial_number==trial_names(i)),1),repmat(unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))),sum(frames_trial_number==trial_names(i)),1),repmat(trial_names(i),sum(frames_trial_number==trial_names(i)),1),V(frames_trial_number==trial_names(i),1)];%extract ground X axis speed in order to verify wind really exist in expirement (with data of insect, wind speed and trial)
        %ind=ind+length(V); %update index
    end
    if max(logger(:,3))>ymax
        ymax=max(logger(:,3)); %store y axis limit
    end
    if max(logger(:,1))>xmax
        xmax=max(logger(:,1)); %store x axis limit
    end
    if wasp
        logger(logger(:,1)==0.51,:)=[]; %delete 0.51 m/s trials from data (Gal's decision on July 21')
    end
%     L(j)=scatter(logger(:,1),logger(:,3), 100, 'filled', 'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',1); %plot in Matlab2019
    L(j)=scatter(logger(:,1),logger(:,3),50,'filled','DisplayName',insect_name); %plot in Matlab 2014
    mean_upwind_speed_data.(insect_name)=logger; %store data
    clear logger wasp r data insect_name %clear variables that will be used again in the next iteration
end

if xmax>ymax
    axis_limits=xmax; %set qubic axis limits
else
    axis_limits=ymax; %set qubic axis limits
end
axis([-0.05 (axis_limits+0.05) -0.05 (axis_limits+0.05)]) %set qubic axis limits
axis square %define equal distance in x & y axis
grid on %turn on grid in order to easly see that axis are equal
xlabel('Wind speed (m/s)', 'FontSize', 24);
ylabel('Aerial horizontal upwind flight speed (m/s)', 'FontSize', 24);
set(gca,'FontSize',20); %font size of tick axis
plot([0.05 (axis_limits+0.05)],[0.05 (axis_limits+0.05)],'--','Color',[0 0 0],'LineWidth',2) %add line to seperate drifting to upward movemoent
h=legend(L(:),legend_names(:).names,'Location', 'southeast'); %display and set loction of legend
h.FontSize=20; %font size of legend
figure(1)
%title('Trial's mean flight speed Vs. Wind speed');
%print(gcf,'trials mean speed Vs. wind.png','-dpng','-r600'); %save figure in high resolution