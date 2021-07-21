%=========================================================================%
% 18.07.2021 By Amir Sarig                                                %
% - Create a matrix variable of flight directio in each frame, while      %
%   trial's serial number and wind speed are recorded.                    %
% - Create veriable of each trial angles's mean and std.                  %
% - Create vector of just the wind speeds in the data.                    %
% - Calculate maximal Vxy speed of insect (90% highest value from all     %
%   trial's frames before interpulation).                                 %
% - The function is called from the codes:                                %
%   'direction_speed_heatmap_n_contourmap', 'flight_direction_wind',      %
%   'plot_mean_H_speed'.                                                  %
% - Input is data file of the insect created by the code 'extract_data',  %
%   insect number, whether yes/no wasp data, whether yes/no interpolatio, %
%   and max_trial_length for interpolation                                %
% - The code use the functions velocity                                   %
%                                                                         %
%=========================================================================%
%% recieve information and set initial setting
function [frames_wind_speed, frames_trial_number, wind_speeds, V_export, horizontal_angle_logger, vertical_angle_logger, angles_mean_var, frames_wind_category, max_speed] = func_calc_ang_n_speed (data,insect,wasp,interpolation,max_trial_length)
addpath('D:\GalR10\Desktop\Sapir\Codes') %load 'velocity' function
r=size(data,2); %recieve amount of rows
ind=1; %set inital index number for output matrix
temp={data(:).wind}; %extract all trial's wind speeds
wind_speeds=unique(cell2mat(temp)); %record each wind speed once
%% calculate and store
for i=1:r %repeat once for each trial
    wind=data(i).wind; %recieve trial's wind speed
    trial=str2double(strcat(num2str(insect),'.',num2str(i,'%02d'))); %create unique name to each trial
    if any(data(i).wind==wind_speeds((round(length(wind_speeds)/2)+1):end)) %divid wind speeds into 3 categories
        wind_category=2; %storng wind
    elseif any(data(i).wind==wind_speeds(2:round(length(wind_speeds)/2)))
        wind_category=1; %low wind
    else
        wind_category=0; %no wind
    end
    xyz=data(i).filtered_coordinates; %extract 3D trajectory coordinats
    if wasp
        V(:,1:3) = (velocity(xyz(:,1:3),5000)./100); %wasps were recorded at 5000 Hz with cm calibration
        V(:,4)=V(:,1)+abs(wind); %correction to aerial flight speed in x axis. wasp were ditigized with wind direction to negative X axis
    else
        V(:,1:3) = velocity(xyz(:,1:3),2000); %whitefly, thrips & beetles were recorded at 2000 Hz with m calibration
        V(:,4)=V(:,1)-abs(wind); %correction to aerial flight speed in x axis. Sapir & Suzan ditigized with wind direction to positive X axis
        V(:,1)=V(:,1).*(-1); %define upwind flight as possitive
        V(:,4)=V(:,4).*(-1); %define upwind flight as possitive
    end
    V=V(7:(end-6),:); %data is between lines 7 till (end-6) because velocity is calculated wrong at start and end of the data 
    frames=length(V); %unmanipulated trial length
    Vxy_unmanipulated(ind:(ind+frames-1),:)=[repmat(wind,frames,1), sqrt((V(:,4).^2)+(V(:,2).^2))]; %record trial's unmanipulated Vxy and wind speed in each frame in an accumaltive vector, one trail after the previous trial
    angles_mean_var.horizontal(i,:) = [insect, data(i).wind, wind_category, trial, mean(abs(atan2d(V(:,2),V(:,4)))), var(abs(atan2d(V(:,2),V(:,4))))]; %calc. & store trial's mean & SD of abs unmanipulated aerial horizontal angle
    angles_mean_var.vertical(i,:) = [insect, data(i).wind, wind_category, trial, mean(atan2d(V(:,3),sqrt((V(:,4).^2)+(V(:,2).^2)))), var(atan2d(V(:,3),sqrt((V(:,4).^2)+(V(:,2).^2))))]; %calc. & store trial's mean & SD of abs unmanipulated aerial vertical angle
    %convert horizontal data to table with headers
    abs_horizontal_angles_mean_var = array2table(angles_mean_var.horizontal,'VariableNames',{'insect','wind_speed','wind_category','trial','mean_abs_direction','var_abs_direction'});
    if interpolation %interpulation in order to strech to the value of 'max_trial_length' (if user chose to interpulate)
        V=V';
        [r,rr] = size(V);
        t = (1./rr:1./rr:1); %X values (breakpoints) with data (Y value) 
        for k=1:r
            cs(k)=spline(t,[V(k,1) V(k,:) V(k,end)]); % piecewise polynomial form of the cubic spline interpolant of data for later use with the first and last value in data are used as the endslopes for the cubic spline.
            V_new(k,:) = ppval(cs(k),1./max_trial_length:1./max_trial_length:1); %Spline Interpolation with Specified Endpoint Slopes
        end
        V=V';
    end
    frames=length(V(:,2)); %manipulated trial length
    V_export(ind:(ind+frames-1),:)=V(:,:); %record trial's speed in an accumaltive vector, after the previous trial's speed
    frames_wind_speed(ind:(ind+frames-1))=repmat(data(i).wind,frames,1); %record trial's wind speed
    frames_trial_number(ind:(ind+frames-1))=repmat(trial,frames,1); %record trial's serial number
    horizontal_angle = abs(atan2d(V(:,2),V(:,4))); %calculate trial's abs aerial Horizontal_angle
    %% corection to circular data, Gal said it isn't needed
    %circmean = radtodeg(sum(exp(1i*degtorad(horizontal_angle))));
    %or
    %circmean = rad2deg(atan2(mean(sind(angledata_deg),2),mean(cosd(angledata_deg),2)));
    %angles_mean_var.horizontal(i,:) = [insect, data(i).wind, wind_category, trial, circmean, std(horizontal_angle)];
    %%
    horizontal_angle_logger(ind:(ind+frames-1))= horizontal_angle;%record trial's aerial Horizontal_angles
    vertical_angle = atan2d(V(:,3),sqrt((V(:,4).^2)+(V(:,2).^2))); %calculate trial's aerial Vertical_angle
    vertical_angle_logger(ind:(ind+frames-1))= vertical_angle; %record trial's aerial Vertical_angles
    frames_wind_category(ind:(ind+frames-1))=repmat(wind_category,frames,1); %record trial's wind category
    ind=ind+frames; %update the entery row for next iteration's data
    clear V xyz %clear variables that will be used again in the next iteration
end
%% calc maximal speed of insect
max_speed(1)=prctile(Vxy_unmanipulated(:,2),90); %find the insect's 90% highest speed. Set it as 'max speed' and store it
%find the wind speed in which occur the max_speed.
%Matlab can't find non-integer value due to floating-point roundoff error
roundoff_error=0.01; %set intial low roundoff. If roundoff is too high - there is an error
while length(max_speed)==1 %while wind speed wasn't found
    roundoff_error=roundoff_error/10; %increase roundoff
    if length(Vxy_unmanipulated(((abs(Vxy_unmanipulated(:,2)-max_speed(1)))<roundoff_error),1))==1 %if only one frame was found
        max_speed(2)=Vxy_unmanipulated(((abs(Vxy_unmanipulated(:,2)-max_speed(1)))<roundoff_error),1); %it's the insect's maximal speed, store it's wind speed
    end %otherwise there are too many frames that fit the quarry
end
end