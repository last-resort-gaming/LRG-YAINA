/*
	author: Martin
	description: none
	returns: nothing
*/

if (!hasInterface) exitWith {};

player createDiarySubject ["YAINA", "YAINA"];


player createDiaryRecord ["YAINA", ["Issues",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>Were sorry if you are encountering issues, please feel free to contact us on our forums or raise an issue in our bug tracker linked below</font>
<br/>
<br/>Teamspeak:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute></font>
<br/>Forums:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute></font>
<br/>Issue Tracker:<br/><font face='PuristaLight' color='#D3D3D3'>    <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute></font>
"
]];

player createDiaryRecord ["YAINA", ["Credits",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>We would like to thank the following for their contributions to both the community and especially the following projects that have been used to create this mission.</font>
<br/>
<br/>alganthe:<br/><font face='PuristaLight' color='#D3D3D3'>    Vehicle Crew HUD, Occupy Building Function</font>
<br/>CBA_A3:<br/><font face='PuristaLight' color='#D3D3D3'>    PFH Handlers, Event Handlers</font>
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

player createDiaryRecord ["YAINA", ["Medical System",
"
<br/>
<font face='PuristaLight' color='#D3D3D3'>YAINA Runs a modified AIS medical system, the highlights as follows</font>
<font face='PuristaLight' color='#D3D3D3' size='12'>
<br/>
<br/>* After taking too much damange, units become unconsious
<br/>* Anyone can stabalise an unconsious player to avoid bleed out
<br/>* Medical stations such as Medical UAVs allow non-medics to revive
<br/>  players if they are within range.
<br/>
</font>
"
]];

player createDiaryRecord ["YAINA", ["Optional Mods",
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
HQ is a support role, your job is to coordinate support for ground units, schedule pilots and supplies.
<br/>
<br />1. You must be on Teamspeak: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
<br />2. You agree to purchase rewards sensibly, for the benefit of the entire server population
<br/>
<br />If you see a player in violation of the above, contact an admin on Teamspeak or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["MERT",
"
<font face='PuristaLight' color='#D3D3D3'>
<br />
Medical Emergency Response Team: your job is to support ground forces when their medics are incapacitated
<br />
<br />
</font>
General:
<font face='PuristaLight' color='#D3D3D3'>
<br />1. You must be on Teamspeak: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
<br />2. You must be in a MERT group so section leaders can communicate with you to call you in
<br />3. Any MERT member can fly the MERT chopper, but please be sensible
<br />4. Only insert to safe locatinos, if the section is pinned down, and you are unable to safely appraoch, make use of the medical UAVs
<br />
<br />
</font>
UAV:
<font face='PuristaLight' color='#D3D3D3'>
<br />1. Use only the Medical UAVs, unless no main UAV operator is online
<br />
<br />If you see a player in violation of the above, contact an admin on Teamspeak or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];


player createDiaryRecord ["** SERVER RULES **", ["Pilots",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
Infantry units need safe, responsible pilots, as such you have to maintain our code of conduct to participate in this role.
<br/>
<br />1. You must be on Teamspeak: <execute expression=""copyToClipboard 'http://ts.yaina.eu'"">yaina.eu</execute>
<br />2. You agree to take over HQ responsibilities if no HQ is online
<br />3. You agree to listen and obay orders from HQ
<br />4. Excessive failure to deliver your cargo may result in a kick/ban
<br/>
<br />If you see a player in violation of the above, contact an admin on Teamspeak (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>) or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["UAV Operators",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
UAV Operators are a support role, your job is to coordinate air support with section leaders and threat identification
<br/>
<br />1. You must be on Teamspeak: (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>)
<br />2. You must be in your own group so section leaders can communicate with you
<br />3. Help locate and identify incoming threats for ground forces
<br />4. Only initiate strikes upon authorization from section leaders.
<br/>
<br />If you see a player in violation of the above, contact an admin on Teamspeak (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>) or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["Sniper Team",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
Snipers are a support role, your job is to coordinate overwatch with section leaders in thhe operational areas.
<br/>
<br />1. You must be in your own group (along with your spotter if online) unless an admin approves embedding with another section
<br />2. You must communicate with section leaders on incoming threats
<br />3. You are expected to be in sensible locations to carry out overwatch
<br/>
<br />If you see a player in violation of the above, contact an admin on Teamspeak (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>) or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["Section Members",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
Section Members, the main fighting force on the ground
<br/>
<br />1. You must listen to your section leader
<br />2. Do not board vehicles without approval of your section leader
<br />3. If you need transport, request it from your section leader who will coordinate with HQ
<br/>
<br />If you see a player in violation of the above, contact an admin on Teamspeak (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>) or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["Section Leaders",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
You are the commanders on the ground, in addition to the section member rules
<br/>
<br />1. Take lead of your section with respect
<br />2. Coordinate transport for your members with HQ
<br />2. Coordinate ground attacks for UAV
<br />4. If no HQ are online, Pilots take over that respnsibility, if no pilots, you may use the paradrop feature for insersion
<br/>
<br />If you see a player in violation of the above, contact an admin on Teamspeak (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>) or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

player createDiaryRecord ["** SERVER RULES **", ["General Rules",
"
<font face='PuristaLight' color='#D3D3D3'>
<br/>
We want this server to remain friendly and a place folks come to enjoy themselves, therefore our general ruleset is pretty much common sense
<br/>
<br />1. Hacking and mission exploitation
<br />2. Intentional team-killing
<br />3. Excessive, unintentional team-killing may result in a kick/ban
<br />4. Unnecessary destruction of BLUFOR vehicles
<br />5. Verbal abuse and bullying
<br />6. Griefing and obstructive play.
<br />7. Excessive mic spamming, music playing
<br />8. Ignroing a server moderator or admin's requests
<br />
<br />If you see a player in violation of the above, contact an admin on Teamspeak (<execute expression=""copyToClipboard 'http://yaina.eu'"">ts.yaina.eu</execute>) or file a player report on our website: <execute expression=""copyToClipboard 'http://yaina.eu'"">yaina.eu</execute>
</font>
"
]];

