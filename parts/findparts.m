function jp = findparts(annotation,j)

jp = [];
if isfield(annotation, 'object') && isfield(annotation.object(j), 'parts') && isfield(annotation.object(j).parts, 'hasparts')
    jp = annotation.object(j).parts.hasparts;
end

%     
% id = [];
% jp = [];
% if isfield(annotation,'object') && isfield(annotation.object(j),'id')
%     id = annotation.object(j).id;
% end
% 
% if ~isempty(id) && isfield(annotation.object,'partof')
%     parts = str2double({annotation.object(:).partof});
%     jp = find(parts==str2double(id));
% end
