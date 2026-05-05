ScenEdit_RunScript('DeveloperMode.lua')

UI_SetCameraView(72, -180, 3000000)

local function ScenarioSetup()
	local html = [[
		<html lang='es'>
			<head>
				<meta charset='UTF-8'>
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<title>Scenario Options Menu</title>
				<style>
					/* Global Page Styling */
					body {
						font-family: "Share Tech Mono", monospace;
						background-color: #1c1c1c;
						color: lightgrey;
						text-align: justify;
						margin: 0;
						padding: 0;
					}

					/* Main Container */
					.container {
						width: 60%;
						max-width: 500px;
						margin: auto;
						margin-top: 20px;
						margin-bottom: 20px;
						background-color: rgba(0, 0, 0, 0.3); /* Semi-transparent for depth */
						border: 2px solid #007bff; /* Glowing blue border */
						border-radius: 8px;
						box-shadow: 0px 0px 10px rgba(0, 123, 255, 0.5);
						padding: 0px 20px 20px 20px;
					}

					/* Header Styling */
					h1 {
						font-size: 1.8rem;
						text-align: center;
						text-transform: uppercase;
						font-weight: bold;
						color: lightgrey;
						/* border-bottom: 2px solid #007bff; */
						padding-top: 5px;
						padding-bottom: 0px;
						margin-top: 0px;
						margin-bottom: 10px;
					}

					h2 {
						font-size: 1.2rem;
						text-align: center;
						text-transform: uppercase;
						font-weight: bold;
						color: lightgrey;
						padding-bottom: 0px;
						margin-top: 0px;
						margin-bottom: -5px;
					}

					/* Table Styling */
					table {
						width: 100%;
						border-collapse: collapse;
						margin: auto;
						background-color: rgba(0, 0, 0, 0.2);
						border-radius: 0px;
						overflow: hidden;
					}

					/* Table Headers & Cells */
					th, td {
						border: 2px solid #007bff;
						padding: 10px;
						text-align: left;
						font-size: 1rem;
					}

					/* Header Row */
					th {
						background-color: rgba(0, 123, 255, 0.3);
						color: lightgrey;
						font-weight: bold;
						text-transform: uppercase;
					}

					/* Table Row Styling */
					tr:nth-child(even) {
						background-color: rgba(0, 0, 0, 0.3);
					}

					tr:hover {
						background-color: rgba(70, 70, 70, 0.3);
						transition: background 0.2s ease-in-out;
					}

					ul {
						margin: 2px 0px 10px 32px;
						padding: 0;
					}

					/* Column Widths */
					td:first-child {
						width: 65%;
					}

					td:last-child {
						width: 35%;
					}

					.radio-option {
						margin-bottom: 10px;
						display: flex;
						align-items: flex-start;
						gap: 8px; /* space between the radio button and the text */
					}

					.radio-description {
						display: flex;
						flex-direction: column;
					}

					.radio-option input[type="radio"] {
						margin-top: 3px; /* optional, aligns radio dot with text top */
					}

					.radio-option span {
						display: block;
					}

					.name {
						font-size: 20px;
						font-weight: bold;
					}

					/* Responsive Design */
					@media (max-width: 768px) {
						.container {
							width: 95%;
						}

						table {
							font-size: 0.9rem;
						}

						th, td {
							padding: 8px;
						}
					}

					hr.glowing-line {
						border: none;
						height: 2px;
						background-color: lightgrey;
						box-shadow: 0 0 10px rgba(0, 123, 255, 0.6);
						width: 100%;
						margin-top: 0px;
						margin-bottom: 15px;
					}
				</style>
			</head>
			<body>
				<div class="container">
					<h1 align="center">Scenario Options</h1>
					<table>
						<tr>
							<td>
								<p><h2>Difficulty Selection</h2></p>
								<hr class="glowing-line">
								<label class="radio-option">
									<input type="radio" name="scenario_difficulty" value="easy">
									<span><b>Easy:</b> Russian side proficiency is reduced, and all Zircon missiles are removed from Russian surface ships.</span>
								</label>
								<label class="radio-option">
									<input type="radio" name="scenario_difficulty" value="medium" checked>
									<div class="radio-description">
										<span><b>Medium:</b> Amount of Zircon missiles on Russian surface ships are cut in half. Russian navy proficiency is reduced.</span>
									</div>
								</label>						
								<label class="radio-option">
									<input type="radio" name="scenario_difficulty" value="hard">
									<div class="radio-description">
										<span><b>Hard:</b> Real life standard, no reduction in Russian armament or proficiency.</span>
									</div>
								</label>
							</td>
						</tr>
						<tr>
							<td>
								<p><h2>Extras</h2></p>
								<hr class="glowing-line">
								<span><b>Add Mk70 PDS to USS Savannah? </b></span>
								<span>
									<select name="use_alternative_lcs">
										<option value="use_alternative_lcs_true">Yes</option>
										<option value="use_alternative_lcs_false" selected>No</option>			
										<!-- Add more options here -->
									</select>
								</span>
								<p>Replaces flight facilities and 2x MH-60R Seahawks with Mk70 PDS armed with SM-6 Blk 1B.</p>
							</td>
						</tr>
					</table>
				</div>
			</body>
		</html>
	]]

	local form = UI_CallAdvancedHTMLDialog('Difficulty', html, {'Submit'})
	if form['pressed'] and form['pressed'] == 'Submit' then

		-- =========================
		-- Scenario Difficulty Selection
		-- =========================

		local SelectedDifficulty = string.gsub(form['scenario_difficulty'], "%'", "")
		if SelectedDifficulty == 'easy' then
			-- Sets Russia side proficency to cadet
			-- Removes all hypersonics from the Petr Velikiy

			ScenEdit_SetSideOptions({side='Russia', PROFICIENCY=1})
			ScenEdit_AddReloadsToUnit({side='Russia', guid='0LXD63-0HMSEP46PGDFN', wpn_dbid=3361, number=80, remove=true})
			ScenEdit_SpecialMessage('NATO', 'Scenario set to easy difficulty.')
		elseif SelectedDifficulty == 'medium' then
			-- Lowers the proficiency of Russian ships
			-- Removes half of the hypersonics on the Petr Velikiy

			local RussianNavy = {
				-- Defines ships effected by Medium difficulty
				{name='SSV Yug [Pr.862.1/2]', guid='0LXD63-0HMSEP46PHHJR'},
				{name='SSV Yury Ivanov [Pr.18280]', guid='0LXD63-0HMSEP46PI8VQ'},
				{name='MPK Grisha III [Pr.1124M Albatros]', guid='0LXD63-0HMSEP46PGK29'},
				{name='BPK Udaloy I [Pr.1155 Fregat]', guid='0LXD63-0HMSEP46PGJK3'},
				{name='VTR Boris Chilikin [Pr.1559V]', guid='0LXD63-0HMSEP46PGO45'},
				{name='RKR Petr Velikiy [Pr.1144.2M Orlan, Ex-Yuri Androvo]', guid='0LXD63-0HMSEP46PGDFN'},
				{name='PLA-671RTMK Victor III [Shchuka]', guid='0LXD63-0HMSEP46PNV25'},
				{name='PLA-885M Severodvinsk [Yasen-M]', guid='0LXD63-0HMSEP46PMUI0'},
				{name='MPK Grisha III [Pr.1124M Albatros]', guid='0LXD63-0HMSEP46PI1AR'},
				{name='BPK Udaloy I [Pr.1155 Fregat]', guid='0LXD63-0HMSEP46PI5EC'},
				{name='LDK Arktika', guid='0LXD63-0HMSEP46PIL5A'}
			}

			for _, ship in ipairs(RussianNavy) do
				ScenEdit_SetUnit({side='Russia', guid=ship.guid, proficiency='1'})
			end

			ScenEdit_AddReloadsToUnit({side='Russia', guid='0LXD63-0HMSEP46PGDFN', wpn_dbid=3361, number=40, remove=true})
			ScenEdit_SpecialMessage('NATO', 'Scenario set to medium difficulty.')
		else
			-- Does nothing but closes out the other options
			ScenEdit_SpecialMessage('NATO', 'Scenario set to hard difficulty.')
		end

		local SelectedOption = string.gsub(form['use_alternative_lcs'], "%'", "")
		if SelectedOption == 'use_alternative_lcs_true' then
			ScenEdit_DeleteUnit({guid='BI5B3D-0HMUC5RIDU5H6'})

			local ship = ScenEdit_AddUnit({type='Ship', unitname='LCS 28 Savannah', side='NATO', dbid=4584, latitude=72.1054297519102, longitude=-178.4203667614, speed=18, heading=250})
			ScenEdit_AddUnit({type='Ship',unitname='Generic RHIB [7m]', side='NATO', dbid=2315, base=ship.guid})
			ScenEdit_AddUnit({type='Ship',unitname='Generic RHIB [7m]', side='NATO', dbid=2315, base=ship.guid})

			ship.group = 'Michael Monsoor SAG'
		end
	end
end

-- ==========================
-- Scenario Initialization --
-- ==========================

local function ThisIsFirstLoad(booleanValue)
	local result
	if booleanValue == nil then
		result = ScenEdit_GetKeyValue('firstLoad')
		if result == '' or result == nil then result = true end
		if result == 'false' then result = false end
	else
		if booleanValue == true then
			ScenEdit_ClearKeyValue('firstLoad')
			result = true
		elseif booleanValue == false then
			ScenEdit_SetKeyValue('firstLoad','false')
			result = false
		end
	end
	return result
end

if ThisIsFirstLoad() then
	if inDevelopment then -- Ask to do stuff
		userInput = string.upper(ScenEdit_MsgBox('Initialize scenarios?', 1))
		if userInput == 'OK' then
			ScenarioSetup()
		end

		userInput = string.upper(ScenEdit_MsgBox('Set firstLoad key value to false?', 1))
		if userInput == 'OK' then
			ThisIsFirstLoad(false)
		end
	else -- Don't give the option and just do it
		ScenarioSetup()
		ThisIsFirstLoad(false)
	end
end