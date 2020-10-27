function [name, vec] = piParseVector(txt)
% Parse vector in the string
%{
txt = 'Rot 90 -1 0 0';
[name, vec] = piParseVector(txt);
%}
%%
if iscell(txt)
    % Loop through all cell elements
    name = cell(1, numel(txt));
    vec = cell(1, numel(txt));
    
    for ii = 1:numel(txt)
        [name{ii}, vec{ii}] = piParseVector(txt{ii});
    end
elseif ischar(txt)
    % Just a string
    vecString = strsplit(txt);
    name = vecString{1};
    vec = str2double(vecString(2:end));
    vec(isnan(vec)) = [];
end
end