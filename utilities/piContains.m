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

% Sometimes the str is a cell. This is no good for isempty. Let's check and
% fix, if possible.
if(iscell(str))
    if((length(str) == 1))
        str = str{1};
    else
        error('String given to piContains is a cell matrix with multiple entries.');
    end
end

if (~isempty(strfind(str,pattern)))
    tf = 1;
else
    tf = 0;
end
