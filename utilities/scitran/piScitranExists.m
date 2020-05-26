function bool = piScitranExists
% Check the scitran installation.  Current required version is 432 or
% higher
%
% Does not check that the user has the stanfordlabs account.
%
% ZL/BW SCIEN
%
% See also
%

if isempty(which('scitran'))
    error('You must have scitran with a stanfordlabs Flywheel account');
else
    bool = true;
end

end

