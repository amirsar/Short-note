

data=thrips_data;
wasp=0;
r=size(data,2); %recieve amount of rows
[frames_wind_speed, frames_trial_number, wind_speeds, V, horizontal_angle, vertical_angle, angles_mean_variance] = func_calc_ang_n_speed(data,1,wasp,0,0); %Create a matrix variable of flight directio in each frame, in addition extract wind speeds list, and vertical speed
trial_names=unique(frames_trial_number); %extract trial names
clear wind_speeds vertical_angle angles_mean_variance %variables that the above function create for another code
Vxy=sqrt((V(:,4).^2)+(V(:,2).^2)); %calculate horizontal flight speed
for i=1:r %repeat once for each trial
        logger_mean_upwind(i,:)=[unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))), trial_names(i), mean(Vxy(frames_trial_number==trial_names(i) & abs(horizontal_angle)<45))]; %store wind, trial data and mean speed while flying upwind
        logger_mean_all(i,:)=[unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))), trial_names(i), mean(Vxy(frames_trial_number==trial_names(i)))]; %store wind, trial data and mean speed while flying upwind
        logger_max_all(i,:)=[unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))), trial_names(i), prctile(Vxy(frames_trial_number==trial_names(i)),90)]; %store wind, trial data and mean speed while flying upwind
        logger_max_upwind(i,:)=[unique(frames_wind_speed(find(frames_trial_number==trial_names(i)))), trial_names(i), prctile(Vxy(frames_trial_number==trial_names(i) & abs(horizontal_angle)<45),90)]; %store wind, trial data and mean speed while flying upwind
end       
max(logger_max_all(:,3))
max(logger_max_upwind(:,3))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Code from direction_speed_heatmap_n_contourmap.m

variablesInCurrentWorkspace = who; %recieve names of variables in current workspace
addpath('D:\GalR10\Desktop\PhD\From Projects_n_MSc\Flight direction in wind\code') %load 'velocity' function
h=helpdlg('Manually load data files (type: struct) to workspace.\n\nMake sure that workspace contain only the data files.');
uiwait(h)

interpolation=input('Perform interpolation to maximal trial length? (0-No, 1-Yes)\n'); %user enter choice regarding interpolation
winds_name={'No wind','Low wind','High wind'};


%% Recieving data files names, and calculate max. trial length between all data variables
max_trial_length=0;
for insect=1:3 %repeat for each insect
    insects(insect).name=input('''Wasp'' / ''Bemisia'' / ''Thrips''\n'); %user enter insect name
    data=eval(sprintf('%s_data',lower(insects(insect).name))); %choose the data variable from workspace according to user selection
    for j=1:size(data,2) %for each trial in the data variable
        if max_trial_length<size(data(j).filtered_coordinates,1) %if trial length is longer then all previous
            max_trial_length=size(data(j).filtered_coordinates,1); %record length
        end
    end
end

%% calculate value of each cell
for insect=1:3 %repeat for each insect

    data=eval(sprintf('%s_data',lower(insects(insect).name))); %choose the data variable from workspace according to user selection
    wasp=strcmp('wasp',lower(insects(insect).name)); %wasp data is from my M.Sc and is different
    [frames_wind_speed, frames_trial_number, wind_speeds, V, horizontal_angle, vertical_angle, angles_mean_variance] = func_calc_ang_n_speed(data,insect,wasp,interpolation,max_trial_length); %Create a matrix variable of flight directio in each frame, in addition extract wind speeds list, and vertical speed
    clear vertical_angle angles_mean_variance %variables that the above function create for another code
    Vxy=sqrt((V(:,4).^2)+(V(:,2).^2)); %calculate horizontal flight speed
    trials=unique(frames_trial_number); %acquire trial's names
    max_speed=0;
    for trial=1:length(trials)
        logger_max_all_2(trial,:)=[unique(frames_wind_speed(find(frames_trial_number==trials(trial)))), trials(trial), prctile(Vxy(frames_trial_number==trials(trial)),90)];
        if max_speed < prctile(Vxy(frames_trial_number==trials(trial)),90) %find the 90% highest speed. Set it as 'max speed'
            max_speed = prctile(Vxy(frames_trial_number==trials(trial)),90)
        end
    end
    max(logger_max_all_2(:,3))
    clear frames_wind_speed frames_trial_number max_trial_length
end