function [ ] = ipso( varargin )
%IPSO (ISEA PLOT STYLE OFFICE)
%dings
% Export your figure for Office use.
%   Inputs:
%   'FigureFormat' [ ] %Erstmal einen
%   'ColorStyle' [ ] %Erstmal einen
%   'FigureHandle' [ ] %ohne Auswahl gfc
%
% V0.1 initial implementation for MATLAB 2016a (pde, djo)
% V0.2 added some features (djo)
%
%
% %standard linestyles for same nameing
% style.linestyle.solid='-';
% style.linestyle.dashed='--';
% style.linestyle.dotted=':';
% style.linestyle.dashdot='-.';
%
% ToDo:
% Achsen bis maximale Größe Fenster
%
%
%
%

%% falsche Version abfangen
matlab_version = version('-release');
if str2double(matlab_version(1:end-1))<2016
    error('Nicht unterstützte Matlab-Version. Bitte Matlab ab 2016a verwenden.');
end

%% input evaluation
try
    if  max(strcmp(varargin,'FigureFormat')) %get Value for FigureFormat
        index_FigureFormat=find(strcmp(varargin,'FigureFormat')); %get position in input argument
        FigureFormat=varargin{index_FigureFormat+1};
    else
        FigureFormat='pp_big_12x7'; % default value
    end
    
    if  max(strcmp(varargin,'ColorStyle')) %get Value for ColorStyle
        index_ColorStyle=find(strcmp(varargin,'ColorStyle')); %get position in input argument
        ColorStyle=varargin{index_ColorStyle+1};
    else
        ColorStyle='standard_colors'; % default value
    end
    
    if  max(strcmp(varargin,'FigureHandle')) %get Value for FigureHandle
        index_FigureHandle = find(strcmp(varargin,'FigureHandle')); %get position in input argument
        FigureHandleName = varargin{index_FigureHandle+1};
        if strcmp(FigureHandleName,'open') %open gui to open figure
            [FigureHandleName, FigureHandlePath] = uigetfile({'*.fig'},'File Selector');
            FigureHandle = openfig([FigureHandlePath FigureHandleName]);
        elseif strcmp(class(FigureHandleName),'matlab.ui.Figure')
            FigureHandle=FigureHandleName;
            clear FigureHandleName %delete Handle to save Name
            FigureHandleName=FigureHandle.Name; %get name of figure from handle
        else
            FigureHandle = evalin('base',FigureHandleName); %load figure from base workspace
        end
    else
        FigureHandle = gcf; % default value
        FigureHandleName = 'Current Figure';
    end
    
    fprintf('\nStyle input complete.\nUsing folowing parameters:\nFigure Format:  %s\nColor Style:    %s\nFigure Handle:  %s\n',...
        FigureFormat,ColorStyle,FigureHandleName); %kein Fan von Ausgaben
        

    %% Add Paths
    addpath(genpath('ISEA_plotstyle_core')); %add folder with subfolders
    
    %% FigureFormat
    ISEA_FigureFormat(FigureFormat, FigureHandle)
    
    %% ColorStyle
    if strcmp(ColorStyle,'none')
    else
    ISEA_ColorStyle(ColorStyle, FigureHandle)
    end
    
catch err
    disp(err);
    error('invalid inputs');
end



end


