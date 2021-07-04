function string = piNum2String(num)
% ISET3d replacement for num2str
%
% Synopsis
%   string = piNum2String(num)
%
% Input
%   num - An array of numbers
%
% Output
%   str - A char array?  A string array?
%
% Description
%
%  The speed on num2str is bad.  But the function has some features we
%  like, though. This function emulates num2string (we think) but runs much
%  faster
%
%  Because these are supposed to fit in text, we always force the num to be
%  a row vector.
%
% See also
%    sprintf

% Convert a number to a string
if isinteger(num)
    % Adding num(:)' to avoid dimension mismatch
    string = int2str(num(:)');
else
    % using %.5f is much slower than simply asking for precision
    %formatSpec = '%.5f ';
    formatSpec = 7; % 7 significant digits
    string = num2str(num(:)', formatSpec);
end

end