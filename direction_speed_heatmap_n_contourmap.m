%=========================================================================%
% 15.07.2021 By Amir Sarig                                                %
% * Work on Matlab 2020+                                                  %
% Input -                                                                 %
% - Data files of insect flight, in struct variable. Created by the code: % 
%   extract_data_from_MSc_data.m                                          %
% Output:                                                                 %
% - Heatmap of abs direction (Y) Vs. speed/Max speed (X), tiled in wind   %
%   category (Y) Vs. insect (X)                                           %
%   * works only from Matlab 2017a.                                       %
% - Filled 2D contour plot. Similar description as above.                 %
%   * works only from Matlab 2020.                                        %
% External functions in use:                                              %
% - func_calc_ang_n_speed                                                 %
% - velocity (inside of the above)                                        %
% - common2latine_name                                                    %
%=========================================================================%

variablesInCurrentWorkspace = who; %recieve names of variables in current workspace
h=helpdlg('Manually load data files (type: struct) to workspace.\n\nMake sure that workspace contain only the data files.');
uiwait(h)
h=helpdlg('Images should be in the active directory. They should be in the same name as givven to the insects, and ''tif'' type.');
uiwait(h)
resolution=10; %set how many row and columns will be in each combination
interpolation=input('Perform interpolation to maximal trial length? (0-No, 1-Yes)\n'); %user enter choice regarding interpolation
winds_name={'No wind','Low wind','High wind'};
%% works only from Matlab 2020. Prepare tiled layout for contour maps
figure
t = tiledlayout(length(variablesInCurrentWorkspace),(3+1),'TileSpacing','Compact','Padding','Compact');
title=sprintf('Flight direction (degrees)\nLeft - Upwind (0), Right - Downwind (180)');
xlabel(t,title, 'FontSize', 24)
title=sprintf('Insect''s relative flight speed (%%)\nDown - Min, Up - Max');
ylabel(t,title, 'FontSize', 24)

%% Recieving data files names, and calculate max. trial length between all data variables
max_trial_length=0;
for insect=1:length(variablesInCurrentWorkspace) %repeat for each insect
    insects(insect).name=input('''Wasp'' / ''Bemisia'' / ''Thrips''\n'); %user enter insect name
    data=eval(sprintf('%s_data',lower(insects(insect).name))); %choose the data variable from workspace according to user selection
    for j=1:size(data,2) %for each trial in the data variable
        if max_trial_length<size(data(j).filtered_coordinates,1) %if trial length is longer then all previous
            max_trial_length=size(data(j).filtered_coordinates,1); %record length of maximal trial (from all insects)
        end
    end
end

%% calculate value of each cell
for insect=1:length(variablesInCurrentWorkspace) %repeat for each insect

    data=eval(sprintf('%s_data',lower(insects(insect).name))); %choose the data variable from workspace according to user selection
    wasp=strcmp('wasp',lower(insects(insect).name)); %wasp data is from my M.Sc and is different
    [frames_wind_speed, frames_trial_number, wind_speeds, V, horizontal_angle, vertical_angle, angles_mean_var, frames_wind_category, max_speed] = func_calc_ang_n_speed(data,insect,wasp,interpolation,max_trial_length); %Create a matrix variable of flight direction in each frame, in addition extract wind speeds list, and vertical speed
    clear vertical_angle angles_mean_var frames_wind_category data %variables that the above function create for another code
    Vxy=sqrt((V(:,4).^2)+(V(:,2).^2)); %calculate horizontal flight speed
    trials=unique(frames_trial_number); %acquire trial's names
%     for trial=1:length(trials)
%         if max_speed(insect) < prctile(Vxy(frames_trial_number==trials(trial)),90) %find the 90% highest speed. Set it as 'max speed'
%             max_speed(insect) = prctile(Vxy(frames_trial_number==trials(trial)),90);
%         end
%     end
    R_Vxy=Vxy./max_speed(1); %calculate all speed as relative to the 'max speed'
    insects_max_speed(insect,:)=max_speed; %store insects max speed
    wind_speed(1,:)=frames_wind_speed(:)==0; %extract row numbers of frames at wind speed 0
    wind_speed(2,:)=ismember(frames_wind_speed(:),wind_speeds(2:round(length(wind_speeds)/2))); %extract row numbers of frames at low wind speed
    if wasp
        wind_speed(3,:)=ismember(frames_wind_speed(:),wind_speeds((round(length(wind_speeds)/2)+1):(end-1))); %extract row numbers of frames at max wind speed except 0.51 m/s (Gal's decision on July 21')
    else
        wind_speed(3,:)=ismember(frames_wind_speed(:),wind_speeds((round(length(wind_speeds)/2)+1):end)); %extract row numbers of frames at max wind speed
    end
    clear wasp frames_wind_speed frames_trial_number wind_speeds V Vxy trials
    for wind=1:size(wind_speed,1) %for each wind category
        current_wind_angles=horizontal_angle(wind_speed(wind,:));
        for speed=(10/(resolution-1)):(10/(resolution-1)):(10+(10/(resolution-1))) %find indices of frames of each 1/'resolution' speed
            if speed>10
                current_speed=find(R_Vxy(wind_speed(wind,:))>=((speed/10)-((10/(resolution-1))/10))); %find frame indices of hieghest 10% speed
            else
                current_speed=find(R_Vxy(wind_speed(wind,:))<(speed/10) & R_Vxy(wind_speed(wind,:))>=((speed/10)-((10/(resolution-1))/10))); 
            end
            for direction=(180/resolution):(180/resolution):180 %find indices of frames of each 1/'resolution' direction among the frames found above, and count their amount
                cell_value((((insect-1)*(resolution+1))+round(speed/(10/(resolution-1)))),(((wind-1)*(resolution+1))+round(direction/(180/resolution))))=length(find(current_wind_angles(current_speed)<direction & current_wind_angles(current_speed)>=(direction-(180/resolution))));
            end
            clear current_speed
        end
        clear current_wind_angles 
        %% Plot contour map
        z=cell_value(((insect-1)*(resolution+1))+1:((insect-1)*(resolution+1))+resolution,((wind-1)*(resolution+1))+1:((wind-1)*(resolution+1))+resolution);
        nexttile
        max_z=max(max(z)); %use twice 'max' func. because when using 'max' on a matrix it returns a vector of the max. value in each column
%         levels=0; n=0; %define that cells with count zero will be included in the following contourf
%         while (2^n)<max_z %store levels for contourf that increase as (2^n) until max_z
%             levels(length(levels)+1)=2^n;
%             n=n+1;
%         end
        colormap(jet)        
%         contourf(1:resolution,1:resolution,z,levels) %plot contours
        contourf(1:resolution,1:resolution,(z/max_z)*100) %plot contours
        for i=1:resolution %prepare small labels. *Will work only in simmetric heatmap (equal number of rows and columns)
            CustomXLabels(i)={''};
            CustomYLabels(i)={''};
        end
        %write insect-wind labels. position fit large window presetation
        if wind==1
            CustomYLabels(3)={common2latine_name(insects(insect).name)}; %write insect name
            if insect==3
                CustomXLabels(3)={char(winds_name(wind))}; %write wind category
            end
        elseif insect==3
            CustomXLabels(3)={char(winds_name(wind))}; %write wind category
        end
        set(gca,'YTickLabel',CustomYLabels,'YTickLabelRotation',30, 'FontSize', 22) %write y axis
        set(gca,'XTickLabel',CustomXLabels,'XTickLabelRotation',30, 'FontSize', 22) %write x axis
    end
    %insert insect image
    nexttile
    im=imread(lower(insects(insect).name),'tif');
    imshow(im(:,:,1:3));
    %
    clear wind_speed horizontal_angle R_Vxy z im
end

%% works only from Matlab 2017a. Plot Heatmap
%fill NaN in prepared in advance empty rows and columns, it will use as borders between the different combinations
for i=1:(insect-1)
    cell_value((resolution+1)*i,:)=nan(size(cell_value,1),1);
    cell_value(:,(resolution+1)*i)=nan(1,size(cell_value,2));
end
figure
h=heatmap(cell_value,'Colormap', jet); 
j=1;
for i=1:size(cell_value,1) %prepare heatmap small labels. *Will work only in simmetric heatmap (equal number of rows and columns)
    switch i
        case (((size(cell_value,1)-2)/insect)/2)+(resolution*(j-1))+j-1 %the middle of bulk number j
            CustomXLabels(i)={winds_name(j)};
            CustomYLabels(i)={common2latine_name(insects(j).name)};
            j=j+1;
        otherwise
            CustomXLabels(i)={''};
            CustomYLabels(i)={''};
    end
end
h.XDisplayLabels = CustomXLabels;
h.YDisplayLabels = CustomYLabels;
s = struct(h);
s.XAxis.TickLabelRotation=30;
s.YAxis.TickLabelRotation=30;
title=sprintf('Flight direction (degrees)\nLeft - Upwind (0), Right - Downwind (180)');
xlabel(title); % X axis are columns
title=sprintf('Insect''s relative flight speed (%%)\nDown - Max, Up - Min');
ylabel(title); % Y axis are rows
for i=1:insect
    fprintf('Max. speed of %s is %1.4f m/s while flying in wind of %1.2f.\n',insects(i).name,insects_max_speed(i,1),insects_max_speed(i,2));
end
%%create contourf with colorbar of range 0 till 100. Will be used to paste
%%the colorbar on the figure of the contourf data
figure
colormap(jet)
contourf(1:resolution,1:resolution,[0:9;11:20;21:30;31:40;41:50;51:60;61:70;71:80;81:90;91:100]) %plot contours
colorbar('northoutside')