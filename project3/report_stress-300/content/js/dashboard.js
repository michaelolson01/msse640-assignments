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

    var data = {"OkPercent": 0.6876556308598402, "KoPercent": 99.31234436914016};
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
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [0.005987446305754724, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.006373829104467916, 500, 1500, "List Users"], "isController": false}, {"data": [0.005054409615072275, 500, 1500, "User Workflow"], "isController": true}, {"data": [0.006178983271073575, 500, 1500, "Delete User"], "isController": false}, {"data": [0.006342432922195593, 500, 1500, "Create User"], "isController": false}]}, function(index, item){
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
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 2309150, 2293271, 99.31234436914016, 11.69925167269376, 0, 8779, 1.0, 6.0, 13.0, 1121.9200000000128, 19045.635624324703, 32321.15029804556, 1813.6193703579795], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["List Users", 769710, 764358, 99.3046731886035, 11.211393901599429, 0, 7217, 1.0, 4.0, 11.0, 479.9300000000112, 6355.147131675419, 15476.02253469814, 387.37282336768055], "isController": false}, {"data": ["User Workflow", 769625, 764481, 99.33162254344649, 34.810744193600364, 0, 13519, 5.0, 16.0, 23.0, 1044.0, 6344.701653723764, 32210.811080312462, 1812.4438546200804], "isController": true}, {"data": ["Delete User", 769625, 764481, 99.33162254344649, 11.678863082670143, 0, 8779, 1.0, 6.0, 12.0, 1014.9900000000016, 6354.812606825257, 8437.472705050306, 685.748220611185], "isController": false}, {"data": ["Create User", 769815, 764432, 99.30074108714432, 12.207426459603987, 0, 7027, 1.0, 6.0, 12.0, 1005.9900000000016, 6349.356251494932, 8433.191181655848, 741.6619944682374], "isController": false}]}, function(index, item){
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
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": [{"data": ["Non HTTP response code: org.apache.http.NoHttpResponseException/Non HTTP response message: localhost:8081 failed to respond", 154, 0.0067152988024529155, 0.006669120672108785], "isController": false}, {"data": ["503/Service Unavailable", 1146401, 49.98977443136899, 49.64601693263755], "isController": false}, {"data": ["Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 1145652, 49.9571136599207, 49.613580754823204], "isController": false}, {"data": ["404/Not Found", 206, 0.008982802294190264, 0.008921031548405258], "isController": false}, {"data": ["Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 519, 0.022631429080993918, 0.022475802784574412], "isController": false}, {"data": ["Non HTTP response code: org.apache.http.conn.HttpHostConnectException/Non HTTP response message: Connect to localhost:8081 [localhost/127.0.0.1, localhost/0:0:0:0:0:0:0:1] failed: Connection refused (Connection refused)", 22, 9.593284003504165E-4, 9.527315245869692E-4], "isController": false}, {"data": ["Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 317, 0.01382305013232191, 0.01372799514973042], "isController": false}]}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 2309150, 2293271, "503/Service Unavailable", 1146401, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 1145652, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 519, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 317, "404/Not Found", 206], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": ["List Users", 769710, 764358, "503/Service Unavailable", 382092, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 381962, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 162, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 84, "Non HTTP response code: org.apache.http.NoHttpResponseException/Non HTTP response message: localhost:8081 failed to respond", 51], "isController": false}, {"data": [], "isController": false}, {"data": ["Delete User", 769625, 764481, "503/Service Unavailable", 382109, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 381828, "404/Not Found", 206, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 186, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 91], "isController": false}, {"data": ["Create User", 769815, 764432, "503/Service Unavailable", 382200, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Connection reset", 381862, "Non HTTP response code: java.net.SocketException/Non HTTP response message: Broken pipe (Write failed)", 171, "Non HTTP response code: java.net.SocketTimeoutException/Non HTTP response message: Read timed out", 142, "Non HTTP response code: org.apache.http.NoHttpResponseException/Non HTTP response message: localhost:8081 failed to respond", 48], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});
