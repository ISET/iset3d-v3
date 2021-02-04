function [tree,container] = struct2tree(S,h)
%STRUCT2TREE renders the given structure as a uitree object
%
% [TREE,CONTAINER] = STRUCT2TREE(S) returns the uitree object and its
% container object rendered in the current figure. 
%
% ... STRUCT2TREE(S,H) renders the uitree in the given container.
%Example
%
% [tree,container] = struct2tree(S,gcf);
% set(tree,'NodeSelectedCallback',@myNodeSelectedCallback)
% set(container,'units','normalized','position',[0 0 1 1])
if nargin==1,h=gcf;end

if isscalar(S)
    root = struct2node(S);
else
    root = uitreenode('v0','Root','Root',[],false);
    name = inputname(1);
    arrayfun(@(x)root.add(struct2node(x,name)),S);
end

[tree,container] = uitree('v0','Root',root);
set(container,'Parent',h)
