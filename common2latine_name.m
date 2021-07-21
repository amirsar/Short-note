function figure_name = common2latine_name(insect_name)
 
switch lower(insect_name)
    case 'wasp'
        figure_name='\itE. mundus\rm';
    case 'bemisia'
        figure_name='\itB. tabaci\rm';
    case 'thrips'
        figure_name='\itG. ficorum\rm';
end
end
