function [ ] = ISEA_FigureFormat( FigureFormat,FigureHandle )
%ISEA_FigureFormat Summary of this function goes here
%   Detailed explanation goes here
try
    % Figure
    %     eval(['set(gcf,' '''Units''' ',style.output.' style.output.selected '.UnitsFig);']);
    %     eval(['set(gcf,' '''Position''' ',style.output.' style.output.selected '.PositionFig);']);
    
    %% exception yy
    %     if strcmp(FigureFormat,'pp_big_12x7yy') %for plot with 2 y axes
    %         try
    %             ax(1).YColor='k';
    %             ax(2).YColor='k';
    %             ax(1).Units=style.output.pp_big_12x7yy.UnitsAxes;
    %             ax(2).Units=style.output.pp_big_12x7yy.UnitsAxes;
    %             ax(1).Position=style.output.pp_big_12x7yy.PositionAxes;
    %             ax(2).Position=style.output.pp_big_12x7yy.PositionAxes;
    %             ax(1).LineWidth=style.output.pp_big_12x7yy.LineWidth;
    %             ax(2).LineWidth=style.output.pp_big_12x7yy.LineWidth;
    %             ax(1).FontName=style.output.pp_big_12x7yy.FontName;
    %             ax(2).FontName=style.output.pp_big_12x7yy.FontName;
    %             ax(1).FontSize=style.output.pp_big_12x7yy.FontSize;
    %             ax(2).FontSize=style.output.pp_big_12x7yy.FontSize;
    %             ax(1).XMinorTick=style.output.pp_big_12x7yy.XMinorTick;
    %             ax(2).XMinorTick=style.output.pp_big_12x7yy.XMinorTick;
    %             ax(1).YMinorTick=style.output.pp_big_12x7yy.YMinorTick;
    %             ax(2).YMinorTick=style.output.pp_big_12x7yy.YMinorTick;
    %
    %
    %         catch err
    %             disp(err.message)
    %         end
    %
    %     elseif strcmp(FigureFormat,'wd_big_12x7yy') %for plot with 2 y axes
    %                 try
    %             ax(1).YColor='k';
    %             ax(2).YColor='k';
    %             ax(1).Units=style.output.wd_big_12x7yy.UnitsAxes;
    %             ax(2).Units=style.output.wd_big_12x7yy.UnitsAxes;
    %             ax(1).Position=style.output.wd_big_12x7yy.PositionAxes;
    %             ax(2).Position=style.output.wd_big_12x7yy.PositionAxes;
    %             ax(1).LineWidth=style.output.wd_big_12x7yy.LineWidth;
    %             ax(2).LineWidth=style.output.wd_big_12x7yy.LineWidth;
    %             ax(1).FontName=style.output.wd_big_12x7yy.FontName;
    %             ax(2).FontName=style.output.wd_big_12x7yy.FontName;
    %             ax(1).FontSize=style.output.wd_big_12x7yy.FontSize;
    %             ax(2).FontSize=style.output.wd_big_12x7yy.FontSize;
    %             ax(1).XMinorTick=style.output.wd_big_12x7yy.XMinorTick;
    %             ax(2).XMinorTick=style.output.wd_big_12x7yy.XMinorTick;
    %             ax(1).YMinorTick=style.output.wd_big_12x7yy.YMinorTick;
    %             ax(2).YMinorTick=style.output.wd_big_12x7yy.YMinorTick;
    %
    %
    %         catch err
    %             disp(err.message)
    %         end
    
    %% Load selected Parameters
    eval(FigureFormat);

    %% Figure level
    
    % Check for number and type of Children
    numAxes=0;
    numLegend=0;
    for nbd=1:size(FigureHandle.Children,1)
        if strcmp(class(FigureHandle.Children(nbd)),'matlab.graphics.illustration.Legend') %check if Legend object
            numLegend=numLegend+1;
            LegendCell{numLegend}=FigureHandle.Children(nbd);
        elseif strcmp(class(FigureHandle.Children(nbd)),'matlab.graphics.axis.Axes') % check if Axes object
            numAxes=numAxes+1;
            AxesCell{numAxes}=FigureHandle.Children(nbd);
        end
    end
    clear nbd
    
    FigureHandle.Units = FigureFormatValues.UnitsFig;
    
    % Get position with size
    Screen = groot; %get Screensize
    Screen.Units = 'centimeters'; %change to centimeters
    FigureHandle.Position=[(Screen.ScreenSize(3)- FigureFormatValues.SizeFig(1))/2 (Screen.ScreenSize(4)- FigureFormatValues.SizeFig(2))/2 FigureFormatValues.SizeFig(1) FigureFormatValues.SizeFig(2)]; %get in the middle of display
    
    FigureHandle.PaperUnits = 'centimeters'; %make changes to Paper
    FigureHandle.PaperPosition = [0 0 FigureHandle.Position(3) FigureHandle.Position(4)];
    FigureHandle.PaperPositionMode = 'manual';
    FigureHandle.PaperSize =[FigureHandle.Position(3) FigureHandle.Position(4)];
    
    % Set Figure Values
    
    %% Axes level
    
    % Set Axes Values
    for mvc=1:numAxes
        currentAxes=AxesCell{mvc};
        
        currentAxes.Units =         FigureFormatValues.UnitsAxes;
        currentAxes.Position =      FigureFormatValues.PositionAxes;
        currentAxes.LineWidth =     FigureFormatValues.LineWidth;
        currentAxes.FontName =      FigureFormatValues.FontName;
        currentAxes.FontSize =      FigureFormatValues.FontSize;
        currentAxes.XMinorTick =    FigureFormatValues.XMinorTick;
        currentAxes.YMinorTick =    FigureFormatValues.YMinorTick;
        
        set(allchild(currentAxes),'LineWidth', currentAxes.LineWidth)
        
    end
    
    %% Legend level
    for mvc=1:numLegend
        currentLegend = LegendCell{mvc};
        
        currentLegend.FontSize = FigureFormatValues.LegendFontSize;
        currentLegend.Location = FigureFormatValues.LegendLocation;
    end
    
catch err
    disp(['Error in ISEA_FigureFormat: ' err.message ' Is style.output.selected defined?']);
end

end

