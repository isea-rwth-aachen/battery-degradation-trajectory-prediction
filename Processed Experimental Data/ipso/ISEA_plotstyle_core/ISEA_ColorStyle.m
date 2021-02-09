function [ ] = ISEA_ColorStyle( ColorStyle,FigureHandle )
%ISEA_FigureFormat Summary of this function goes here
%   Detailed explanation goes here

if strcmp(ColorStyle,'None') || strcmp(ColorStyle,'none')
    return
end

try
    %% Load Style Parameters
    
    
    eval(ColorStyle)
    
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
    
    % Set Figure Values
    
    %% Axes level
    
    % Set Axes Values
    % ColorStyleValues
    for mvc=1:numAxes
        currentAxes=AxesCell{mvc};
        
        if length(currentAxes.YAxis)==2 % 2 Y-Achsen
            yyaxis left
            currentAxes.YAxis(1).Color = ColorStyleValues.ColorOrderLeft(1,:);
            currentAxes_child_handle = currentAxes.Children;
            num_Ax_Children=size(currentAxes_child_handle,1);
            for i=1:length(currentAxes_child_handle) %12 % set definded Colors to ploted figure
                try
                    currentAxes_child_handle(num_Ax_Children+1-i).Color = ColorStyleValues.ColorOrderLeft(i,:); %allchild order FILO
                catch
                end
            end
            yyaxis right
            currentAxes.YAxis(2).Color = ColorStyleValues.ColorOrderRight(1,:);
            currentAxes_child_handle = currentAxes.Children;
            num_Ax_Children=size(currentAxes_child_handle,1);
            for i=1:length(currentAxes_child_handle) %12 % set definded Colors to ploted figure
                try
                    currentAxes_child_handle(num_Ax_Children+1-i).Color = ColorStyleValues.ColorOrderRight(i,:); %allchild order FILO
                catch
                end
            end
        elseif isfield(ColorStyleValues,'Gradient') % 1 Y-Achse mit Farbgradient
            currentAxes_child_handle=allchild(currentAxes);
            num_Ax_Children=size(currentAxes_child_handle,1);
            
            saturation = linspace(ColorStyleValues.Gradient.MaxSaturation,ColorStyleValues.Gradient.MinSaturation ,length(currentAxes_child_handle));
            for i=1:length(currentAxes_child_handle)  % set definded Colors to ploted figure
                colorHsv = ColorStyleValues.Gradient.BaseColorHsv;
                colorHsv(2) = saturation(i);
                colorRgb = hsv2rgb(colorHsv);
                currentAxes_child_handle(num_Ax_Children+1-i).Color = colorRgb; %allchild order FILO
            end
        else % 1 Y-Achse
            currentAxes_child_handle=allchild(currentAxes);
            num_Ax_Children=size(currentAxes_child_handle,1);
            
            % todo mehr Linien als Farben
            
            for i=1:length(currentAxes_child_handle) %12 % set definded Colors to ploted figure
                try
                    currentAxes_child_handle(num_Ax_Children+1-i).Color = ColorStyleValues.ColorOrder(i,:); %allchild order FILO
                catch
                end
            end
        end
        
    end
    
    %% Legend level
    
    
catch err
    disp(['Error in ColorStyle: ' err.message ' Is style.output.selected defined?']);
end

end

