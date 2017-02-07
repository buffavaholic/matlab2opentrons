function arg=parseVarargin(Var,arg,casesen)
% function arg=parseVarargin(var,arg)
% parses any additional input argument that came in property/value pair
% arg is a struct where field names ar eproperty names and values ar
% edefault values. 
% 
% EXAMPLE: 
% arg=parseVarargin(varargin,arg);

% if varargin was empty - this will return whatever defaults where given by
% arg. 
if isempty(Var)
    return
end

% if varargin first item is a struct - assumes it should repace
% arg as new defaults and return. useful for recursive calls of functions
% just pass the arg
if numel(Var)==1 && isstruct(Var{1})
    arg=Var{1}; 
    return
end


if nargin<3
    casesen=0;
end


% get rid of any possible other optional arguemnt that are not in
% property/value pair. parseparams remove all the cells up to (not
% including) the first string one assumeing it is the first property name
[~,Var]=parseparams(Var);

% test if all fields in var are fields in arg
if ~casesen
    unknown=setdiff(lower(Var(1:2:end)),lower(fieldnames(arg)));
else
    unknown=setdiff(Var(1:2:end),fieldnames(arg));
end

if ~isempty(unknown)
    str=sprintf('Unknown fields in input arguments:\n');
    for i=1:length(unknown)
        str=sprintf('%s %s\n',str,unknown{i});
    end
    error(str);
end

% update any fields  
for i=1:2:length(Var)
    % check that new argument is of same class is 
    if ~casesen
        if ~isequal(class(arg.(lower(Var{i}))),class(Var{i+1}))
            warning('parsevarargin:class','Argument %s require value of class %s',Var{i},class(arg.(Var{i}))); %#ok<*WNTAG>
        end
        arg.(lower(Var{i}))=Var{i+1};
    else
        if ~isequal(class(arg.(Var{i})),class(Var{i+1}))
            warning('parsevarargin:class','Argument %s require value of class %s',Var{i},class(arg.(Var{i})));
        end
        arg.(Var{i})=Var{i+1}; 
    end
end