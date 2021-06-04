function nLights = piLightPrint(thisR)
% Print list of lights in the recipe
%
% Synopsis
%   nLights = piLightPrint(thisR)
%
% See also
%   piMaterialPrint

nLights = thisR.get('n lights');

if nLights == 0
    disp('---------------------')
    disp('No lights in this recipe');
    disp('---------------------')
    return;
end

lightNames = thisR.get('light', 'names');
rows = cell(nLights,1);
names = rows;
types = rows;

fprintf('\nLights\n');
fprintf('-------------------------------\n');
for ii =1:numel(lightNames)
    rows{ii, :} = num2str(ii);
    names{ii,:} = lightNames{ii};
    types{ii,:} = thisR.lights{ii}.type;
end
T = table(categorical(names), categorical(types),'VariableNames',{'name','type'}, 'RowNames',rows);
disp(T);
fprintf('-------------------------------\n');

end
