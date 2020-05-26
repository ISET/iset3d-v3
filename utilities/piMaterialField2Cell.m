function thisR = piMaterialField2Cell(thisR)

%%
tmp = struct2cell(thisR.materials.list);

for ii=1:numel(tmp)
%     fNames = fieldnames(tmp{ii});
%     for ff=1:numel(fNames)
%         if isempty(tmp{ii}.(fNames{ff}))
%             tmp{ii} = rmfield(tmp{ii},fNames{ff});
%         end
%     end
    
    tmp{ii} = ieStructRemoveEmptyField(tmp{ii});
    stringType = tmp{ii}.string;
    tmp{ii} = rmfield(tmp{ii}, 'string');
    tmp{ii}.stringtype = stringType;
end

thisR.materials.list = tmp;

end