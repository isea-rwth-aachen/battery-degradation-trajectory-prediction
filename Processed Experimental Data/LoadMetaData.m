function [metaDataCell] = LoadMetaData(DataEvalPath,varargin)

DataFolderList=dir(DataEvalPath);

DataFolderList(1:2)=[];
DataFolderList = DataFolderList(~cellfun('isempty', {DataFolderList.date}));
DataFolderList = DataFolderList([DataFolderList.isdir]);
if ~isempty(varargin)
    %if excel avail, look for cyc or cal data
    if isfile([DataEvalPath '\_Projectlog.xlsx'])
    dataxls = readtable([DataEvalPath '\_Projectlog.xlsx']);    
    DataFolderList = DataFolderList(cellfun(@(x) contains(x,varargin{1}) ,dataxls.Aging));
    else
       disp('_Projectlog.xlsx is missing')
    end
end

metaDataCell=cell(length(DataFolderList),1);

for ii=1:length(DataFolderList)
    SubfolderList=dir([DataFolderList(ii).folder '\' DataFolderList(ii).name]);
    if max(cellfun(@(x) strcmp(x,'metadata.mat'), {SubfolderList.name}))
        metaDataCell{ii,1}=load([DataFolderList(ii).folder '\' DataFolderList(ii).name '\metadata.mat']);
    end
end

end