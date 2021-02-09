function [XData,YData] = PlotDataField(XDataName,YDataName,Cells,lifetime)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   XDataName='Ah_cummulative','Remaining_Cap';

if ischar(Cells)
    Cellsstr=Cells;
    clear Cells
    Cells={Cellsstr;'EmptyString'};
end


CellsInLifetime=fieldnames(lifetime);
EvalCells=Cells(ismember(Cells,CellsInLifetime));


if sum(ismember(Cells,CellsInLifetime))==0
    disp('None of the cells can be found in lifetime')
end

if sum(~ismember(Cells,CellsInLifetime))>0
    if length(Cells(~ismember(Cells,CellsInLifetime)))==1 && ~strcmp(Cells{~ismember(Cells,CellsInLifetime)},'EmptyString')
        disp([Cells{~ismember(Cells,CellsInLifetime)} ' is/are not in lifetime'])
    end
end


YData=cell(1,length(EvalCells));
XData=cell(1,length(EvalCells));

for ii=1:length(EvalCells)
    YDataAvailCell=structfun(@(x) isfield(x,YDataName), lifetime.(EvalCells{ii}));
    YDataCell=struct2cell(structfun(@(x) getFieldFromName(x,YDataName), lifetime.(EvalCells{ii}),'UniformOutput' ,false));

%     YData{ii}=YDataCell(YDataAvailCell);
    
    if isempty(YDataCell(YDataAvailCell))
        warning(['No Data for ' EvalCells{ii} ' in field ' YDataName]);
        XData{ii}=[];
        continue
    end
    
    XDataAvailCell=structfun(@(x) isfield(x,XDataName), lifetime.(EvalCells{ii}));
    XDataCell=struct2cell(structfun(@(x) getFieldFromName(x,XDataName), lifetime.(EvalCells{ii}),'UniformOutput' ,false));
    
    if strcmp(XDataName,'AhEla')
        XDataCell=[XDataCell{:}];
        XDataCell(isnan(XDataCell))=0;
        XDataCell=cumsum(XDataCell);
    else
        XDataCell=[XDataCell{:}];
    end
    
    XData{ii}=XDataCell(and(XDataAvailCell,YDataAvailCell));
    if iscell(XData{ii})
        XData{ii}=XData{ii}{:};
    end
    
    YData{ii}=YDataCell(and(XDataAvailCell,YDataAvailCell));
    if max(cellfun(@length, YData{ii})) == 1
        YData{ii}=[YData{ii}{:}];
    end
end
end

function [data] = getFieldFromName(Datastruct,Fieldname)
if contains(Fieldname,'.')
    disp('More than one')
    try
        data=eval(['Datastruct.' Fieldname]);
    catch
        data=NaN(1);
    end
elseif isfield(Datastruct,Fieldname)
    data=Datastruct.(Fieldname);
else
    data=NaN(1);
end
end
