function [content, xmlsubstring] = queryXML(xml, tag)
%
% xml = '<bls>3223445</bls><pol>dsdsf</pol>'
% [content, xmlsubstring] = queryXML(xml, 'pol');
% content{1}
%    ans = 
%    'dsdsf'
% xmlsubstring = 
%    '<pol>dsdsf</pol>'


query = ['<' tag '>(\w+)</' tag '>'];
[content, xmlsubstring] = regexp(xml, query, 'tokens', 'match');

% we can query:
%

% query = ['<object>*<name>*car*</name>*</object>];
