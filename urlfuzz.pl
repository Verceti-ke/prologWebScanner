:- module(urlfuzz,[url_parameter_vulnerable/3]).

:- use_module(library(http/http_client)).

%!	url_parameter_vulnerable(+Url, -Name, -Vulnerability) is nondet
%   Tests Url for vulnerable parameters and succeeds when parameter named Name 
%   is found to be vulnerable to Vulnerability.
url_parameter_vulnerable(Url, Name, Vulnerability) :-
    vulnerability_spike(Vulnerability, Spike),
    spike_url(Url, Spike, Name, SpikedUrl),
    proxy(Options),
    http_get(SpikedUrl, ResponseBody, Options),
    vulnerability_tell(Vulnerability, Tell),
    sub_atom(ResponseBody, _, _, _, Tell).

vulnerability_spike(xss, 'fd<xss>sa').
vulnerability_spike(sqli, 'fd\'sa').
vulnerability_tell(xss, XssTell) :- vulnerability_spike(xss, XssTell).
vulnerability_tell(sqli, 'error in your SQL syntax').

spike_url(Url, Spike, Name, SpikedUrl) :-
    parse_url(Url, Attributes),
    memberchk(search(Pairs), Attributes),
    select(Name=_, Pairs, Name=Spike, SpikedPairs),
    select(search(Pairs), Attributes, search(SpikedPairs), SpikedAttributes),
    parse_url(SpikedUrl, SpikedAttributes).

proxy([proxy(Host:Port)]) :- 
    getenv(http_proxy, Url), 
    parse_url(Url, UrlAttributes), 
    memberchk(host(Host), UrlAttributes), 
    memberchk(port(Port), UrlAttributes), 
    !.
proxy([]).
