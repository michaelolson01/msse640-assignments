/*
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
var showControllersOnly = false;
var seriesFilter = "";
var filtersOnlySampleSeries = true;

/*
 * Add header in statistics table to group metrics by category
 * format
 *
 */
function summaryTableHeader(header) {
    var newRow = header.insertRow(-1);
    newRow.className = "tablesorter-no-sort";
    var cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Requests";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 3;
    cell.innerHTML = "Executions";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 7;
    cell.innerHTML = "Response Times (ms)";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Throughput";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 2;
    cell.innerHTML = "Network (KB/sec)";
    newRow.appendChild(cell);
}

/*
 * Populates the table identified by id parameter with the specified data and
 * format
 *
 */
function createTable(table, info, formatter, defaultSorts, seriesIndex, headerCreator) {
    var tableRef = table[0];

    // Create header and populate it with data.titles array
    var header = tableRef.createTHead();

    // Call callback is available
    if(headerCreator) {
        headerCreator(header);
    }

    var newRow = header.insertRow(-1);
    for (var index = 0; index < info.titles.length; index++) {
        var cell = document.createElement('th');
        cell.innerHTML = info.titles[index];
        newRow.appendChild(cell);
    }

    var tBody;

    // Create overall body if defined
    if(info.overall){
        tBody = document.createElement('tbody');
        tBody.className = "tablesorter-no-sort";
        tableRef.appendChild(tBody);
        var newRow = tBody.insertRow(-1);
        var data = info.overall.data;
        for(var index=0;index < data.length; index++){
            var cell = newRow.insertCell(-1);
            cell.innerHTML = formatter ? formatter(index, data[index]): data[index];
        }
    }

    // Create regular body
    tBody = document.createElement('tbody');
    tableRef.appendChild(tBody);

    var regexp;
    if(seriesFilter) {
        regexp = new RegExp(seriesFilter, 'i');
    }
    // Populate body with data.items array
    for(var index=0; index < info.items.length; index++){
        var item = info.items[index];
        if((!regexp || filtersOnlySampleSeries && !info.supportsControllersDiscrimination || regexp.test(item.data[seriesIndex]))
                &&
                (!showControllersOnly || !info.supportsControllersDiscrimination || item.isController)){
            if(item.data.length > 0) {
                var newRow = tBody.insertRow(-1);
                for(var col=0; col < item.data.length; col++){
                    var cell = newRow.insertCell(-1);
                    cell.innerHTML = formatter ? formatter(col, item.data[col]) : item.data[col];
                }
            }
        }
    }

    // Add support of columns sort
    table.tablesorter({sortList : defaultSorts});
}

$(document).ready(function() {

    // Customize table sorter default options
    $.extend( $.tablesorter.defaults, {
        theme: 'blue',
        cssInfoBlock: "tablesorter-no-sort",
        widthFixed: true,
        widgets: ['zebra']
    });

    var data = {"OkPercent": 0.814262207468053, "KoPercent": 99.18573779253195};
    var dataset = [
        {
            "label" : "FAIL",
            "data" : data.KoPercent,
            "color" : "#FF6347"
        },
        {
            "label" : "PASS",
            "data" : data.OkPercent,
            "color" : "#9ACD32"
        }];
    $.plot($("#flot-requests-summary"), dataset, {
        series : {
            pie : {
                show : true,
                radius : 1,
                label : {
                    show : true,
                    radius : 3 / 4,
                    formatter : function(label, series) {
                        return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'
                            + label
                            + '<br/>'
                            + Math.round10(series.percent, -2)
                            + '%</div>';
                    },
                    background : {
                        opacity : 0.5,
                        color : '#000'
                    }
                }
            }
        },
        legend : {
            show : true
        }
    });

    // Creates APDEX table
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [0.006939323660184338, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.007432677056754706, 500, 1500, "List Users"], "isController": false}, {"data": [0.005666070389448048, 500, 1500, "User Workflow"], "isController": true}, {"data": [0.007263087566542382, 500, 1500, "Delete User"], "isController": false}, {"data": [0.007395329794646, 500, 1500, "Create User"], "isController": false}]}, function(index, item){
        switch(index){
            case 0:
                item = item.toFixed(3);
                break;
            case 1:
            case 2:
                item = formatDuration(item);
                break;
        }
        return item;
    }, [[0, 0]], 3);

    // Create statistics table
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 2088148, 2071145, 99.18573779253195, 8.583578845943531, 0, 5015, 1.0, 3.0, 9.0, 456.950000000008, 17259.98908928601, 25966.10615693347, 1645.5640579538692], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["List Users", 696048, 690333, 99.17893593545273, 8.363770889364064, 0, 5012, 2.0, 3.0, 10.0, 53.0, 5756.459029408846, 10704.846139313657, 351.34573019699627], "isController": false}, {"data": ["User Workflow", 695985, 690444, 99.20386215220155, 25.528278626694405, 0, 13175, 5.0, 13.0, 19.0, 1017.0, 5750.373864978973, 25921.917319617893, 1644.6448715174786], "isController": true}, {"data": ["Delete User", 695985, 690444, 99.20386215220155, 8.338984317190915, 0, 5015, 1.0, 3.0, 10.0, 54.0, 5756.080818439705, 7635.670911755767, 622.1453276968771], "isController": false}, {"data": ["Create User", 696115, 690368, 99.17441802001106, 9.047914496886493, 0, 5008, 1.0, 3.0, 10.0, 58.0, 5753.87247689739, 7635.783854984626, 672.6195015709982], "isController": false}]}, function(index, item){
        switch(index){
            // Errors pct
            case 3:
                item = item.toFixed(2) + '%';
                break;
            // Mean
            case 4:
            // Mean
            case 7:
            // Median
            case 8:
            // Percentile 1
            case 9:
            // Percentile 2
            case 10:
            // Percentile 3
            case 11:
            // Throughput
            case 12:
            // Kbytes/s
            case 13:
            // Sent Kbytes/s
                item = item.toFixed(2);
                break;
        }
        return item;
    }, [[0, 0]], 0, summaryTableHeader);

    // Create error table
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": [{"data": ["503/Service Unavailable", 1035390, 49.991188448901454, 49.584129094297914], "isController": false}, {"data": ["Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 1035012, 49.97293767457131, 49.56602692912571], "isController": false}, {"data": ["Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 324, 0.01564352085440662, 0.015516141576171804], "isController": false}, {"data": ["404/Not Found", 157, 0.0075803480683390104, 0.007518624158823991], "isController": false}, {"data": ["Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 262, 0.012650007604489304, 0.012547003373324112], "isController": false}]}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 2088148, 2071145, "503/Service Unavailable", 1035390, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 1035012, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 324, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 262, "404/Not Found", 157], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": ["List Users", 696048, 690333, "503/Service Unavailable", 345115, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 345017, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 126, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 75, "", ""], "isController": false}, {"data": [], "isController": false}, {"data": ["Delete User", 695985, 690444, "503/Service Unavailable", 345113, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 345001, "404/Not Found", 157, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 99, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 74], "isController": false}, {"data": ["Create User", 696115, 690368, "503/Service Unavailable", 345162, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 344994, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 113, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 99, "", ""], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});
