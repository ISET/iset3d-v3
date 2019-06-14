function piAssetPrint(thisR)
% Print asset name with index number
fprintf('\n Assets List \n')
disp('--------------------')
if ~isempty(thisR.assets)
    for ii = 1:length(thisR.assets)
        fprintf('%d: %s. \n', ii, thisR.assets(ii).name);
    end
else
    error('No assets found.');
end
disp('--------------------')
end