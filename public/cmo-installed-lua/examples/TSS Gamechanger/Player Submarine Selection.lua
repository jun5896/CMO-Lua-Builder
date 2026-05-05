local html = [[
	<html>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>Submarine Selection</title>
			<style>
				body {
					font-family: "Courier New", Courier, monospace;
					color: #ffffff;
					text-align: left;
					padding: 20px;
				}

				.container {
					border: 2px solid #ffffff;
					padding: 0px 15px 15px 15px;
					max-width: 800px;
					margin: auto;
				}

				h1 {
					font-size: 20px;
					text-align: center;
					text-decoration: underline;
				}

				table {
					border-collapse: collapse;
					width: 100%;
					margin: auto;
					font-family: "Courier New", Courier, monospace;
				}

				th, td {
					border: 1px solid #ffffff;
					padding: 10px;
					vertical-align: top;
				}

				.radio-option {
					display: flex;
					align-items: center;
					margin-bottom: 15px;
				}

				.radio-option input[type="radio"] {
					margin-right: 10px;
				transform: scale(1.1);
			}

			.radio-label {
				line-height: 1.2;
			}
		</style>
	</head>
	<body>
		<div class="container">
			<h1>Submarine Selection</h1>
			<br>
			<div class="radio-option">
				<input type="radio" name="submarine_selector" value="nautilus">
				<label for="nautilus" class="radio-label">Take command of the <b>USS Nautilus (SSN-571)</b>, the first nuclear-powered submarine in the US Navy.</label>
			</div>
			<div class="radio-option">
				<input type="radio" name="submarine_selector" value="razorback">
				<label for="razorback" class="radio-label">Take command of the <b>USS Razorback (SS-394)</b>, a WW2 veteran modernized through the GUPPY-IIA program, one of the most capable submarines in the US Navy.</label>
			</div>
		</div>
	</body>
</html>
]]

form = UI_CallAdvancedHTMLDialog('Title', html, {'Done'})

local submarine = string.gsub(form['submarine_selector'], "%'", "")
if submarine == 'nautilus' then
	print('Player selects USS Nautilus (SSN-571)')
	ScenEdit_DeleteUnit({guid='141c01f2-571c-44d3-b984-f57f42be5c73'}) -- Deletes the USS Razorback (SS-394)
else
	print('Player selects USS Razorback (SS-394)')
	ScenEdit_DeleteUnit({guid='6d63f3a5-a7d7-41a2-8712-1324494f74c0'}) -- Deletes the USS Nautilus (SSN-571)
end