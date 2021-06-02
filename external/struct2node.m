function root = struct2node(S,name)
%STRUCT2NODE returns a parallel uitreenode object for a struct
%   ROOT = STRUCT2NODE(S) returns a uitreenode object.
%   ROOT = STRUCT2NODE(S,NAME) returns a uitreenode object with the given
%   name.

assert(isscalar(S)&&isstruct(S),'function only defined for scalar structs')

if nargin==1
    name = inputname(1);
end
if isempty(name),name='Node';end
root = uitreenode('v0',name,name,[],false);
cellfun(@(name)buildNode(root,S,name,S.name),fieldnames(S))
    

function buildNode(parentNode,S,name,value)
if ~isscalar(S)
    arrayfun(@(X)buildNode(parentNode,X,name),S)
    return
end
val = S.(name);
isLeaf = ~isstruct(val);
childNode = uitreenode(parentNode,'Text',name,isLeaf);
if ~isLeaf
    cellfun(@(x)buildNode(childNode,val,x,x),fieldnames(val))
end
parentNode.add(childNode);
    
