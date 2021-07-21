%=========================================================%
% 19.10.2020 By Amir Sarig                                %
% - Create 3 histogram figures of flight direction of     %
%   several insects, each figure is different wind speed. %
% - The code needs to be manually run as many times as    %
%   insects in the comparision.                           %
% - Input that should be manually loaded to Workspace is  %
%   data file of the insect that is renamed to 'data'.    %
% - The code use the functions velocity and calc_hor_ang. %
%=========================================================%

clearvars -except data count insects_name relativefreq
%% recieve data
insects_amount=input('How many insects species are in the study?   ');
count=input('Which iteration is it now?   ');
count=count+1;
insects_name(count).name=input('Insect name in the legend is:   ','s');
[frames_wind_speed, frames_trial_number, wind_speeds, V, horizontal_angle, vertical_angle] = calc_hor_ang (data); %Create a matrix variable of flight directio in each frame, in addition extract wind speeds list, and vertical speed
degrees=-180:20:180; %create vector of angles in order to bin and display the data

%% create figures
%figure(1)
range=frames_wind_speed(:)==0; %extract row numbers of frames at wind speed 0
[N,edges] = histcounts(horizontal_angle(range,3),degrees); %partitions flight direction values into 20 degrees bins, and returns the count in each bin
relativefreq(1,count,:) = (N/length(horizontal_angle(range,3)))*100; %calculate the relative frequency of each data range

%figure(2)
range=frames_wind_speed(:)==wind_speeds(round(length(wind_speeds)/2)); %extract row numbers of frames at low wind speed
[N,edges] = histcounts(horizontal_angle(range,3),degrees); %partitions flight direction values into 20 degrees bins, and returns the count in each bin
relativefreq(2,count,:) = (N/length(horizontal_angle(range,3)))*100; %calculate the relative frequency of each data range

%figure(3)
range=frames_wind_speed(:)==wind_speeds(end); %extract row numbers of frames at max wind speed
[N,edges] = histcounts(horizontal_angle(range,3),degrees); %partitions flight direction values into 20 degrees bins, and returns the count in each bin
relativefreq(3,count,:) = (N/length(horizontal_angle(range,3)))*100; %calculate the relative frequency of each data range

%% after all the data exists, create general annotations.
if count==insects_amount 
    for i=1:3 %repeat once for each wind category
        subplot(3,1,i)
        bar(degrees(2:end)-20/2, reshape(relativefreq(i,:,:),size(relativefreq,2),size(relativefreq,3))',1) %plot current wind category data. BAR function centers the bars it creates on the supplied x-data. So 'degrees' has been translated by half an interval so the extents of the bar width fall on the limits of the data ranges
        xlim([min(degrees) max(degrees)]) %define x axis limits
        set(gca, 'xtick', degrees, 'XTickLabelRotation', 45) %set x axis ticks to be as in 'degrees'
        legend({insects_name(:).name});
        xlabel('Angles (Degrees)');
        ylabel('Time (%)');
        if i==1
            t=sprintf('Flight direction without wind');
        elseif i==2
            t=sprintf('Flight direction at low wind speed');
        else
            t=sprintf('Flight direction at max wind speed');
        end
        title(t)
    end
    clear
end

 