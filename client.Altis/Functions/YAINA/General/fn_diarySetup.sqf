/*
Function: YAINA_fnc_diarySetup

Description:
	Initializes the diary with server rules, information and credits
	during the postInit phase.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Sekwah
*/

if (!hasInterface) exitWith {};

player createDiarySubject ["LRG Public Server", "LRG Public Server"];


player createDiaryRecord ["LRG Public Server", ["Issues",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>If you do encounter any bugs, issues or want to leave us feedback feel free to talk to a member of the Server Team, post on our forums or log an issue on our tracker, all linked below:</font>
<br/>
<br/>Discord:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://discord.lastresortgaming.net'"">discord.lastresortgaming.net</execute></font>
<br/>Forums:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute></font>
<br/>Issue Tracker:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'https://bitbucket.org/lastresortgaming/lrg-yaina/issues/new'"">lastresortgaming.net</execute></font>
"
]];

player createDiaryRecord ["LRG Public Server", ["Credits",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>We would like to thank the following for their contributions to both the community and especially the following projects that have been used to create this mission.</font>
<br/>
<br/>alganthe:<br/><font face='PuristaLight' color='#D3D3D3'>    Vehicle Crew HUD, Occupy Building Function</font>
<br/>CBAP_A3:<br/><font face='PuristaLight' color='#D3D3D3'>    PFH Handlers, Event Handlers</font>
<br/>Champ-1:<br/><font face='PuristaLight' color='#D3D3D3'>    CHVD</font>
<br/>code34 :<br/><font face='PuristaLight' color='#D3D3D3'>    Real Weather</font>
<br/>duda :<br/><font face='PuristaLight' color='#D3D3D3'>
    Advanced Towing, Advanced Rappelling,<br/>
    Advanced Sling Loading, Advanced Urban Rappelling
</font>
<br/>outlawled:<br/><font face='PuristaLight' color='#D3D3D3'>    Mag Repack</font>
<br/>Psychobastard:<br/><font face='PuristaLight' color='#D3D3D3'>    AIS Revive</font>
<br/>Quicksilver:<br/><font face='PuristaLight' color='#D3D3D3'>    QS Icons</font>
<br/>suiside :<br/><font face='PuristaLight' color='#D3D3D3'>    AOA Hummingbird Skin</font>
</font>
"
]];

player createDiaryRecord ["LRG Public Server", ["Medical System",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>The LRG public server runs a modified AIS medical system, the highlights as follows</font>
<font face='PuristaLight' color='#D3D3D3' size='12'>
<br/>
<br/>* After taking too much damage, players become unconscious
<br/>* Anyone can stabalise an unconscious player to avoid bleed out
<br/>* Specialist medical equipment such as MERT UAVs allow non-medics
<br/>  to revive players if they are within range.
<br/>
</font>
"
]];

player createDiaryRecord ["LRG Public Server", ["Optional Mods",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>Please click a mod to copy the URL to your clipboard, alternatively, use the following collection url: <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=1214679552'"">YAINA Approved Mods Collection</execute></font>
<br/>
<br/>badbenson:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=333310405'"">Enhanced Movement</execute></font>
<br/>CBA_A3:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=450814997'"">CBA_A3</execute></font>
<br/>dslyecxi:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=498740884'"">ShackTac User Interface</execute></font>
<br/>LAxemann:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=825179978'"">Enhanced Soundscape</execute>, <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=825181638'"">DynaSound 2</execute></font>
<br/>LordJarhead:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=861133494'"">JSRS SOUNDMOD</execute></font>
<br/>Paladin:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://steamcommunity.com/sharedfiles/filedetails/?id=767380317'"">Blastcore Edited (standalone version)</execute></font>
"
]];



player createDiarySubject ["** SERVER RULES **", "** SERVER RULES **" ];

player createDiaryRecord ["** SERVER RULES **", ["HQ",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
HQ is a support role, your job is to coordinate the tasking, transport, reinforcement and resupply of players and assets.
<br/>
<br />1. You must be on Discord in a voice channel: <execute expression=""copyToClipboard 'http://discord.lastresortgaming.net'"">discord.lastresortgaming.net</execute>
<br />2. You should be in a locked group alone, and name it HQ or ZERO to clearly identify yourself and ensure players can contact you.
<br />3. When directing sections and players such as pilots, consider both the mission and player enjoyment together.
<br />4. HQ should be fair in directing pilots and section commanders, not ignoring or favouring individuals.
<br />5. Any rewards purchased should be bought with the best interests of the entire playerbase and the mission requirements.
<br/>
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["MERT",
"
<font face='PuristaLight' color='#D3D3D3'>
<br />
Medical Emergency Response Team (MERT) is a support role, your job is to support ground forces with emergency medical aid when their medics are incapacitated or impeded
<br />
<br />1. You must be on Discord in a voice channel: <execute expression=""copyToClipboard 'http://discord.lastresortgaming.net'"">discord.lastresortgaming.net</execute>
<br />2. You must be in a clearly identified MERT group so section leaders can contact you
<br />3. Any MERT member can fly the MERT chopper - use this with sensibly
<br />4. Only insert to safe locatinos, if the section is pinned down, and you are unable to safely appraoch, make use of the medical UAVs
<br />
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];


player createDiaryRecord ["** SERVER RULES **", ["Pilots",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
Pilot is a support role, your job is to provide infantry units with safe, responsible transport, as such you have to maintain our code of conduct to participate in this role.
<br/>
<br />1. You must be on Discord in a voice channel: <execute expression=""copyToClipboard 'http://discord.lastresortgaming.net'"">discord.lastresortgaming.net</execute>
<br />2. You should be in a locked group alone, clearly identified with a call sign to ensure HQ and other players can contact you.
<br />3. If no HQ is online, pilots must coordinate transport and resupply directly with section leaders.
<br />4. If an HQ is online, pilots must obey their instructions and taskings.
<br />5. You are expected to have a basic standard of ability at flying aircraft in game before joining this server as a pilot.
<br />6. Close Air Support (CAS) is only to be undertaken following specific request from a ground unit observing the target.
<br />7. Pilots are a critical role on the server and failure to meet standards and rules may result in immediate kicking and/or banning.
<br/>
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["UAV Operator",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
UAV Operators are a support role, your job is to provide intelligence of enemy positions and movements, as well as fire support on request only.
<br/>
<br />1. You must be on Discord in a voice channel: <execute expression=""copyToClipboard 'http://discord.lastresortgaming.net'"">discord.lastresortgaming.net</execute>
<br />2. You should be in a locked group alone, clearly identified with a call sign to ensure HQ and other players can contact you.
<br />3. You must coordinate your actions with HQ and Section Leaders and not operate unilaterally.
<br />4. You should mark targets and enemy positions on the map but do not overclutter it so as to obstruct players ability to use it.
<br />5. Close Air Support (CAS) is only to be undertaken following specific request from a ground unit observing the target.
<br />6. UAVs are highly valuable assets for the server and failure to meet standards and rules may result in immediate kicking and banning.
<br/>
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["Sniper Team (GHOST)",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
Snipers are a support role, your job is to provide sections with covert surveillance and target acquisition, as well as precision fires in support of their manoeuvres.
<br/>
<br />1. You should be in a locked group containing only the sniper and observer (if both online), clearly identified with the GHOST call sign to ensure HQ and other players can contact you.
<br />2. GHOST may not deploy as a member of a normal infantry section unless specifically directed to do so by a Zeus. GHOST is an independent specialist asset.
<br />3. You must communicate effectvely with HQ and section leaders on your observations in the AO.
<br />4. You are expected to be in sensible locations to carry out overwatch. Remember you are a small isolated unit and may not be able to get medical support if you are downed.
<br />5. Your primary role is intelligence gathering, providing precision fires only in support of another unit or at direction of HQ.
<br/>
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["Section Members",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
You are the the main fighting force on the ground.
<br/>
<br />1. All players must be in a section, and these sections must contain at least 4 players to deploy to the field.
<br />2. You must listen to and follow the instructions of your section leader.
<br />3. Do not board vehicles or leave the main base without approval of your section leader.
<br />4. If you need transport, request it from your section leader who will coordinate with HQ.
<br/>
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["Section Leaders",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
You are the commanders on the ground, expected to follow the section member rules as well as those below.
<br/>
<br />1. Your role is to coordinate the movement and actions of your section. Do this with respect and fairness, remembering player enjoyment as well as the mission requirements.
<br />2. Coordinate transport for your members with HQ
<br />3. If required, coordinate CAS strikes with pilots or UAV. You may not request CAS for targets you are not able to see or in contact with.
<br />4. If no HQ are online, Pilots take over that responsibility, if no pilots, you may use the paradrop feature for insertion
<br/>
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["General Rules",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
We want this server to remain friendly and a place people come to enjoy themselves, therefore our geneeral rules are largely common sense:
<br/>
<br />1. Hacking and mission exploitation
<br />2. Intentional team-killing
<br />3. Excessive unintentional team-killing
<br />4. Unnecessary destruction of BLUFOR vehicles
<br />5. Verbal abuse and bullying
<br />6. Griefing and obstructive play.
<br />7. Excessive mic spamming, music playing
<br />8. Ignoring directions from an admin or a member of the Server Team
<br />
<br />Full rules are provided in the <execute expression=""copyToClipboard 'https://bit.ly/2VySths'"">LRG Player Guide</execute>
<br />
<br />If you see a player in violation of the above, contact an LRG admin or a member of the Server Team on Discord or PM an admin on our forums at <execute expression=""copyToClipboard 'http://lastresortgaming.net'"">lastresortgaming.net</execute>
</font>
"
]];