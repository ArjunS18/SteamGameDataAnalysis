# SteamGameDataAnalysis
•	Took Steam Data set from the kaggle website.
https://www.kaggle.com/connorwynkoop/steam-monthly-player-data

•	The key columns in the data set are (Name of the game, Average players, Gain, Gain %, Peak player count)

• Wrote functions to perform data filtering, normalizing, drawing graph and much more to enable code reuse.

• Performed Descriptive Statistics on the data as a part of exploratory data analysis

• Computed Top 10 games based on player count for any year based on input dataframe

• Visualized the output in a time series graph and made the graph interactive with Plotly package

• Performed hypothesis testing based on user input on the data. Visualized the output in normal distribution graph.

• Performed multivariate regression analysis on the data based on categorical variable month and predicted the output for future years

• Computed Mean Absolute Percentage Error (MAPE). Achieved 96% accuracy with the regression model.

• For top 100 games, split the data into training and test set and performed KNN clustering based on total player count.

==========
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Excel to Table</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        .highlight {
            background-color: red;
            color: white;
        }
    </style>
</head>
<body>
    <h1>Upload Excel File</h1>
    <input type="file" id="upload" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.9/xlsx.full.min.js"></script>
    <script>
        document.getElementById('upload').addEventListener('change', handleFile, false);

        function handleFile(event) {
            const file = event.target.files[0];
            const reader = new FileReader();

            reader.onload = function(e) {
                const data = new Uint8Array(e.target.result);
                const workbook = XLSX.read(data, { type: 'array' });
                const firstSheet = workbook.Sheets[workbook.SheetNames[0]];
                const jsonData = XLSX.utils.sheet_to_json(firstSheet, { header: 1 });
                const mandatoryColumns = [0, 1]; // Adjust the indexes of mandatory columns
                localStorage.setItem('tableData', JSON.stringify({ data: jsonData, mandatoryColumns }));
                window.location.href = 'table.html';
            };

            reader.readAsArrayBuffer(file);
        }
    </script>
</body>
</html>
================

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table View</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        .highlight {
            background-color: red;
            color: white;
        }
    </style>
</head>
<body>
    <h1>Excel Data</h1>
    <div id="tableContainer"></div>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const tableData = JSON.parse(localStorage.getItem('tableData'));
            const data = tableData.data;
            const mandatoryColumns = tableData.mandatoryColumns;
            const tableContainer = document.getElementById('tableContainer');
            const table = document.createElement('table');

            data.forEach((row, rowIndex) => {
                const tr = document.createElement('tr');
                row.forEach((cell, colIndex) => {
                    const cellElement = rowIndex === 0 ? document.createElement('th') : document.createElement('td');
                    cellElement.textContent = cell || '';
                    if (mandatoryColumns.includes(colIndex) && (cell === null || cell === undefined || cell === '')) {
                        cellElement.classList.add('highlight');
                    }
                    tr.appendChild(cellElement);
                });
                table.appendChild(tr);
            });

            tableContainer.appendChild(table);
        });
    </script>
</body>
</html>
