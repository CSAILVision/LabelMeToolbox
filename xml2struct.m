function v = xml2struct(xml)
%
% Translate an xml string into a matlab struct
%



xml = char(xml(:)');
xml = strrep(xml, char(10), '');
xml = strrep(xml, char(13), '');
xml = strrep(xml, '!', '');

% This is compatible Matlab 6.5
% first replace entries <tag/> by <tag></tag>
je = strfind(xml, '/>');
while ~isempty(je)
    jo = strfind(xml, '<');
    l = jo(max(find(jo < je(1))));
    tok = xml(l+1:je(1)-1);
    xml = strrep(xml, sprintf('<%s/>', char(tok)), sprintf('<%s></%s>', char(tok), char(tok)));
    je = strfind(xml, '/>');
end

xml = strrep(xml, '< ', '<');
xml = strrep(xml, ' >', '>');


% Recursive function to parse the XML file
v = parseXMLelement(xml);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = parseXMLelement(xml)
%
% gets a XML sub_string and returns a struct
% This is for Matlab 7
% first replace entries <tag/> by <tag></tag>
% [tok mat] = regexp(xml, '<(\w+)/>', 'tokens', 'match');
% for i = 1:length(tok)
%     xml = strrep(xml, sprintf('<%s/>', char(tok{i})),
%     sprintf('<%s></%s>', char(tok{i}), char(tok{i})));
% end





% start parsing
Nchar = length(xml);
%v = [];
jo = strfind(xml, '<');
%je = strfind(xml, '</');
jc = strfind(xml, '>');

v = [];

if ~isempty(jo)
    while ~isempty(jo)
        tag = deblank(xml(jo(1)+1:jc(1)-1));

        % Detect repetitions of same item (I assume all are at the same
        % level)
        jtag = strfind(xml, ['<' tag '>']);
        jClosetag = strfind(xml, ['</' tag '>']);

        if length(jtag)~=length(jClosetag)
            xml
            error(sprintf('Field  %s  is not closed', tag));
        end
        Nitems = length(jtag);

        % Call recursive parsing for each item.
        for i = 1:Nitems
            init_field = min(jc(jc>jtag(i)))+1;
            end_field = jClosetag(i)-1;

            xml_sub = xml(init_field:end_field);
            v_sub = parseXMLelement(xml_sub);

            if i == 1
                if (isstr(v_sub) && (Nitems>1))
                    v = setfield(v, tag, {v_sub});
                else
                    v.(tag) = v_sub;
                    %v = setfield(v, tag, v_sub);
                end
            else
                try
                    if isstr(v_sub)
                        v = setfield(v, tag, {i}, {v_sub}); % PROBLEM: one field repeated is constrained to have the same sub_tags.
                    else
                        v.(tag)(i) = v_sub;
                    end
                catch
                    % before adding a new element we have to check if it has
                    % all the fields, and that they are in the same order.
                    % The struct representation in Matlab
                    % requires all the fields to be identical.
                    if isstruct(v.(tag))
                        lof = fieldnames(v.(tag));
                        lof_sub = fieldnames(v_sub);
                        v_new = [];

                        for n=1:length(lof)
                            %if strmatch(lof{n}, strvcat(lof_sub))
                            if isfield(v_sub, lof{n})
                                v_new.(lof{n})=v_sub.(lof{n});
                            else
                                v_new.(lof{n})=[];
                            end
                        end

                        for m = 1:length(lof_sub)
                            %if ~(length(strmatch(lof_sub{m}, strvcat(lof)))>0)
                            if ~(isfield(v.(tag), lof_sub{m}))
                                for ii = 1:length(v.(tag))
                                    v.(tag)(ii).(lof_sub{m})=[]; % if there is a new field, add it to the previous elements in the struct
                                end
                                v_new.(lof_sub{m}) = v_sub.(lof_sub{m});
                            end
                        end
                    else
                        v_new = v_sub;
                    end

                    if(isstr(v_new))
                        v = setfield(v, tag, {i}, {v_new}); % PROBLEM: one field repeated is constrained to have the same sub_tags.
                    else
                        v.(tag)(i) = v_new;
                        %v = setfield(v, tag, {i}, v_new); % PROBLEM: one field repeated is constrained to have the same sub_tags.
                    end
                end
            end
        end

        init_nextTag = min(jo(jo>2+jClosetag(Nitems)));
        xml = xml(init_nextTag:end);

        jo = strfind(xml, '<');
        %je = strfind(xml, '</');
        jc = strfind(xml, '>');
    end
else
    % End of recursion. Return the value and remove new line characters
    v = strrep(xml, char(10), '');
end




