function string = piNum2String(num)

% Convert a number to a string
if isinteger(num)
    % Adding num(:)' to avoid dimension mismatch
    string = int2str(num(:)');
else
    % using %.5f is much slower than simply asking for precision
    %formatSpec = '%.5f ';
    formatSpec = 7; % 7 significant digits
    string = num2str(num, formatSpec);
end
%{
% Comment this out for reference. If the faster code is correct, we will 
% delete this.    

string='';
  
% by default we use the older, slower code, since I can't prove
% that the newer, faster code doesn't break anything -- DJC
perf = getpref('ISET','fast_num2string', false);


if perf
    if isinteger(num)
        string = int2str(num);
    else
        % using %.5f is much slower than simply asking for precision
        %formatSpec = '%.5f ';
        formatSpec = 7;
        string = num2str(num, formatSpec);
    end
else
    %I Don't think we need our own for loop?!
    for ii = 1:numel(num)
        if isinteger(num)
            string = [string, ' ' ,int2str(num(ii))]; % look for better perf. -- djc
        else
            formatSpec = '%.5f';
            string = [string, ' ' ,num2str(num(ii), formatSpec)];
        end
    end
end
%}
end