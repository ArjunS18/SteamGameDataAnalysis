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

• For the top 100 games, split the data into training and test set and performed KNN clustering based on total player count.

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

---------------------

<!DOCTYPE HTML>
<html>
<head>
    <meta charset="utf-8" />
    <title>Convert Excel to HTML Table using JavaScript</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.15.1/xlsx.full.min.js"></script>
</head>
<body>
    <div class="container">
        <h2 class="text-center mt-4 mb-4">Convert Excel to HTML Table using JavaScript</h2>
        <div class="card">
            <div class="card-header"><b>Select Excel File</b></div>
            <div class="card-body">
                <input type="file" id="excel_file" />
                <button id="back_button" class="btn btn-secondary mt-3">Back</button>
                <button id="submit_button" class="btn btn-primary mt-3" disabled>Submit</button>
            </div>
        </div>
        <div id="excel_data" class="mt-5"></div>
    </div>
</body>
</html>

<script>
const excel_file = document.getElementById('excel_file');
const submit_button = document.getElementById('submit_button');
const back_button = document.getElementById('back_button');

excel_file.addEventListener('change', (event) => {
    if (!['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/vnd.ms-excel'].includes(event.target.files[0].type)) {
        document.getElementById('excel_data').innerHTML = '<div class="alert alert-danger">Only .xlsx or .xls file format are allowed</div>';
        excel_file.value = '';
        return false;
    }

    var reader = new FileReader();
    reader.readAsArrayBuffer(event.target.files[0]);

    reader.onload = function (event) {
        var data = new Uint8Array(reader.result);
        var work_book = XLSX.read(data, { type: 'array' });
        var sheet_name = work_book.SheetNames;
        var sheet_data = XLSX.utils.sheet_to_json(work_book.Sheets[sheet_name[0]], { header: 1 });

        if (sheet_data.length > 0) {
            var table_output = '<table class="table table-striped table-bordered">';
            var columnsToCheck = ['Column1', 'Column2']; // Replace with the actual column titles to check for null values
            var duplicateCheckColumn = 'Column1'; // Replace with the actual column title to check for duplicates

            // Get the indexes of the specific columns to check for null values
            var columnIndexesToCheck = [];
            for (var headerCell = 0; headerCell < sheet_data[0].length; headerCell++) {
                if (columnsToCheck.includes(sheet_data[0][headerCell])) {
                    columnIndexesToCheck.push(headerCell);
                }
            }

            // Get the index of the column to check for duplicates
            var duplicateCheckIndex = sheet_data[0].indexOf(duplicateCheckColumn);
            var seenValues = new Set();
            var hasErrors = false;

            for (var row = 0; row < sheet_data.length; row++) {
                table_output += '<tr>';
                for (var cell = 0; cell < sheet_data[row].length; cell++) {
                    if (row == 0) {
                        table_output += '<th>' + sheet_data[row][cell] + '</th>';
                    } else {
                        let cellContent = sheet_data[row][cell];
                        let style = '';

                        if (columnIndexesToCheck.includes(cell) && (cellContent === null || cellContent === '')) {
                            style = 'background-color: red;';
                            hasErrors = true;
                        }

                        if (cell === duplicateCheckIndex) {
                            if (seenValues.has(cellContent)) {
                                style = 'background-color: red;';
                                hasErrors = true;
                            } else {
                                seenValues.add(cellContent);
                            }
                        }

                        table_output += `<td style="${style}">${cellContent}</td>`;
                    }
                }
                table_output += '</tr>';
            }

            table_output += '</table>';
            document.getElementById('excel_data').innerHTML = table_output;
            submit_button.disabled = hasErrors;
        }
        excel_file.value = '';
    }
});

submit_button.addEventListener('click', () => {
    const table = document.querySelector('#excel_data table');
    if (table) {
        const rows = table.querySelectorAll('tr');
        let data = [];
        rows.forEach(row => {
            let rowData = [];
            const cells = row.querySelectorAll('th, td');
            cells.forEach(cell => {
                rowData.push(cell.textContent);
            });
            data.push(rowData);
        });

        fetch('/home/test_index/upload', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).then(response => {
            if (response.ok) {
                alert('Data successfully submitted!');
            } else {
                alert('Failed to submit data.');
            }
        }).catch(error => {
            alert('An error occurred: ' + error.message);
        });
    }
});

back_button.addEventListener('click', () => {
    // Implement the back button functionality here
    // For now, just refreshing the page to reset the state
    location.reload();
});
</script>

