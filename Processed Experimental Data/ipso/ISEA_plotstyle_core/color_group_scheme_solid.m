function [ color_output ] = color_group_scheme_solid( num_line, groupVector )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% addpath(genpath('IPSO\ISEA_plotstyle_core'));
colors_RWTH;

ColorDifference=0.2;
Transparency=1;
diff_color=ColorDifference*ones(1,3);

if groupVector(num_line)==0 %group 0 is invisible
    color_output=[0 0 0 0];
    return
end

total_num_lines=length(groupVector);

if all(groupVector)
    num_Colors=length(unique(groupVector));
    ColorIndex=find(groupVector(num_line)==unique(groupVector));
else
    num_Colors=length(unique(groupVector))-1;
    ColorIndex=find(groupVector(num_line)==unique(groupVector))-1;
end

% if num_Colors>5
%     error('Only 5 groups implemented in color_group_scheme')
% end

% groupBaseColor={colorsRWTH.Blau, colorsRWTH.Gruen, colorsRWTH.Rot, colorsRWTH.Orange, colorsRWTH.Magenta};
group_colors_solid;
% ColorIndex=find(groupVector(num_line)==unique(groupVector));

ColorGroup=find(ColorIndex==groupVector);

num_lines_group=length(ColorGroup);

num_line_group=find(num_line==ColorGroup);

BaseColor=ColorStyleValues.ColorOrder(ColorIndex,:);

minIndex=find(BaseColor<(ColorDifference/2));
maxIndex=find(BaseColor>(1-(ColorDifference/2)));
BaseColor=BaseColor-(diff_color./2);

if ~isempty(minIndex)
    BaseColor(minIndex)=0;    
end

if ~isempty(maxIndex)
    BaseColor(maxIndex)=1-ColorDifference;    
end



color_output=[(BaseColor+(num_line_group/num_lines_group)*diff_color),Transparency];


end

