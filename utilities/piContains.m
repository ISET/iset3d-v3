function tf = piContains(str,pattern)
% Returns 1 (true) if str contains pattern, and returns 0 (false) otherwise.
%
% Synopsis:
%    tf = pipiContains(str,pattern)
%
% Description:
%    Workalike for contains, in its simple calling form.  Written so that
%    work with Matlab versions prior to those with piContains().
%
% See also: contains, strfind

if(iscell(str))
    
    % If cell loop through all entries.
    for ii = 1:length(str)
        currStr = str{ii};
        if (~isempty(strfind(currStr,pattern)))
            tf = 1;
            break;
        else
            tf = 0;
        end
    end
    
else
    
    if (~isempty(strfind(str,pattern)))
        tf = 1;
    else
        tf = 0;
    end
    
end
