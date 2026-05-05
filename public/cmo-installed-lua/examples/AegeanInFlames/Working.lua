local WeaponList = {
	{name='Thessaloniki International Airport', wpn_dbid=718, number=12}, -- AIM-120C-7 AMRAAM P3I.3
	{name='Thessaloniki International Airport', wpn_dbid=1129, number=36}, -- AIM-2000A IRIS-T
	{name='Thessaloniki International Airport', wpn_dbid=1765, number=12}, -- AGM-65G Maverick IR
	{name='Thessaloniki International Airport', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Thessaloniki International Airport', wpn_dbid=459, number=10}, -- AN/AAQ-33 Sniper XR Pod [FLIR + LRMTS, 40k ft]
	{name='Thessaloniki International Airport', wpn_dbid=1906, number=40}, -- GBU-12D/B Paveway II LGB [Mk82]

	{name='Larissa AB - 110 TFW', wpn_dbid=718, number=36}, -- AIM-120C-7 AMRAAM P3I.3
	{name='Larissa AB - 110 TFW', wpn_dbid=1129, number=98}, -- AIM-2000A IRIS-T
	{name='Larissa AB - 110 TFW', wpn_dbid=826, number=4}, -- AGM-154C JSOW [BROACH]
	{name='Larissa AB - 110 TFW', wpn_dbid=1765, number=18}, -- AGM-65G Maverick IR
	{name='Larissa AB - 110 TFW', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Larissa AB - 110 TFW', wpn_dbid=459, number=10}, -- AN/AAQ-33 Sniper XR Pod [FLIR + LRMTS, 40k ft]
	{name='Larissa AB - 110 TFW', wpn_dbid=1709, number=24}, -- DWS.39 AFDS [24 x STABO]
	{name='Larissa AB - 110 TFW', wpn_dbid=870, number=168}, -- GBU-31(V)3/B JDAM [BLU-109/B]
	{name='Larissa AB - 110 TFW', wpn_dbid=1498, number=200}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Larissa AB - 110 TFW', wpn_dbid=1814, number=908}, -- Mk82 500lb LDGP
	{name='Larissa AB - 110 TFW', wpn_dbid=1839, number=532}, -- Mk84 2000lb LDGP

	{name='Agxialos AB - 111 TFW', wpn_dbid=446, number=16}, -- AIM-120B AMRAAM
	{name='Agxialos AB - 111 TFW', wpn_dbid=1384, number=240}, -- AIM-9M Sidewinder
	{name='Agxialos AB - 111 TFW', wpn_dbid=1765, number=20}, -- AGM-65G Maverick IR
	{name='Agxialos AB - 111 TFW', wpn_dbid=650, number=8}, -- AGM-88B HARM
	{name='Agxialos AB - 111 TFW', wpn_dbid=977, number=12}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Agxialos AB - 111 TFW', wpn_dbid=976, number=12}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Agxialos AB - 111 TFW', wpn_dbid=1709, number=24}, -- DWS.39 AFDS [24 x STABO]
	{name='Agxialos AB - 111 TFW', wpn_dbid=1032, number=72}, -- Durandal [BLU-107]
	{name='Agxialos AB - 111 TFW', wpn_dbid=871, number=100}, -- GBU-24A/B Paveway III LGB [BLU-109/B]
	{name='Agxialos AB - 111 TFW', wpn_dbid=1498, number=60}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Agxialos AB - 111 TFW', wpn_dbid=1814, number=760}, -- Mk82 500lb LDGP
	{name='Agxialos AB - 111 TFW', wpn_dbid=1839, number=640}, -- Mk84 2000lb LDGP

	{name='Tanagra AB - 114 TFW', wpn_dbid=1872, number=160}, -- MICA EM
	{name='Tanagra AB - 114 TFW', wpn_dbid=1873, number=120}, -- MICA IR
	{name='Tanagra AB - 114 TFW', wpn_dbid=1878, number=150}, -- R.550 Magic 2 Mk1
	{name='Tanagra AB - 114 TFW', wpn_dbid=258, number=28}, -- AM.39 Exocet Blk II
	{name='Tanagra AB - 114 TFW', wpn_dbid=333, number=86}, -- SCALP EG

	{name='Araxos AB - 116 TFW', wpn_dbid=718, number=8}, -- AIM-120C-7 AMRAAM P3I.3
	{name='Araxos AB - 116 TFW', wpn_dbid=1129, number=120}, -- AIM-2000A IRIS-T
	{name='Araxos AB - 116 TFW', wpn_dbid=826, number=16}, -- AGM-154C JSOW [BROACH]
	{name='Araxos AB - 116 TFW', wpn_dbid=1765, number=28}, -- AGM-65G Maverick IR
	{name='Araxos AB - 116 TFW', wpn_dbid=650, number=4}, -- AGM-88B HARM
	{name='Araxos AB - 116 TFW', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Araxos AB - 116 TFW', wpn_dbid=459, number=10}, -- AN/AAQ-33 Sniper XR Pod [FLIR + LRMTS, 40k ft]
	{name='Araxos AB - 116 TFW', wpn_dbid=91, number=140}, -- GBU-24E/B Paveway III GPS/LGB [BLU-109A/B]
	{name='Araxos AB - 116 TFW', wpn_dbid=554, number=96}, -- GBU-31(V)1/B JDAM [Mk84]
	{name='Araxos AB - 116 TFW', wpn_dbid=870, number=60}, -- GBU-31(V)3/B JDAM [BLU-109/B]
	{name='Araxos AB - 116 TFW', wpn_dbid=1498, number=480}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Araxos AB - 116 TFW', wpn_dbid=1814, number=400}, -- Mk82 500lb LDGP
	{name='Araxos AB - 116 TFW', wpn_dbid=1839, number=500}, -- Mk84 2000lb LDGP

	{name='Andravida AB - 117 TFW', wpn_dbid=446, number=32}, -- AIM-120B AMRAAM
	{name='Andravida AB - 117 TFW', wpn_dbid=1401, number=90}, -- AIM-9L Sidewinder
	{name='Andravida AB - 117 TFW', wpn_dbid=1765, number=48}, -- AGM-65G Maverick IR
	{name='Andravida AB - 117 TFW', wpn_dbid=1036, number=22}, -- AN/ALQ-119 DECM Pod
	{name='Andravida AB - 117 TFW', wpn_dbid=1920, number=380}, -- GBU-10E/B Paveway II LGB [Mk84]
	{name='Andravida AB - 117 TFW', wpn_dbid=1906, number=150}, -- GBU-12D/B Paveway II LGB [Mk82]
	{name='Andravida AB - 117 TFW', wpn_dbid=871, number=80}, -- GBU-24A/B Paveway III LGB [BLU-109/B]
	{name='Andravida AB - 117 TFW', wpn_dbid=504, number=10}, -- Litening Pod [FLIR + LRMTS, 40k ft]
	{name='Andravida AB - 117 TFW', wpn_dbid=1498, number=200}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Andravida AB - 117 TFW', wpn_dbid=1814, number=360}, -- Mk82 500lb LDGP
	{name='Andravida AB - 117 TFW', wpn_dbid=1839, number=120}, -- Mk84 2000lb LDGP

	{name='Skyros FAB - 135 SQN', wpn_dbid=446, number=24}, -- AIM-120B AMRAAM
	{name='Skyros FAB - 135 SQN', wpn_dbid=1384, number=60}, -- AIM-9M Sidewinder
	{name='Skyros FAB - 135 SQN', wpn_dbid=1498, number=160}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]

	{name='Santorini Airbase FOB', wpn_dbid=446, number=8}, -- AIM-120B AMRAAM
	{name='Santorini Airbase FOB', wpn_dbid=1384, number=48}, -- AIM-9M Sidewinder
	{name='Santorini Airbase FOB', wpn_dbid=1498, number=24}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]

	{name='Souda AB - 115 TFW', wpn_dbid=718, number=24}, -- AIM-120C-7 AMRAAM P3I.3
	{name='Souda AB - 115 TFW', wpn_dbid=1129, number=120}, -- AIM-2000A IRIS-T
	{name='Souda AB - 115 TFW', wpn_dbid=826, number=8}, -- AGM-154C JSOW [BROACH]
	{name='Souda AB - 115 TFW', wpn_dbid=1765, number=44}, -- AGM-65G Maverick IR
	{name='Souda AB - 115 TFW', wpn_dbid=650, number=12}, -- AGM-88B HARM
	{name='Souda AB - 115 TFW', wpn_dbid=977, number=28}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Souda AB - 115 TFW', wpn_dbid=459, number=28}, -- AN/AAQ-33 Sniper XR Pod [FLIR + LRMTS, 40k ft]
	{name='Souda AB - 115 TFW', wpn_dbid=91, number=150}, -- GBU-24E/B Paveway III GPS/LGB [BLU-109A/B]
	{name='Souda AB - 115 TFW', wpn_dbid=2061, number=128}, -- GBU-49/B Paveway II GPS/LGB [Mk82]
	{name='Souda AB - 115 TFW', wpn_dbid=1498, number=160}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Souda AB - 115 TFW', wpn_dbid=1814, number=880}, -- Mk82 500lb LDGP
	{name='Souda AB - 115 TFW', wpn_dbid=1839, number=1000}, -- Mk84 2000lb LDGP

	{name='Heliport Lesvos', wpn_dbid=683, number=16}, -- AGM-114K Hellfire II
	{name='Heliport Lesvos', wpn_dbid=733, number=8}, -- AIM-92E Stinger ATAS RPM Blk I
	{name='Heliport Lesvos', wpn_dbid=1929, number=168}, -- Hydra 70mm Rocket

	{name='Heliport Chios', wpn_dbid=683, number=32}, -- AGM-114K Hellfire II
	{name='Heliport Chios', wpn_dbid=733, number=8}, -- AIM-92E Stinger ATAS RPM Blk I
	{name='Heliport Chios', wpn_dbid=1929, number=168}, -- Hydra 70mm Rocket

	{name='Heliport Samos', wpn_dbid=683, number=16}, -- AGM-114K Hellfire II
	{name='Heliport Samos', wpn_dbid=733, number=8}, -- AIM-92E Stinger ATAS RPM Blk I
	{name='Heliport Samos', wpn_dbid=1929, number=168}, -- Hydra 70mm Rocket

	{name='Heliport Rhode', wpn_dbid=683, number=16}, -- AGM-114K Hellfire II
	{name='Heliport Rhode', wpn_dbid=733, number=12}, -- AIM-92E Stinger ATAS RPM Blk I
	{name='Heliport Rhode', wpn_dbid=1929, number=112}, -- Hydra 70mm Rocket

	{name='Paphos International Airport', wpn_dbid=1120, number=96}, -- AGM-114KBF Hellfire II
	{name='Paphos International Airport', wpn_dbid=1042, number=80}, -- AT-6 Spiral [9M114 Sturm-V]
	{name='Paphos International Airport', wpn_dbid=372, number=24}, -- HOT
	{name='Paphos International Airport', wpn_dbid=1929, number=2736}, -- Hydra 70mm Rocket
	{name='Paphos International Airport', wpn_dbid=1025, number=1920}, -- S-80KO 80mm Rocket [HEAT]


	{name='Ataturk International Airport', wpn_dbid=446, number=16}, -- AIM-120B AMRAAM
	{name='Ataturk International Airport', wpn_dbid=945, number=48}, -- AIM-9X Sidewinder

	{name='Bandirma AB', wpn_dbid=446, number=48}, -- AIM-120B AMRAAM
	{name='Bandirma AB', wpn_dbid=945, number=120}, -- AIM-9X Sidewinder
	{name='Bandirma AB', wpn_dbid=977, number=12}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Bandirma AB', wpn_dbid=976, number=12}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Bandirma AB', wpn_dbid=911, number=12}, -- AN/ALQ-184(V) DECM Pod
	{name='Bandirma AB', wpn_dbid=1920, number=200}, -- GBU-10E/B Paveway II LGB [Mk84]
	{name='Bandirma AB', wpn_dbid=3174, number=8}, -- GBU-10X/B Paveway II LGB [NEB 2000lb Penetrator]
	{name='Bandirma AB', wpn_dbid=870, number=100}, -- GBU-31(V)3/B JDAM [BLU-109/B]
	{name='Bandirma AB', wpn_dbid=1498, number=60}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Bandirma AB', wpn_dbid=1814, number=200}, -- Mk82 500lb LDGP
	{name='Bandirma AB', wpn_dbid=3170, number=30}, -- SOM A

	{name='Balikesir AB', wpn_dbid=446, number=40}, -- AIM-120B AMRAAM
	{name='Balikesir AB', wpn_dbid=945, number=48}, -- AIM-9X Sidewinder
	{name='Balikesir AB', wpn_dbid=1765, number=48}, -- AGM-65G Maverick IR
	{name='Balikesir AB', wpn_dbid=650, number=12}, -- AGM-88B HARM
	{name='Balikesir AB', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Balikesir AB', wpn_dbid=976, number=10}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Balikesir AB', wpn_dbid=1920, number=100}, -- GBU-10E/B Paveway II LGB [Mk84]
	{name='Balikesir AB', wpn_dbid=1906, number=150}, -- GBU-12D/B Paveway II LGB [Mk82]
	{name='Balikesir AB', wpn_dbid=1929, number=608}, -- Hydra 70mm Rocket
	{name='Balikesir AB', wpn_dbid=3175, number=208}, -- Hydra Cirit 70mm Rocket
	{name='Balikesir AB', wpn_dbid=3497, number=32}, -- MAM-L
	{name='Balikesir AB', wpn_dbid=3176, number=208}, -- Mizrak-U [UMTAS]
	{name='Balikesir AB', wpn_dbid=1498, number=60}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Balikesir AB', wpn_dbid=1814, number=400}, -- Mk82 500lb LDGP

	{name='Çiğli AB', wpn_dbid=1401, number=36}, -- AIM-9L Sidewinder
	{name='Çiğli AB', wpn_dbid=1765, number=20}, -- AGM-65G Maverick IR
	{name='Çiğli AB', wpn_dbid=3175, number=1000}, -- Hydra Cirit 70mm Rocket
	{name='Çiğli AB', wpn_dbid=3497, number=24}, -- MAM-L
	{name='Çiğli AB', wpn_dbid=3176, number=160}, -- Mizrak-U [UMTAS]
	{name='Çiğli AB', wpn_dbid=1498, number=60}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Çiğli AB', wpn_dbid=1814, number=480}, -- Mk82 500lb LDGP

	{name='Dalaman AFB', wpn_dbid=446, number=16}, -- AIM-120B AMRAAM
	{name='Dalaman AFB', wpn_dbid=945, number=48}, -- AIM-9X Sidewinder
	{name='Dalaman AFB', wpn_dbid=1120, number=16}, -- AGM-114KBF Hellfire II
	{name='Dalaman AFB', wpn_dbid=1475, number=8}, -- AGM-119B Penguin Mk2 Mod 7
	{name='Dalaman AFB', wpn_dbid=3497, number=20}, -- MAM-L
	{name='Dalaman AFB', wpn_dbid=1647, number=16}, -- Mk46 NEARTIP Mod 5

	{name='Eskisehir AB', wpn_dbid=1401, number=60}, -- AIM-9L Sidewinder
	{name='Eskisehir AB', wpn_dbid=1765, number=12}, -- AGM-65G Maverick IR
	{name='Eskisehir AB', wpn_dbid=3174, number=100}, -- GBU-10X/B Paveway II LGB [NEB 2000lb Penetrator]
	{name='Eskisehir AB', wpn_dbid=1906, number=96}, -- GBU-12D/B Paveway II LGB [Mk82]
	{name='Eskisehir AB', wpn_dbid=3173, number=20}, -- HGK INS/GPS [NEB 2000lb Penetrator]
	{name='Eskisehir AB', wpn_dbid=822, number=12}, -- EL/L-8222 ASSP DECM Pod
	{name='Eskisehir AB', wpn_dbid=1292, number=12}, -- Litening III Pod [FLIR + LRMTS, 40k ft]
	{name='Eskisehir AB', wpn_dbid=1498, number=60}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Eskisehir AB', wpn_dbid=1814, number=980}, -- Mk82 500lb LDGP
	{name='Eskisehir AB', wpn_dbid=3170, number=36}, -- SOM A

	{name='Konya AB', wpn_dbid=446, number=16}, -- AIM-120B AMRAAM
	{name='Konya AB', wpn_dbid=945, number=36}, -- AIM-9X Sidewinder
	{name='Konya AB', wpn_dbid=1765, number=12}, -- AGM-65G Maverick IR
	{name='Konya AB', wpn_dbid=977, number=12}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Konya AB', wpn_dbid=976, number=12}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Konya AB', wpn_dbid=1032, number=60}, -- Durandal [BLU-107]
	{name='Konya AB', wpn_dbid=1498, number=80}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Konya AB', wpn_dbid=1814, number=420}, -- Mk82 500lb LDGP

	{name='Merzifon AFB', wpn_dbid=446, number=16}, -- AIM-120B AMRAAM
	{name='Merzifon AFB', wpn_dbid=945, number=96}, -- AIM-9X Sidewinder
	{name='Merzifon AFB', wpn_dbid=1765, number=40}, -- AGM-65G Maverick IR
	{name='Merzifon AFB', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Merzifon AFB', wpn_dbid=976, number=10}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Merzifon AFB', wpn_dbid=1906, number=200}, -- GBU-12D/B Paveway II LGB [Mk82]
	{name='Merzifon AFB', wpn_dbid=1498, number=40}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Merzifon AFB', wpn_dbid=1814, number=600}, -- Mk82 500lb LDGP
	{name='Merzifon AFB', wpn_dbid=1839, number=72}, -- Mk84 2000lb LDGP

	{name='Incirlik AFB', wpn_dbid=446, number=8}, -- AIM-120B AMRAAM
	{name='Incirlik AFB', wpn_dbid=945, number=48}, -- AIM-9X Sidewinder
	{name='Incirlik AFB', wpn_dbid=650, number=8}, -- AGM-88B HARM
	{name='Incirlik AFB', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Incirlik AFB', wpn_dbid=976, number=10}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Incirlik AFB', wpn_dbid=795, number=24}, -- CBU-103 WCMD [BLU-87/B CEM, 202 x BLU-97/B Dual-Purpose Bomblets]
	{name='Incirlik AFB', wpn_dbid=1906, number=80}, -- GBU-12D/B Paveway II LGB [Mk82
	{name='Incirlik AFB', wpn_dbid=870, number=48}, -- GBU-31(V)3/B JDAM [BLU-109/B]
	{name='Incirlik AFB', wpn_dbid=1498, number=100}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Incirlik AFB', wpn_dbid=1814, number=900}, -- Mk82 500lb LDGP
	{name='Incirlik AFB', wpn_dbid=1839, number=72}, -- Mk84 2000lb LDGP

	{name='Diyabakir AFB', wpn_dbid=446, number=24}, -- AIM-120B AMRAAM
	{name='Diyabakir AFB', wpn_dbid=945, number=48}, -- AIM-9X Sidewinder
	{name='Diyabakir AFB', wpn_dbid=1765, number=50}, -- AGM-65G Maverick IR
	{name='Diyabakir AFB', wpn_dbid=977, number=10}, -- AN/AAQ-13 LANTIRN Pod [FLIR + TFR]
	{name='Diyabakir AFB', wpn_dbid=976, number=10}, -- AN/AAQ-14 LANTIRN Pod [FLIR + LRMTS, 12k ft]
	{name='Diyabakir AFB', wpn_dbid=1920, number=120}, -- GBU-10E/B Paveway II LGB [Mk84]
	{name='Diyabakir AFB', wpn_dbid=3177, number=100}, -- HGK INS/GPS [Mk84]
	{name='Diyabakir AFB', wpn_dbid=1498, number=80}, -- Mk20 Rockeye II CB [247 x Mk118 Dual Purpose Bomblets]
	{name='Diyabakir AFB', wpn_dbid=1814, number=720}, -- Mk82 500lb LDGP
	{name='Diyabakir AFB', wpn_dbid=1839, number=96}, -- Mk84 2000lb LDGP

	{name='Dalaman Secret Heliport', wpn_dbid=3175, number=200}, -- Hydra Cirit 70mm Rocket
	{name='Dalaman Secret Heliport', wpn_dbid=3176, number=200}, -- Mizrak-U [UMTAS]

	{name='Cyprus Secret Heliport', wpn_dbid=1120, number=128}, -- AGM-114KBF Hellfire II
	{name='Cyprus Secret Heliport', wpn_dbid=833, number=64}, -- BGM-71E TOW 2A
	{name='Cyprus Secret Heliport', wpn_dbid=1929, number=1672}, -- Hydra 70mm Rocket
}

for k,v in ipairs (WeaponList) do
	ScenEdit_AddWeaponToUnitMagazine({name=v.name, wpn_dbid=v.wpn_dbid, number=v.number})
end