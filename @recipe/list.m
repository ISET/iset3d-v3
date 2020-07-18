function [names,lst] = list(obj)
% Show the directories in data/V3
%
% Synopsis
%   thisR.list
%
% Inputs
%  obj:  The recipe, but not needed 
%
% key/val options
%  N/A
%
% Outputs
%  names:
%  lst:
%
% See also
%   recipeSet, recipeGet

v3Dir = fullfile(piRootPath,'data','V3');
lst = dir(v3Dir);
names = cell(numel(lst)-2,1);
kk = 1;
for ii = 1:numel(lst)
    if isequal(lst(ii).name(1),'.')
        % fprintf('skipping %s\n',lst(ii).name);
        continue;
    else
        names{kk} = lst(ii).name;
        kk = kk + 1;
    end 
end

%% Remove empty cells, arise from other dot-files, like .DS_Store
vFunc = @(x)(~isempty(x));
e = cellfun(vFunc,names);
names = names(e);
lst = lst(e);

fprintf('\nPBRT directories in your iset3d/data/V3\n');
fprintf('----------------------------------------\n');

for ii=1:numel(names)
    fprintf('%02d - %s\n',ii,names{ii});
end
fprintf('\n');
fprintf('Use:  "thisR = piRecipeDefault(nameFromList)" \n or   "theScene = sceneEye(nameFromList)" to read a recipe.\n');
end
