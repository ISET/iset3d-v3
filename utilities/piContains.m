function tf = piContains(str, pattern, varargin)
% Return 1/true if str contains pattern, and returns 0 otherwise.
%
% Synopsis:
%    tf = piContains(str, pattern, [ignoreCase])
%
% Description:
%    Work around for the contains function. Written so that it will
%    work with Matlab versions prior to those with contains(). If
%    ignoreCase is provided will do the obvious.
%
% Inputs:
%    str        - Array. A cell array of strings (or a string)
%    pattern    - String. A string.
%
% Outputs:
%    tf         - Numeric Array. A logical array for each entry in the cell
%                 array, according to whether it contains the pattern.
%
% Optional key/value pairs:
%    ignoreCase - (Optional) Numeric. The boolean indicator whether or not
%                 to ignore the case of pattern. Default is 0 (false). If
%                 1(true), will ignore case.
%
% See Also:
%   contains, strfind
%

% History:
%    XX/XX/XX  DHB/ZL  ISETBIO Team
%    03/29/19  JNM     Documentation pass. Ingore case added.
%    04/18/19  JNM  Merge Master in (resolve conflicts)

% Examples:
%{
   piContains('help', 'he')
   piContains('help', 'm')
   piContains({'help', 'he', 'lp'}, 'he')
%}

p = inputParser;
p.KeepUnmatched = true;
p.addParameter('ignoreCase', 0);
p.parse(varargin{:})

ignoreCase = logical(p.Results.ignoreCase);

if iscell(str)
    tf = zeros(1, length(str));

    % If cell loop through all entries.
    for ii = 1:length(str)
        currStr = str{ii};

        if ignoreCase
            pattern = lower(pattern);
            currStr = lower(currStr);
        end
        if ~isempty(strfind(currStr, pattern)) %#ok<*STREMP>
            tf(ii) = 1;
        else
            tf(ii) = 0;
        end
    end
else
    if ~isempty(strfind(str, pattern)), tf = 1; else, tf = 0; end
end

tf = logical(tf);

end
