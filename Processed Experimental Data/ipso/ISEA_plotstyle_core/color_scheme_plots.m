function [ color_output ] = color_scheme_plots( num_line, total_num_lines )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% addpath(genpath('IPSO\ISEA_plotstyle_core'));
colors_RWTH;


start_color=[colorsRWTH.Blau];
end_color=[colorsRWTH.Rot];
if total_num_lines<20
    diff_color=end_color-start_color;
    color_output=start_color+(num_line/total_num_lines)*diff_color;
elseif total_num_lines<40
    mid_color1=[colorsRWTH.Gruen];
    num_lines_per_section=floor(total_num_lines/2);
    num_lines_1=total_num_lines-num_lines_per_section;
    
    if num_line<num_lines_1
        diff_color=mid_color1-start_color;
        color_output=start_color+((2*num_line)/total_num_lines)*diff_color;
    else
        diff_color=end_color-mid_color1;
        color_output=mid_color1+((2*(num_line-num_lines_1))/total_num_lines)*diff_color;
    end
    
else
    mid_color1=[colorsRWTH.Gruen];
    mid_color2=[colorsRWTH.Orange];
    num_lines_per_section=floor(total_num_lines/3);
    num_lines_1=total_num_lines-2*num_lines_per_section;
    num_lines_2=total_num_lines-num_lines_per_section;
    
    if num_line<num_lines_1
        diff_color=mid_color1-start_color;
        color_output=start_color+((3*num_line)/total_num_lines)*diff_color;
    elseif num_line<num_lines_2
        diff_color=mid_color2-mid_color1;
        color_output=mid_color1+((3*(num_line-num_lines_1))/total_num_lines)*diff_color;
    else
        diff_color=end_color-mid_color2;
        color_output=mid_color2+((3*(num_line-num_lines_2))/total_num_lines)*diff_color;
    end
    
end


end

