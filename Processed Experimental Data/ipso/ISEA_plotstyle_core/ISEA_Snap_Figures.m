function [ Position ] = ISEA_Snap_Figures( postion_of_plot,total_plot_number, num_screens, middle_monitor)
%ISEA_FigureFormat Summary of this function goes here
%   Detailed explanation goes here

try
    if postion_of_plot>total_plot_number
        error('Position cannot be greater than total plot number')
    end
    plots_per_screen=total_plot_number/num_screens;
    
    
    if plots_per_screen<=1
        x_num=1;
        y_num=1;
        plots_per_screen=1;
    elseif  plots_per_screen<=2
        x_num=2;
        y_num=1;
        plots_per_screen=2;
    elseif  plots_per_screen<=6
        x_num=3;
        y_num=2;
        plots_per_screen=6;
    elseif  plots_per_screen<=9
        x_num=3;
        y_num=3;
        plots_per_screen=9;
    elseif  plots_per_screen<=12
        x_num=4;
        y_num=3;
        plots_per_screen=12;
    elseif  plots_per_screen<=16
        x_num=4;
        y_num=4;
        plots_per_screen=16;
    elseif  plots_per_screen<=20
        x_num=5;
        y_num=4;
        plots_per_screen=20;
    elseif  plots_per_screen<=144
        x_num=16;
        y_num=9;
        plots_per_screen=144;
    else
        error('Too many plots')
    end
    
%     plots_per_screen=total_plot_number/num_screens;
    
%     9px window

    current_Unit_groot=get(groot,'Units');
    set(groot,'Units','pixels'); 
    Screen = groot; %get Screensize
    
    
    screen_num=ceil(postion_of_plot/plots_per_screen); % get on which screen plot should be
    position_on_screen=postion_of_plot-(plots_per_screen*(screen_num-1));
    row= ceil(position_on_screen/x_num);
%     collum= mod(position_on_screen,x_num);
    collum= position_on_screen- (row-1)*x_num;
    
    
    x_Screen=Screen.ScreenSize(3);
    y_Screen=Screen.ScreenSize(4)-40; %40px offset taskbar

    

    windowsize_x=(x_Screen)/x_num;
    windowsize_y=(y_Screen)/y_num;
    
    plotsize_x=windowsize_x -2*8; %     9px window
    plotsize_y=windowsize_y - 76 -2*8 ;%     76px offset menu
    
    if middle_monitor==2
        offset_x=-x_Screen;
    else
        offset_x=0;
    end
    x_Position=windowsize_x*(collum-1)+x_Screen*(screen_num-1)+offset_x;
    y_Position=(y_Screen - windowsize_y*row);
    
    x_plot_Position= x_Position +1 +8;% (2*collum-1)*9;
    y_plot_Position= y_Position +1 +8 +40;
    
    %      Position [left bottom width height]
    Position=[ x_plot_Position y_plot_Position plotsize_x plotsize_y];
    
    set(groot,'Units',current_Unit_groot);
    
catch err
    disp(['Error in ISEA_Snap_Figures: ' err.message]);
end

end

