function piLightList(thisR)
disp('---------------------')
disp('*****Light Type******')
for ii = 1:numel(thisR.lights)
    fprintf('%d: name: %s     type: %s\n', ii,...
            thisR.lights{ii}.name,thisR.lights{ii}.type);
end
disp('*********************')
disp('---------------------')
end