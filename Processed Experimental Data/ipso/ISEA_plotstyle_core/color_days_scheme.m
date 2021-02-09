function [ color_output ] = color_days_scheme( day, total_days,num_colors )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% addpath(genpath('IPSO\ISEA_plotstyle_core'));
colors_RWTH;

if day< 0
    day=0;
end

if day > total_days
   day=total_days;
end
start_color=[colorsRWTH.Blau];
end_color=[colorsRWTH.Rot];
if num_colors==2
    diff_color=end_color-start_color;
    color_output=start_color+(day/total_days)*diff_color;
elseif num_colors==3
    mid_color1=[colorsRWTH.Gruen];
    num_lines_per_section=floor(total_days/2);
    num_lines_1=total_days-num_lines_per_section;
    
    if day<num_lines_1
        diff_color=mid_color1-start_color;
        color_output=start_color+((2*day)/total_days)*diff_color;
    else
        diff_color=end_color-mid_color1;
        color_output=mid_color1+((2*(day-num_lines_1))/total_days)*diff_color;
    end
    
else
    mid_color1=[colorsRWTH.Gruen];
    mid_color2=[colorsRWTH.Orange];
    num_lines_per_section=floor(total_days/3);
    num_lines_1=total_days-2*num_lines_per_section;
    num_lines_2=total_days-num_lines_per_section;
    
    if day<num_lines_1
        diff_color=mid_color1-start_color;
        color_output=start_color+((3*day)/total_days)*diff_color;
    elseif day<num_lines_2
        diff_color=mid_color2-mid_color1;
        color_output=mid_color1+((3*(day-num_lines_1))/total_days)*diff_color;
    else
        diff_color=end_color-mid_color2;
        color_output=mid_color2+((3*(day-num_lines_2))/total_days)*diff_color;
    end
    
end


end

