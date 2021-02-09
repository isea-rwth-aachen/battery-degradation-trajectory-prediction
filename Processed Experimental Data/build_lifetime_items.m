function [lifetime] = build_lifetime_items(data_path,varargin)

if data_path(end)=='\'
    data_path(end)=[];
end

if ~isempty(varargin)
    if strcmp(varargin{1},'lean')
        loadLeanDataOnly=1;
    else
        loadLeanDataOnly=0;
    end
else
    loadLeanDataOnly=0;
end

names = dir(data_path);
names(ismember( {names.name}, {'.', '..'})) = [];

dir_names = names([names.isdir]);
if length(names) <= 4
    lifetime_vector =  load([names(1).folder '\lifetime']);
    lifetime = lifetime_vector.lifetime;
    return
end
clear names dir_flages

if size(dir_names,1)==0
    error('Path is empty')
end

for cell_output_counter = 1 : size(dir_names,1)
    path_cell = [] ;
    names = [];
    dir_flages = [];
    dir_names_cell = [];
    path_cell = [data_path '\' dir_names(cell_output_counter).name];
    names = dir(path_cell);
    names(ismember( {names.name}, {'.', '..'})) = [];
    dir_flages = [names.isdir];
    dir_names_cell = names(dir_flages);
    
    for testset_output_counter = 1 : size(dir_names_cell,1)
        path_testset = [];
        testset_names = [];
        path_testset = [path_cell '\' dir_names_cell(testset_output_counter).name];
        testset_names = dir(path_testset);
        testset_names = testset_names(3:end);
        
        for value_output_counter = 1 : size(testset_names,1)
            if ~any(strcmp(testset_names(value_output_counter).name,{'lean_data.mat'})) && loadLeanDataOnly
                continue
            end
            var_name = char(testset_names(value_output_counter).name);
            var_name = var_name(1:end-4);
            data_item = load([path_testset '\' (testset_names(value_output_counter).name)]);
            if strcmp(var_name,'lean_data')
                val_fieldnames = fieldnames(data_item);
                for val_fieldnames_counter = 1 : length(val_fieldnames)
                    lifetimeCell{cell_output_counter}.(char(dir_names(cell_output_counter).name)).(char(dir_names_cell(testset_output_counter).name)).(val_fieldnames{val_fieldnames_counter}) = data_item.(val_fieldnames{val_fieldnames_counter});
                end
            else
                lifetimeCell{cell_output_counter}.(char(dir_names(cell_output_counter).name)).(char(dir_names_cell(testset_output_counter).name)).(var_name) = data_item.(var_name);
            end
            
        end
    end
end

for CellCounter=1:size(lifetimeCell,2)
    if ~isempty(lifetimeCell{1,CellCounter})
        CellName=fieldnames(lifetimeCell{1,CellCounter});
        lifetime.(CellName{1})=orderfields(lifetimeCell{1,CellCounter}.(CellName{1}));
    end
end

lifetime=orderfields(lifetime);

end