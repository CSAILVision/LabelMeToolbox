function [varargout] = parseparameters(var, variables, defaults);

N = length(variables);
for i = 1:N
    j = strmatch(variables{i}, lower(var(1:2:end)));
    if length(j)>0
        varargout(i) = {var{j(1)*2}};
    else
        varargout(i) = {defaults{i}};
    end
end
