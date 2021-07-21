count=1;
for wind=1:3
    for insect=1:3
        for bin=1:18
            temp(count,:) = [insect, wind, bin, relativefreq(wind, insect, bin)];
            count=count+1;
        end
    end
end
relativefreq_table = array2table(temp,'VariableNames',{'insect', 'wind', 'bin', 'relativefreq'}); %insects: 1-wasp, 2-bemisisa, 3-thrips. winds: 1-no, 2-low, 3-high