function val = piAssetGet(tree, id, param)
%%
% Get the value(s) of a node parameter(s) in the asset tree. If you want to
% get more than one parameter values, pass param as a cell array.
% 
%% 
thisNode = tree.get(id);

if ~isfield(thisNode, param)
    if ischar(thisNode) % In the case of a string
        name = thisNode;
    else
        name = thisNode.name;
    end
    warning('Node %s does not have field: %s. Empty return', name, param)
    val = [];
else
    if ischar(param)
        val = thisNode.(param);
    elseif iscell(param)
        val = cell(1, numel(param));
        for ii = 1:numel(param)
            val{ii} = piAssetGet(tree, id, param{ii});
        end
    end
        
end
end