/*
	author: Martin
	description: none
	returns: nothing
*/

_msg = "Could all ungrouped players back at base please join an existing section and request your new squad lead for transport, or start a new section and request transport once you have at least 4 members";

[[west, "HQ"], _msg] remoteExec ["sideChat"];

"ugmsg sent"