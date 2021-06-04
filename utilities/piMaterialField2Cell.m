function thisR = piMaterialField2Cell(thisR)
% Converts the list field in V1 recipe to to a cell field for V2
% Further changes are necessary in 

%%
tmp = struct2cell(thisR.materials.list);

for ii=1:numel(tmp)   
    tmp{ii} = ieStructRemoveEmptyField(tmp{ii});
    materialType = tmp{ii}.string;
    tmp{ii} = rmfield(tmp{ii}, 'string');
    tmp{ii}.type = materialType;
end

thisR.materials.list = tmp;

end