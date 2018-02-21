%% List materials type
function pilistmaterial(thisR)
materials =thisR.materials;
for i =1:length(materials)
list{i} = sprintf('%d, %s:[ %s ] \n', i, materials(i).name,materials(i).string);
fprintf('%s',list{i});
end
end