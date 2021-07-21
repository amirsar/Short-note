%=========================================================================%
% 10.06.2021 By Amir Sarig                                                %
% Input:                                                                  %
% - Data files of insect flight, in struct variable. Created by the code: % 
%   extract_data_from_MSc_data.m                                          %
% Output:                                                                 %
% - Create 3 histogram figures (relative/cumulative) of flight direction  %
%   of several insects, each figure is a different wind speed category.   %   
% - Store figure data in "relativefreq", and original bins in "bin_logger"%
% - Store angles data with categorial afiliationin in "angles_logger"     %
% - Store mean&std of trial's angles in "angles_mean_var_logger"%
% - The code use the functions velocity, calc_ang_n_speed, func_ang_hist, %
%   and cumulative_plot.                                                  %
%=========================================================================%

variablesInCurrentWorkspace = who; %recieve names of variables in current workspace
msg=sprintf('Manually load data files (type: struct) to workspace.\n\nMake sure that workspace contain only the data files.');
h=msgbox(msg);
uiwait(h)
angles_name=input('Which angles variable to use?  (horizontal_angle / vertical_angle) ','s');
hist_type=input('Choose figure: relative histogram (''r'') / cumulative histogram (''c'') / cumulative plot (''p'') - ');
interpolation=0;
if hist_type=='p'
    interpolation=input('Perform interpolation to maximal trial length? (0-No, 1-Yes)\n'); %user enter choice regarding interpolation
end
insects_name=[];
relativefreq=[];
bin_logger=[];
j=0;
angles_logger=[];
angles_mean_var_logger.horizontal=[];
angles_mean_var_logger.vertical=[];
for i=1:length(variablesInCurrentWorkspace) %repeat for each insect
    max_trial_length=0; %will be used if user choose to interpolate trials to equal length
    name=input('''Wasp'' / ''Bemisia'' / ''Thrips''\n'); %user enter insect name
    data_name=sprintf('%s_data',lower(name)); %choose the data variable from workspace according to user selection
    wasp=strcmp('wasp',lower(name)); %wasp data is from my M.Sc and is different
    if interpolation
        data=eval(data_name);
        for j=1:size(data,2) %for each trial in the data variable
            if max_trial_length<size(data(j).filtered_coordinates,1) %if trial length is longer then all previous
                max_trial_length=size(data(j).filtered_coordinates,1); %record length
            end
        end
    end
    [frames_wind_speed, frames_trial_number, wind_speeds, V, horizontal_angle, vertical_angle, angles_mean_var, frames_wind_category, max_speed] = func_calc_ang_n_speed (eval(data_name),i,wasp,interpolation,max_trial_length); %Create a matrix variable of flight directio in each frame, in addition extract wind speeds list, and vertical speed
    if hist_type=='p' %if user choose cumulative plot
        [insects_name, j] = cumulative_plot(length(variablesInCurrentWorkspace), i, frames_wind_speed, wind_speeds, eval(angles_name), insects_name, j, name, wasp); %Create 3 plot figures of flight direction of several insects, each figure is different wind speed.
    else
        [insects_name, relativefreq, bin_logger, j] = func_ang_hist(length(variablesInCurrentWorkspace), i, frames_wind_speed, frames_trial_number, wind_speeds, eval(angles_name), insects_name, relativefreq, bin_logger, j, name, lower(hist_type)); %Create 3 histogram figures of flight direction of several insects, each figure is different wind speed.
    end
    angles_logger(length(angles_logger)+1:length(angles_logger)+length(frames_trial_number),:) = [repmat(i,length(frames_trial_number),1), frames_wind_speed', frames_wind_category', frames_trial_number', eval(angles_name)']; %store angles
    angles_mean_var_logger.horizontal(length(angles_mean_var_logger.horizontal)+1:length(angles_mean_var_logger.horizontal)+length(angles_mean_var.horizontal),:) = angles_mean_var.horizontal; %store trial's mean and std horizontal angle. columns order: insect, wind speed, wind category, trial, mean, std
    angles_mean_var_logger.vertical(length(angles_mean_var_logger.vertical)+1:length(angles_mean_var_logger.vertical)+length(angles_mean_var.vertical),:) = angles_mean_var.vertical; %store trial's mean and std vartical angle. columns order: insect, wind speed, wind category, trial, mean, std
    fprintf('%s succesfully exctraced !\n', name)
end
if hist_type~='p'
    bin_logger = array2table(bin_logger,'VariableNames',{'insect', 'wind', 'trial', 'bin', 'count'}); %insect's serial number depends on user input. winds: 0-no, 1-low, 2-high
end
angles_logger = array2table(angles_logger,'VariableNames',{'insect', 'wind_speed', 'wind_category', 'trial', 'angle'}); %insect's serial number depends on user input. winds: 0-no, 1-low, 2-high