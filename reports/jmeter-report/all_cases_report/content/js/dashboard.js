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

    var data = {"OkPercent": 100.0, "KoPercent": 0.0};
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
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [0.8225806451612904, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.5, 500, 1500, "19.1 Conversation "], "isController": false}, {"data": [1.0, 500, 1500, "6.1 Forgot Password - User Exists"], "isController": false}, {"data": [1.0, 500, 1500, "5.2 Reset Password - empty resetToken "], "isController": false}, {"data": [1.0, 500, 1500, "11.1 Block User"], "isController": false}, {"data": [1.0, 500, 1500, "5.3 Reset Password - empty userSecret"], "isController": false}, {"data": [1.0, 500, 1500, "5.4 Reset Password - no content"], "isController": false}, {"data": [1.0, 500, 1500, "2.2 Registration Request - Opt-In Marketing"], "isController": false}, {"data": [1.0, 500, 1500, "4.2 Activate Account - missing Token"], "isController": false}, {"data": [0.5, 500, 1500, "13.1 MyGumtree Screen"], "isController": false}, {"data": [1.0, 500, 1500, "1.2 Login - Incorrect Password"], "isController": false}, {"data": [1.0, 500, 1500, "14.2 Cancel favourites ads"], "isController": false}, {"data": [1.0, 500, 1500, "6.4 Forgot Password - Missing Email"], "isController": false}, {"data": [0.5, 500, 1500, "20.1 Reviews Conversation "], "isController": false}, {"data": [0.5, 500, 1500, "7.1 Ad Posted Analytics Event"], "isController": false}, {"data": [0.5, 500, 1500, "12.1 VIP Screen"], "isController": false}, {"data": [0.5, 500, 1500, "3.1 Logout Request"], "isController": false}, {"data": [0.5, 500, 1500, "1.4 Login - Missing Password"], "isController": false}, {"data": [1.0, 500, 1500, "6.3 Forgot Password - Invalid Email Format"], "isController": false}, {"data": [0.5, 500, 1500, "17.1 Conversation Screen"], "isController": false}, {"data": [1.0, 500, 1500, "10.1 Promote Ad Screen"], "isController": false}, {"data": [0.5, 500, 1500, "4.3 Activate Account - Missing User "], "isController": false}, {"data": [1.0, 500, 1500, "15.1 Favourites Screen"], "isController": false}, {"data": [1.0, 500, 1500, "5.5 Reset Password - wrong info"], "isController": false}, {"data": [1.0, 500, 1500, "6.2 Forgot Password - User Does Not Exist"], "isController": false}, {"data": [1.0, 500, 1500, "11.2 Unblock User"], "isController": false}, {"data": [0.5, 500, 1500, "16.1 Chat Screen"], "isController": false}, {"data": [1.0, 500, 1500, "4.4 Activate Account - 500"], "isController": false}, {"data": [1.0, 500, 1500, "2.1 Registration Request - Opt-Out Marketing"], "isController": false}, {"data": [0.5, 500, 1500, "18.1 Conversation Unread Messages"], "isController": false}, {"data": [1.0, 500, 1500, "1.3 Login - Missing Username"], "isController": false}, {"data": [1.0, 500, 1500, "14.1 Favourites ads"], "isController": false}]}, function(index, item){
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
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 31, 0, 0.0, 436.83870967741933, 145, 1062, 471.0, 660.2, 979.1999999999998, 1062.0, 0.5137809304406914, 2.529979402149593, 0.5619802629398213], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["19.1 Conversation ", 1, 0, 0.0, 606.0, 606, 606, 606.0, 606.0, 606.0, 606.0, 1.6501650165016502, 0.8009101691419143, 2.613835602310231], "isController": false}, {"data": ["6.1 Forgot Password - User Exists", 1, 0, 0.0, 489.0, 489, 489, 489.0, 489.0, 489.0, 489.0, 2.044989775051125, 0.7269299591002045, 1.375974565439673], "isController": false}, {"data": ["5.2 Reset Password - empty resetToken ", 1, 0, 0.0, 407.0, 407, 407, 407.0, 407.0, 407.0, 407.0, 2.457002457002457, 1.1229269041769043, 1.6627956081081081], "isController": false}, {"data": ["11.1 Block User", 1, 0, 0.0, 471.0, 471, 471, 471.0, 471.0, 471.0, 471.0, 2.1231422505307855, 0.7153164808917197, 3.2282543789808917], "isController": false}, {"data": ["5.3 Reset Password - empty userSecret", 1, 0, 0.0, 145.0, 145, 145, 145.0, 145.0, 145.0, 145.0, 6.896551724137931, 3.151939655172414, 4.835668103448276], "isController": false}, {"data": ["5.4 Reset Password - no content", 1, 0, 0.0, 150.0, 150, 150, 150.0, 150.0, 150.0, 150.0, 6.666666666666667, 3.046875, 4.127604166666667], "isController": false}, {"data": ["2.2 Registration Request - Opt-In Marketing", 1, 0, 0.0, 228.0, 228, 228, 228.0, 228.0, 228.0, 228.0, 4.385964912280701, 1.567639802631579, 3.5250479714912277], "isController": false}, {"data": ["4.2 Activate Account - missing Token", 1, 0, 0.0, 433.0, 433, 433, 433.0, 433.0, 433.0, 433.0, 2.3094688221709005, 1.0509887413394918, 1.628355946882217], "isController": false}, {"data": ["13.1 MyGumtree Screen", 1, 0, 0.0, 924.0, 924, 924, 924.0, 924.0, 924.0, 924.0, 1.0822510822510822, 34.21245096049783, 1.6202059659090908], "isController": false}, {"data": ["1.2 Login - Incorrect Password", 1, 0, 0.0, 157.0, 157, 157, 157.0, 157.0, 157.0, 157.0, 6.369426751592357, 2.6373407643312103, 4.45984275477707], "isController": false}, {"data": ["14.2 Cancel favourites ads", 1, 0, 0.0, 394.0, 394, 394, 394.0, 394.0, 394.0, 394.0, 2.5380710659898473, 0.7733185279187816, 3.8641140545685277], "isController": false}, {"data": ["6.4 Forgot Password - Missing Email", 1, 0, 0.0, 171.0, 171, 171, 171.0, 171.0, 171.0, 171.0, 5.847953216374268, 2.6612755847953213, 3.7063687865497075], "isController": false}, {"data": ["20.1 Reviews Conversation ", 1, 0, 0.0, 557.0, 557, 557, 557.0, 557.0, 557.0, 557.0, 1.7953321364452424, 27.103554196588867, 2.7736478904847393], "isController": false}, {"data": ["7.1 Ad Posted Analytics Event", 1, 0, 0.0, 538.0, 538, 538, 538.0, 538.0, 538.0, 538.0, 1.858736059479554, 2.699160664498141, 2.7735827137546467], "isController": false}, {"data": ["12.1 VIP Screen", 1, 0, 0.0, 608.0, 608, 608, 608.0, 608.0, 608.0, 608.0, 1.644736842105263, 23.384495785361842, 2.4687114514802633], "isController": false}, {"data": ["3.1 Logout Request", 1, 0, 0.0, 546.0, 546, 546, 546.0, 546.0, 546.0, 546.0, 1.8315018315018314, 0.6510416666666666, 2.7866014194139193], "isController": false}, {"data": ["1.4 Login - Missing Password", 1, 0, 0.0, 541.0, 541, 541, 541.0, 541.0, 541.0, 541.0, 1.8484288354898337, 0.8285437846580406, 1.2653795055452863], "isController": false}, {"data": ["6.3 Forgot Password - Invalid Email Format", 1, 0, 0.0, 374.0, 374, 374, 374.0, 374.0, 374.0, 374.0, 2.6737967914438503, 1.2220086898395721, 1.7964572192513368], "isController": false}, {"data": ["17.1 Conversation Screen", 1, 0, 0.0, 621.0, 621, 621, 621.0, 621.0, 621.0, 621.0, 1.6103059581320451, 61.21206974637681, 2.4154589371980677], "isController": false}, {"data": ["10.1 Promote Ad Screen", 1, 0, 0.0, 430.0, 430, 430, 430.0, 430.0, 430.0, 430.0, 2.3255813953488373, 10.11764171511628, 3.3634629360465116], "isController": false}, {"data": ["4.3 Activate Account - Missing User ", 1, 0, 0.0, 1062.0, 1062, 1062, 1062.0, 1062.0, 1062.0, 1062.0, 0.9416195856873822, 0.4303495762711864, 0.6666740230696798], "isController": false}, {"data": ["15.1 Favourites Screen", 1, 0, 0.0, 480.0, 480, 480, 480.0, 480.0, 480.0, 480.0, 2.0833333333333335, 64.862060546875, 3.118896484375], "isController": false}, {"data": ["5.5 Reset Password - wrong info", 1, 0, 0.0, 168.0, 168, 168, 168.0, 168.0, 168.0, 168.0, 5.952380952380952, 2.9471261160714284, 4.237583705357142], "isController": false}, {"data": ["6.2 Forgot Password - User Does Not Exist", 1, 0, 0.0, 160.0, 160, 160, 160.0, 160.0, 160.0, 160.0, 6.25, 3.082275390625, 4.2724609375], "isController": false}, {"data": ["11.2 Unblock User", 1, 0, 0.0, 195.0, 195, 195, 195.0, 195.0, 195.0, 195.0, 5.128205128205129, 1.5574919871794872, 7.797475961538462], "isController": false}, {"data": ["16.1 Chat Screen", 1, 0, 0.0, 670.0, 670, 670, 670.0, 670.0, 670.0, 670.0, 1.492537313432836, 10.823810634328357, 2.279617537313433], "isController": false}, {"data": ["4.4 Activate Account - 500", 1, 0, 0.0, 178.0, 178, 178, 178.0, 178.0, 178.0, 178.0, 5.617977528089887, 2.770584620786517, 4.142161165730338], "isController": false}, {"data": ["2.1 Registration Request - Opt-Out Marketing", 1, 0, 0.0, 473.0, 473, 473, 473.0, 473.0, 473.0, 473.0, 2.1141649048625792, 0.75151955602537, 1.6867897727272727], "isController": false}, {"data": ["18.1 Conversation Unread Messages", 1, 0, 0.0, 616.0, 616, 616, 616.0, 616.0, 616.0, 616.0, 1.6233766233766236, 0.6119368912337663, 2.4636008522727275], "isController": false}, {"data": ["1.3 Login - Missing Username", 1, 0, 0.0, 271.0, 271, 271, 271.0, 271.0, 271.0, 271.0, 3.6900369003690034, 1.6612373154981548, 2.490054197416974], "isController": false}, {"data": ["14.1 Favourites ads", 1, 0, 0.0, 479.0, 479, 479, 479.0, 479.0, 479.0, 479.0, 2.08768267223382, 0.6320133089770356, 3.2008415970772446], "isController": false}]}, function(index, item){
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
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": []}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 31, 0, "", "", "", "", "", "", "", "", "", ""], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});
