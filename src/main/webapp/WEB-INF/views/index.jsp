<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<meta name="description" content="">
<meta name="author" content="">
	<title>BINANCE</title>
	<!-- Custom fonts for this template-->
	<link href="../resources/vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
	<link
	    href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
	    rel="stylesheet">
    <!-- Custom styles for this template-->
    <link href="../resources/css/sb-admin-2.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.3.js"></script>
    <script src="../resources/js/jspdf.min.js"></script>
    <script src="../resources/js/html2canvas.js"></script>
    <script type="text/javascript"
        src="//dapi.kakao.com/v2/maps/sdk.js?appkey=b2cb364ccef277f6f382233c812a84a9"></script>
</head>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    $(document).ready(function () {
    	setInterval(() => {
    		
    		$.ajax({
    			url:"/sensor/resultData",
    			type:"GET",
    			dataType :"json",
    			success:function(result){
    				var d = new Date();	
    				var hur = d.getHours();
    				var min = d.getMinutes();	
    				var sec = d.getSeconds();	
    				var time = "현재 시간 : " + hur + "시 " + min + "분 " + sec + "초"	
    				console.log(result.temp+","+result.humi)
    				$("#temp_humi").empty();
    				$("#temp_humi").append("<i class='fas fa-regular fa-clock' style='color: #22d0d3;'></i>"+"&nbsp;<span>"+time+"</span>");
  				  $("#temp_humi").append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class='fas fa-light fa-temperature-high' style='color: #db0000;'></i>"+"&nbsp;<span>온도 : "+result.temp+" ℃</span>");
  				  $("#temp_humi").append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class='fas fa-duotone fa-cloud' style='--fa-secondary-color: #1d5ecd;'></i>"+"&nbsp;<span>습도 : "+result.humi+" %</span>");
    			}
    		})
    	}, 1000);
    	$("#selectedMonth > option").each(function(){
    		if($(this).val() == "${selectedMonth}"){
    			$(this).prop("selected",true)
    		}
		})
        var container = $('#map')[0];
        var map = new kakao.maps.Map(container, {
            center: new kakao.maps.LatLng(${ lat }, ${ lng }),
            level: 3,
            draggable: false
        });
        var marker = new kakao.maps.Marker({
            // 지도 중심좌표에 마커를 생성합니다 
            position: map.getCenter()
        });
        marker.setMap(map);
        $("#chooseDate").change(function () {
            $.ajax({
                url: "/channelAjax?channel=" + $("#nowChannel").val() + "&chooseDate=" + $("#chooseDate").val(),
                type: 'GET',
                dataType: "JSON",
                success: function (result) {
                    $("#avgtilt").text(result['avgtilt'] + "º")
                    $("#maxmintilt").text(result['maxtilt'] + "º" + "/" + result['mintilt'] + "º")
                    $("#tempData").text(result['tempData'] + "℃")
                    $("#battData").text(result['battData'] + "%")
                    function number_format(number, decimals, dec_point, thousands_sep) {
                        // *     example: number_format(1234.56, 2, ',', ' ');
                        // *     return: '1 234,56'
                        number = (number + '').replace(',', '').replace(' ', '');
                        var n = !isFinite(+number) ? 0 : +number,
                            prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
                            sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
                            dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
                            s = '',
                            toFixedFix = function (n, prec) {
                                var k = Math.pow(10, prec);
                                return '' + Math.round(n * k) / k;
                            };
                        // Fix for IE parseFloat(0.55).toFixed(0) = 0;
                        s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
                        if (s[0].length > 3) {
                            s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
                        }
                        if ((s[1] || '').length < prec) {
                            s[1] = s[1] || '';
                            s[1] += new Array(prec - s[1].length + 1).join('0');
                        }
                        return s.join(dec);
                    }
                    $("#myAreaChart").remove();
                    $(".chart-area").append("<canvas id='myAreaChart'></canvas>")
                    var ctx = document.getElementById("myAreaChart");
                    var myLineChart = new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: result['channelDate'],
                            datasets: [{
                                label: "경사각",
                                lineTension: 0.3,
                                backgroundColor: "rgba(78, 115, 223, 0.05)",
                                borderColor: "rgba(78, 115, 223, 1)",
                                pointRadius: 3,
                                pointBackgroundColor: "rgba(78, 115, 223, 1)",
                                pointBorderColor: "rgba(78, 115, 223, 1)",
                                pointHoverRadius: 3,
                                pointHoverBackgroundColor: "rgba(78, 115, 223, 1)",
                                pointHoverBorderColor: "rgba(78, 115, 223, 1)",
                                pointHitRadius: 10,
                                pointBorderWidth: 2,
                                data: result['channelData'],
                            }],
                        },
                        options: {
                            maintainAspectRatio: false,
                            layout: {
                                padding: {
                                    left: 10,
                                    right: 25,
                                    top: 25,
                                    bottom: 0
                                }
                            },
                            scales: {
                                xAxes: [{
                                    time: {
                                        unit: 'date'
                                    },
                                    gridLines: {
                                        display: false,
                                        drawBorder: false
                                    },
                                    ticks: {
                                        maxTicksLimit: 7,
                                        callback: function (value, index, values) {
                                            return number_format(value) + " 시";
                                        }
                                    }
                                }],
                                yAxes: [{
                                    ticks: {
                                        maxTicksLimit: 5,
                                        padding: 10,
                                        // Include a dollar sign in the ticks
                                        callback: function (value, index, values) {
                                            return number_format(value) + " 도";
                                        }
                                    },
                                    gridLines: {
                                        color: "rgb(234, 236, 244)",
                                        zeroLineColor: "rgb(234, 236, 244)",
                                        drawBorder: false,
                                        borderDash: [2],
                                        zeroLineBorderDash: [2]
                                    }
                                }],
                            },
                            legend: {
                                display: false
                            },
                            tooltips: {
                                backgroundColor: "rgb(255,255,255)",
                                bodyFontColor: "#858796",
                                titleMarginBottom: 10,
                                titleFontColor: '#6e707e',
                                titleFontSize: 14,
                                borderColor: '#dddfeb',
                                borderWidth: 1,
                                xPadding: 15,
                                yPadding: 15,
                                displayColors: false,
                                intersect: false,
                                mode: 'index',
                                caretPadding: 10,
                                callbacks: {
                                    label: function (tooltipItem, chart) {
                                        var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
                                        return datasetLabel + ': ' + number_format(tooltipItem.yLabel) + " 도";
                                    }
                                }
                            }
                        }
                    });
                }
            });
        })
        $("a[data-channel]").click(function () {
            $("#channelName").text("채널별 경사각 (" + $(this).data("channel") + ")")
            $("#nowChannel").val($(this).data("channel"))
            $.ajax({
                url: "/channelAjax?channel=" + $(this).data("channel") + "&chooseDate=" + $("#chooseDate").val(),
                type: 'GET',
                dataType: "JSON",
                success: function (result) {
                    $("#avgtilt").text(result['avgtilt'] + "º")
                    $("#maxmintilt").text(result['maxtilt'] + "º" + "/" + result['mintilt'] + "º")
                    $("#tempData").text(result['tempData'] + "℃")
                    $("#battData").text(result['battData'] + "%")
                    $("#map").empty();
                    var container = $('#map')[0];
                    var map = new kakao.maps.Map(container, {
                        center: new kakao.maps.LatLng(result['lat'], result['lng']),
                        level: 3,
                        draggable: false
                    });
                    var marker = new kakao.maps.Marker({
                        // 지도 중심좌표에 마커를 생성합니다 
                        position: map.getCenter()
                    });
                    marker.setMap(map);
                    function number_format(number, decimals, dec_point, thousands_sep) {
                        // *     example: number_format(1234.56, 2, ',', ' ');
                        // *     return: '1 234,56'
                        number = (number + '').replace(',', '').replace(' ', '');
                        var n = !isFinite(+number) ? 0 : +number,
                            prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
                            sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
                            dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
                            s = '',
                            toFixedFix = function (n, prec) {
                                var k = Math.pow(10, prec);
                                return '' + Math.round(n * k) / k;
                            };
                        // Fix for IE parseFloat(0.55).toFixed(0) = 0;
                        s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
                        if (s[0].length > 3) {
                            s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
                        }
                        if ((s[1] || '').length < prec) {
                            s[1] = s[1] || '';
                            s[1] += new Array(prec - s[1].length + 1).join('0');
                        }
                        return s.join(dec);
                    }
                    $("#myAreaChart").remove();
                    $(".chart-area").append("<canvas id='myAreaChart'></canvas>")
                    var ctx = document.getElementById("myAreaChart");
                    var myLineChart = new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: result['channelDate'],
                            datasets: [{
                                label: "경사각",
                                lineTension: 0.3,
                                backgroundColor: "rgba(78, 115, 223, 0.05)",
                                borderColor: "rgba(78, 115, 223, 1)",
                                pointRadius: 3,
                                pointBackgroundColor: "rgba(78, 115, 223, 1)",
                                pointBorderColor: "rgba(78, 115, 223, 1)",
                                pointHoverRadius: 3,
                                pointHoverBackgroundColor: "rgba(78, 115, 223, 1)",
                                pointHoverBorderColor: "rgba(78, 115, 223, 1)",
                                pointHitRadius: 10,
                                pointBorderWidth: 2,
                                data: result['channelData'],
                            }],
                        },
                        options: {
                            maintainAspectRatio: false,
                            layout: {
                                padding: {
                                    left: 10,
                                    right: 25,
                                    top: 25,
                                    bottom: 0
                                }
                            },
                            scales: {
                                xAxes: [{
                                    time: {
                                        unit: 'date'
                                    },
                                    gridLines: {
                                        display: false,
                                        drawBorder: false
                                    },
                                    ticks: {
                                        maxTicksLimit: 7,
                                        callback: function (value, index, values) {
                                            return number_format(value) + " 시";
                                        }
                                    }
                                }],
                                yAxes: [{
                                    ticks: {
                                        maxTicksLimit: 5,
                                        padding: 10,
                                        // Include a dollar sign in the ticks
                                        callback: function (value, index, values) {
                                            return number_format(value) + " 도";
                                        }
                                    },
                                    gridLines: {
                                        color: "rgb(234, 236, 244)",
                                        zeroLineColor: "rgb(234, 236, 244)",
                                        drawBorder: false,
                                        borderDash: [2],
                                        zeroLineBorderDash: [2]
                                    }
                                }],
                            },
                            legend: {
                                display: false
                            },
                            tooltips: {
                                backgroundColor: "rgb(255,255,255)",
                                bodyFontColor: "#858796",
                                titleMarginBottom: 10,
                                titleFontColor: '#6e707e',
                                titleFontSize: 14,
                                borderColor: '#dddfeb',
                                borderWidth: 1,
                                xPadding: 15,
                                yPadding: 15,
                                displayColors: false,
                                intersect: false,
                                mode: 'index',
                                caretPadding: 10,
                                callbacks: {
                                    label: function (tooltipItem, chart) {
                                        var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
                                        return datasetLabel + ': ' + number_format(tooltipItem.yLabel) + " 도";
                                    }
                                }
                            }
                        }
                    });
                }
            });
        });
        $("#report").click(function () {
            if (confirm("pdf로 변환 하시겠습니까?")) {
                html2canvas($("#pdfDiv")[0]).then(function (canvas) {
                    // 캔버스를 이미지로 변환
                    let imgData = canvas.toDataURL('image/png');

                    let margin = 10; // 출력 페이지 여백설정
                    let imgWidth = 210 - (10 * 2); // 이미지 가로 길이(mm) A4 기준
                    let pageHeight = imgWidth * 1.414;  // 출력 페이지 세로 길이 계산 A4 기준
                    let imgHeight = canvas.height * imgWidth / canvas.width;
                    let heightLeft = imgHeight;

                    let doc = new jsPDF('p', 'mm');
                    let position = margin;

                    // 첫 페이지 출력
                    doc.addImage(imgData, 'PNG', margin, position, imgWidth, imgHeight);
                    heightLeft -= pageHeight;

                    // 한 페이지 이상일 경우 루프 돌면서 출력
                    while (heightLeft >= 20) {
                        position = heightLeft - imgHeight;
                        doc.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
                        doc.addPage();
                        heightLeft -= pageHeight;
                    }

                    // 파일 저장
                    doc.save('report.pdf');
                });
            } else {
                alert("취소 했습니다.")
            }
        })
        var addInterval
        $(".kakaoaddr").click(function (e) {
            tilt = $(this).data('tilt');
            addInterval = setInterval(() => {
                if ($("#changeAddress").val() != 'N') {
                    if (confirm(tilt + " 주소를 '" + $("#changeAddress").val() + "'로 변경하시겠습니까?.")) {
                        $.ajax({
                            url: "http://localhost:5500/latlngChange",
                            type: "post",
                            data: {
                                'addr': $("#changeAddress").val(),
                                'channel': tilt
                            }
                        })
                        $("#changeAddress").val("N")
                        alert("새로고침 하면 업데이트 됩니다.")
                    } else {
                        clearInterval(addInterval)
                        $("#changeAddress").val("N")
                    }
                }
            }, 1000);
            new daum.Postcode({
                oncomplete: function (data) {
                    $("#changeAddress").val(data.address)
                }
            }).open();
        });
        $("#makeDat").click(function () {
            if (confirm("dat 파일을 다운 받으시겠습니까?")) {
                $.ajax({
                    url: "http://localhost:5500/makeDat",
                    type: "get"
                })
                $(".container-fluid").append("<a href='/test/tiltData.dat' download='Data.dat' id='dataDownload'></a>")
                setTimeout(function () { $("#dataDownload")[0].click() }, 2000);
                setTimeout(function () { $("#dataDownload").remove() }, 3000);
            } else {
                alert("취소 했습니다.")
            }
        })
         $("#selectedMonth").change(function () {
        	 console.log($("#selectedMonth").val())
            $.ajax({
                url: "/getMonthAjax?selectedMonth=" + $("#selectedMonth").val(),
                type: 'GET',
                dataType: "JSON",
                success: function (result) {
        function number_format(number, decimals, dec_point, thousands_sep) {

        	  // *     example: number_format(1234.56, 2, ',', ' ');
        	  // *     return: '1 234,56'
        	  number = (number + '').replace(',', '').replace(' ', '');
        	  var n = !isFinite(+number) ? 0 : +number,
        	    prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
        	    sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
        	    dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
        	    s = '',
        	    toFixedFix = function(n, prec) {
        	      var k = Math.pow(10, prec);
        	      return '' + Math.round(n * k) / k;
        	    };
        	  // Fix for IE parseFloat(0.55).toFixed(0) = 0;
        	  s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
        	  if (s[0].length > 3) {
        	    s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
        	  }
        	  if ((s[1] || '').length < prec) {
        	    s[1] = s[1] || '';
        	    s[1] += new Array(prec - s[1].length + 1).join('0');
        	  }
        	  return s.join(dec);
        	}

        	// Bar Chart Example
        	$("#myBarChart").remove();
            $(".chart-bar").append("<canvas id='myBarChart'></canvas>")
        	var ctx = document.getElementById("myBarChart");
            var countDate =[]
            var countData =[]
            result.forEach(element => {
                countDate.push(element['formatted_date'])
                countData.push(element['count'])
            })
            console.log(countDate)
            console.log(countData)
			const maxValue = Math.max(...countData);
        	var myBarChart = new Chart(ctx, {
        	  type: 'bar',
        	  data: {
        	    labels: countDate,
        	    datasets: [{
        	      label: "누적",
        	      backgroundColor: "#4e73df",
        	      hoverBackgroundColor: "#2e59d9",
        	      borderColor: "#4e73df",
        	      data: countData,
        	    }],
        	  },
        	  options: {
        	    maintainAspectRatio: false,
        	    layout: {
        	      padding: {
        	        left: 10,
        	        right: 25,
        	        top: 25,
        	        bottom: 0
        	      }
        	    },
        	    scales: {
        	      xAxes: [{
        	        time: {
        	          unit: 'date'
        	        },
        	        gridLines: {
        	          display: false,
        	          drawBorder: false
        	        },
        	        ticks: {
        	          maxTicksLimit: 6
        	        },
        	        maxBarThickness: 25,
        	      }],
        	      
        	      yAxes: [{
        	        ticks: {
        	          min: 0,
        	          max: maxValue,
        	          maxTicksLimit: 5,
        	          padding: 10,
        	          // Include a dollar sign in the ticks
        	          callback: function(value, index, values) {
        	            return number_format(value) + '명';
        	          }
        	        },
        	        gridLines: {
        	          color: "rgb(234, 236, 244)",
        	          zeroLineColor: "rgb(234, 236, 244)",
        	          drawBorder: false,
        	          borderDash: [2],
        	          zeroLineBorderDash: [2]
        	        }
        	      }],
        	    },
        	    legend: {
        	      display: false
        	    },
        	    tooltips: {
        	      titleMarginBottom: 10,
        	      titleFontColor: '#6e707e',
        	      titleFontSize: 14,
        	      backgroundColor: "rgb(255,255,255)",
        	      bodyFontColor: "#858796",
        	      borderColor: '#dddfeb',
        	      borderWidth: 1,
        	      xPadding: 15,
        	      yPadding: 15,
        	      displayColors: false,
        	      caretPadding: 10,
        	      callbacks: {
        	        label: function(tooltipItem, chart) {
        	          var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
        	          return datasetLabel + number_format(tooltipItem.yLabel) + ': 명' ;
        	        }
        	      }
        	    },
        	  }
                });
            }
            })
        	});
    });
</script>
<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">

        <!-- Sidebar -->
        <ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

            <!-- Sidebar - Brand -->
            <a class="sidebar-brand d-flex align-items-center justify-content-center" href="index.jsp">
                <div class="sidebar-brand-icon rotate-n-15">
                    <i class="fas fa-laugh-wink"></i>
                </div>
                <div class="sidebar-brand-text mx-3">SB Admin <sup>2</sup></div>
            </a>

            <!-- Divider -->
            <hr class="sidebar-divider my-0">

            <!-- Nav Item - Dashboard -->
            <li class="nav-item active">
                <a class="nav-link" href="index.jsp">
                    <i class="fas fa-fw fa-tachometer-alt"></i>
                    <span>Dashboard</span></a>
            </li>

            <!-- Divider -->
            <hr class="sidebar-divider">

            <!-- Heading -->
            <div class="sidebar-heading">
                Interface
            </div>

            <!-- Nav Item - Pages Collapse Menu -->
            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseTwo"
                    aria-expanded="true" aria-controls="collapseTwo">
                    <i class="fas fa-fw fa-cog"></i>
                    <span>Components</span>
                </a>
                <div id="collapseTwo" class="collapse" aria-labelledby="headingTwo"
                    data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <h6 class="collapse-header">Custom Components:</h6>
                        <a class="collapse-item" href="buttons.jsp">Buttons</a>
                        <a class="collapse-item" href="cards.jsp">Cards</a>
                    </div>
                </div>
            </li>

            <!-- Nav Item - Utilities Collapse Menu -->
            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseUtilities"
                    aria-expanded="true" aria-controls="collapseUtilities">
                    <i class="fas fa-fw fa-wrench"></i>
                    <span>Utilities</span>
                </a>
                <div id="collapseUtilities" class="collapse" aria-labelledby="headingUtilities"
                    data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <h6 class="collapse-header">Custom Utilities:</h6>
                        <a class="collapse-item" href="utilities-color.jsp">Colors</a>
                        <a class="collapse-item" href="utilities-border.jsp">Borders</a>
                        <a class="collapse-item" href="utilities-animation.jsp">Animations</a>
                        <a class="collapse-item" href="utilities-other.jsp">Other</a>
                    </div>
                </div>
            </li>

            <!-- Divider -->
            <hr class="sidebar-divider">

            <!-- Heading -->
            <div class="sidebar-heading">
                Addons
            </div>

            <!-- Nav Item - Pages Collapse Menu -->
            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapsePages"
                    aria-expanded="true" aria-controls="collapsePages">
                    <i class="fas fa-fw fa-folder"></i>
                    <span>Pages</span>
                </a>
                <div id="collapsePages" class="collapse" aria-labelledby="headingPages"
                    data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <h6 class="collapse-header">Login Screens:</h6>
                        <a class="collapse-item" href="login.jsp">Login</a>
                        <a class="collapse-item" href="register.jsp">Register</a>
                        <a class="collapse-item" href="forgot-password.jsp">Forgot Password</a>
                        <div class="collapse-divider"></div>
                        <h6 class="collapse-header">Other Pages:</h6>
                        <a class="collapse-item" href="404.jsp">404 Page</a>
                        <a class="collapse-item" href="blank.jsp">Blank Page</a>
                    </div>
                </div>
            </li>

            <!-- Nav Item - Charts -->
            <li class="nav-item">
                <a class="nav-link" href="charts.jsp">
                    <i class="fas fa-fw fa-chart-area"></i>
                    <span>Charts</span></a>
            </li>

            <!-- Nav Item - Tables -->
            <li class="nav-item">
                <a class="nav-link" href="tables.jsp">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Tables</span></a>
            </li>

            <!-- Divider -->
            <hr class="sidebar-divider d-none d-md-block">

            <!-- Sidebar Toggler (Sidebar) -->
            <div class="text-center d-none d-md-inline">
                <button class="rounded-circle border-0" id="sidebarToggle"></button>
            </div>

            <!-- Sidebar Message -->
            <div class="sidebar-card d-none d-lg-flex">
                <img class="sidebar-card-illustration mb-2" src="../resources/img/undraw_rocket.svg" alt="...">
                <p class="text-center mb-2"><strong>SB Admin Pro</strong> is packed with premium features,
                    components, and more!</p>
                <a class="btn btn-success btn-sm" href="https://startbootstrap.com/theme/sb-admin-pro">Upgrade
                    to Pro!</a>
            </div>

        </ul>
        <!-- End of Sidebar -->

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

                <!-- Topbar -->
                <nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">

                    <!-- Sidebar Toggle (Topbar) -->
                    <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
                        <i class="fa fa-bars"></i>
                    </button>

                    <!-- Topbar Search -->
                    <form
                        class="d-none d-sm-inline-block form-inline mr-auto ml-md-3 my-2 my-md-0 mw-100 navbar-search">
                        <div class="input-group-append" id="temp_humi" style="white-space: nowrap;">
                        
                        </div>
                    </form> 

                    <!-- Topbar Navbar -->
                    <ul class="navbar-nav ml-auto">

                        <!-- Nav Item - Search Dropdown (Visible Only XS) -->
                        <li class="nav-item dropdown no-arrow d-sm-none">
                            <a class="nav-link dropdown-toggle" href="#" id="searchDropdown" role="button"
                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fas fa-search fa-fw"></i>
                            </a>
                            <!-- Dropdown - Messages -->
                            <div class="dropdown-menu dropdown-menu-right p-3 shadow animated--grow-in"
                                aria-labelledby="searchDropdown">
                                <form class="form-inline mr-auto w-100 navbar-search">
                                    <div class="input-group">
                                        <input type="text" class="form-control bg-light border-0 small"
                                            placeholder="Search for..." aria-label="Search"
                                            aria-describedby="basic-addon2">
                                        <div class="input-group-append">
                                            <button class="btn btn-primary" type="button">
                                                <i class="fas fa-search fa-sm"></i>
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </li>

                        <!-- Nav Item - Alerts -->
                        <li class="nav-item dropdown no-arrow mx-1">
                            <a class="nav-link dropdown-toggle" href="#" id="alertsDropdown" role="button"
                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fas fa-bell fa-fw"></i>
                                <!-- Counter - Alerts -->
                                <span class="badge badge-danger badge-counter">3+</span>
                            </a>
                            <!-- Dropdown - Alerts -->
                            <div class="dropdown-list dropdown-menu dropdown-menu-right shadow animated--grow-in"
                                aria-labelledby="alertsDropdown">
                                <h6 class="dropdown-header">
                                    Alerts Center
                                </h6>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="mr-3">
                                        <div class="icon-circle bg-primary">
                                            <i class="fas fa-file-alt text-white"></i>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="small text-gray-500">December 12, 2019</div>
                                        <span class="font-weight-bold">A new monthly report is ready to
                                            download!</span>
                                    </div>
                                </a>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="mr-3">
                                        <div class="icon-circle bg-success">
                                            <i class="fas fa-donate text-white"></i>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="small text-gray-500">December 7, 2019</div>
                                        $290.29 has been deposited into your account!
                                    </div>
                                </a>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="mr-3">
                                        <div class="icon-circle bg-warning">
                                            <i class="fas fa-exclamation-triangle text-white"></i>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="small text-gray-500">December 2, 2019</div>
                                        Spending Alert: We've noticed unusually high spending for your account.
                                    </div>
                                </a>
                                <a class="dropdown-item text-center small text-gray-500" href="#">Show All
                                    Alerts</a>
                            </div>
                        </li>

                        <!-- Nav Item - Messages -->
                        <li class="nav-item dropdown no-arrow mx-1">
                            <a class="nav-link dropdown-toggle" href="#" id="messagesDropdown" role="button"
                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fas fa-envelope fa-fw"></i>
                                <!-- Counter - Messages -->
                                <span class="badge badge-danger badge-counter">7</span>
                            </a>
                            <!-- Dropdown - Messages -->
                            <div class="dropdown-list dropdown-menu dropdown-menu-right shadow animated--grow-in"
                                aria-labelledby="messagesDropdown">
                                <h6 class="dropdown-header">
                                    Message Center
                                </h6>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="dropdown-list-image mr-3">
                                        <img class="rounded-circle" src="../resources/img/undraw_profile_1.svg"
                                            alt="...">
                                        <div class="status-indicator bg-success"></div>
                                    </div>
                                    <div class="font-weight-bold">
                                        <div class="text-truncate">Hi there! I am wondering if you can help me
                                            with a
                                            problem I've been having.</div>
                                        <div class="small text-gray-500">Emily Fowler Â· 58m</div>
                                    </div>
                                </a>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="dropdown-list-image mr-3">
                                        <img class="rounded-circle" src="../resources/img/undraw_profile_2.svg"
                                            alt="...">
                                        <div class="status-indicator"></div>
                                    </div>
                                    <div>
                                        <div class="text-truncate">I have the photos that you ordered last
                                            month, how
                                            would you like them sent to you?</div>
                                        <div class="small text-gray-500">Jae Chun Â· 1d</div>
                                    </div>
                                </a>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="dropdown-list-image mr-3">
                                        <img class="rounded-circle" src="../resources/img/undraw_profile_3.svg"
                                            alt="...">
                                        <div class="status-indicator bg-warning"></div>
                                    </div>
                                    <div>
                                        <div class="text-truncate">Last month's report looks great, I am very
                                            happy with
                                            the progress so far, keep up the good work!</div>
                                        <div class="small text-gray-500">Morgan Alvarez Â· 2d</div>
                                    </div>
                                </a>
                                <a class="dropdown-item d-flex align-items-center" href="#">
                                    <div class="dropdown-list-image mr-3">
                                        <img class="rounded-circle"
                                            src="https://source.unsplash.com/Mv9hjnEUHR4/60x60" alt="...">
                                        <div class="status-indicator bg-success"></div>
                                    </div>
                                    <div>
                                        <div class="text-truncate">Am I a good boy? The reason I ask is because
                                            someone
                                            told me that people say this to all dogs, even if they aren't
                                            good...</div>
                                        <div class="small text-gray-500">Chicken the Dog Â· 2w</div>
                                    </div>
                                </a>
                                <a class="dropdown-item text-center small text-gray-500" href="#">Read More
                                    Messages</a>
                            </div>
                        </li>

                        <div class="topbar-divider d-none d-sm-block"></div>

                        <!-- Nav Item - User Information -->
                        <li class="nav-item dropdown no-arrow">
                            <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button"
                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span
                                    class="mr-2 d-none d-lg-inline text-gray-600 small">${loginMember.name}</span>
                                <img class="img-profile rounded-circle"
                                    src="../resources/img/undraw_profile.svg">
                            </a>
                            <!-- Dropdown - User Information -->
                            <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in"
                                aria-labelledby="userDropdown">
                                <a class="dropdown-item" href="#">
                                    <i class="fas fa-user fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Profile
                                </a>
                                <a class="dropdown-item" href="#">
                                    <i class="fas fa-cogs fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Settings
                                </a>
                                <a class="dropdown-item" href="#">
                                    <i class="fas fa-list fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Activity Log
                                </a>
                                <div class="dropdown-divider"></div>
                                <a class="dropdown-item" href="/logout" data-toggle="modal"
                                    data-target="#logoutModal">
                                    <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Logout
                                </a>
                            </div>
                        </li>

                    </ul>

                </nav>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div id="pdfDiv">
                    <div class="container-fluid">

                        <!-- Page Heading -->
                        <div class="d-sm-flex align-items-center justify-content-between mb-4">
                            <h1 class="h3 mb-0 text-gray-800">데이터 모니터링</h1>
                            <a style="cursor:pointer; margin-left:auto;" id='makeDat'
                                class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                                    class="fas fa-download fa-sm text-white-50"></i> DAT 생성</a>
                            <div>&nbsp;&nbsp;</div>
                            <a style="cursor:pointer;" id='report'
                                class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                                    class="fas fa-download fa-sm text-white-50"></i> Report 생성</a>

                        </div>

                        <!-- Content Row -->
                        <div class="row">

                            <!-- Earnings (Monthly) Card Example -->
                            <div class="col-xl-3 col-md-6 mb-4">
                                <div class="card border-left-primary shadow h-100 py-2">
                                    <div class="card-body">
                                        <div class="row no-gutters align-items-center">
                                            <div class="col mr-2">
                                                <div
                                                    class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                    일일 평균 경사각</div>
                                                <div class="h5 mb-0 font-weight-bold text-gray-800"
                                                    id="avgtilt">${avgtilt}º</div>
                                            </div>
                                            <div class="col-auto">
                                                <i class="fas fa-calendar fa-2x text-gray-300"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Earnings (Monthly) Card Example -->
                            <div class="col-xl-3 col-md-6 mb-4">
                                <div class="card border-left-success shadow h-100 py-2">
                                    <div class="card-body">
                                        <div class="row no-gutters align-items-center">
                                            <div class="col mr-2">
                                                <div
                                                    class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                    일일 최고 / 최저 경사각</div>
                                                <div class="h5 mb-0 font-weight-bold text-gray-800"
                                                    id="maxmintilt">${maxtilt}º / ${mintilt}º</div>
                                            </div>
                                            <div class="col-auto">
                                                <i class="fas fa-calendar fa-2x text-gray-300"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Earnings (Monthly) Card Example -->
                            <div class="col-xl-3 col-md-6 mb-4">
                                <div class="card border-left-info shadow h-100 py-2">
                                    <div class="card-body">
                                        <div class="row no-gutters align-items-center">
                                            <div class="col mr-2">
                                                <div
                                                    class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                                    일일 평균 기온
                                                </div>
                                                <div class="row no-gutters align-items-center">
                                                    <div class="col-auto">
                                                        <div class="h5 mb-0 mr-3 font-weight-bold text-gray-800"
                                                            id="tempData">${tempData}℃
                                                        </div>
                                                    </div>
                                                    <div class="col">
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-auto">
                                                <i
                                                    class="fas fa-thermometer-three-quarters fa-2x text-gray-300"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Pending Requests Card Example -->
                            <div class="col-xl-3 col-md-6 mb-4">
                                <div class="card border-left-warning shadow h-100 py-2">
                                    <div class="card-body">
                                        <div class="row no-gutters align-items-center">
                                            <div class="col mr-2">
                                                <div
                                                    class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                    일일 평균 배터리</div>
                                                <div class="h5 mb-0 font-weight-bold text-gray-800"
                                                    id="battData">${battData}%</div>
                                            </div>
                                            <div class="col-auto">
                                                <i class="fas fa-battery-quarter	 fa-2x text-gray-300"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Content Row -->

                        <div class="row">

                            <!-- Area Chart -->
                            <div class="col-xl-8 col-lg-7">
                                <div class="card shadow mb-4">
                                    <!-- Card Header - Dropdown -->
                                    <div
                                        class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                        <h6 class="m-0 font-weight-bold text-primary" id="channelName">채널별 경사각
                                            (${channel})</h6>
                                        <div class="dropdown no-arrow" style="white-space: nowrap;">
                                            <span class="m-0 font-weight-bold text-primary">날짜 선택</span>
                                            <input type="date" id="chooseDate"
                                                class="m-0 font-weight-bold text-primary" value="${minDate }" />

                                            <span class="m-0 font-weight-bold text-primary">채널 선택</span>
                                            <a class="dropdown-toggle" href="#" role="button"
                                                id="dropdownMenuLink" data-toggle="dropdown"
                                                aria-haspopup="true" aria-expanded="false">
                                                <i class="fas fa-ellipsis-v fa-sm fa-fw text-gray-400"></i>
                                            </a>
                                            <div class="dropdown-menu dropdown-menu-right shadow animated--fade-in"
                                                aria-labelledby="dropdownMenuLink">
                                                <div class="dropdown-header">채널 선택</div>
                                                <input type="hidden" id="nowChannel" value="${channel}" />
                                                <c:forEach var="channel" items="${channelList}">
                                                    <a class="dropdown-item" data-channel="${channel}"
                                                        style="cursor:pointer;">${channel}</a>
                                                </c:forEach>
                                                <div class="dropdown-divider"></div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Card Body -->
                                    <div class="card-body">
                                        <div class="chart-area">
                                            <canvas id="myAreaChart"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Pie Chart -->
                            <div class="col-xl-4 col-lg-5">
                                <div class="card shadow mb-4">
                                    <!-- Card Header - Dropdown -->
                                    <div
                                        class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                        <h6 class="m-0 font-weight-bold text-primary">채널 위치 지도</h6>
                                        <div class="dropdown no-arrow">
                                            <a class="dropdown-toggle" href="#" role="button"
                                                id="dropdownMenuLink" data-toggle="dropdown"
                                                aria-haspopup="true" aria-expanded="false">
                                                <i class="fas fa-ellipsis-v fa-sm fa-fw text-gray-400"></i>
                                            </a>
                                            <div class="dropdown-menu dropdown-menu-right shadow animated--fade-in"
                                                aria-labelledby="dropdownMenuLink">
                                                <div class="dropdown-header">Dropdown Header:</div>
                                                <a class="dropdown-item" href="#">Action</a>
                                                <a class="dropdown-item" href="#">Another action</a>
                                                <div class="dropdown-divider"></div>
                                                <a class="dropdown-item" href="#">Something else here</a>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Card Body -->
                                    <div class="card-body">
                                        <!-- <div class="chart-pie pt-4 pb-2"> -->
                                        <div id="map" class="chart-pie pt-4 pb-2"></div>

                                        <!-- </div> -->

                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Content Row -->
                        <div class="row">

                            <!-- Content Column -->
                            <div class="col-lg-6 mb-4">

                                <!-- Color System -->
                                <div class="row">
                                    <c:forEach var="LatLng" items="${LatLngList}">
                                        <div class="col-lg-6 mb-4">
                                            <div class="card bg-primary text-white shadow">
                                                <div class="card-body">
                                                    <p id='LatLngTilt'>${LatLng.tilt}</p>
                                                    <div class="text-white-50 small">
                                                        위도 : <p id="Lat"> ${LatLng.lat}</p>
                                                        경도 : <p id="Lat"> ${LatLng.lng}</p>
                                                    </div>
                                                    <a class="kakaoaddr" data-tilt="${LatLng.tilt}"><span
                                                            class='btn btn-success btn-icon-split'>채널 주소 변경
                                                            하기</span></a>
                                                    <input type="hidden" id="changeAddress" value="N" />
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                            </div>

                            <div class="col-lg-6 mb-4">
							    <!-- Illustrations -->
							    <div class="card shadow mb-4">
							        <div class="card-header py-3">
							            <div style="display: flex; align-items: center;">
							                <select class="form-control" id="selectedMonth" style="width: 80px; height: 40px; margin-left: 10px;">
							                      <option value="1">1월</option>
							                      <option value="2">2월</option>
							                      <option value="3">3월</option>
							                      <option value="4">4월</option>
							                      <option value="5">5월</option>
							                      <option value="6">6월</option>
							                      <option value="7">7월</option>
							                      <option value="8">8월</option>
							                      <option value="9">9월</option>
							                      <option value="10">10월</option>
							                      <option value="11">11월</option>
							                      <option value="12">12월</option>
							                </select>
							                <span class="m-0 font-weight-bold text-primary" style="margin-left: 10px;">　일일 접속자 수</span>
							            </div>
							        </div>
							        <div class="chart-bar">
							            <canvas id="myBarChart" width="790" height="400" style="display: block; height: 320px; width: 632px;" class="chartjs-render-monitor"></canvas>
							        </div>
							    </div>
							</div>
                        </div>

                    </div>
                </div>
                <!-- /.container-fluid -->

            </div>
            <!-- End of Main Content -->

            <!-- Footer -->
            <footer class="sticky-footer bg-white">
                <div class="container my-auto">
                    <div class="copyright text-center my-auto">
                        <span>Copyright &copy; SimpleBit 2023</span>
                    </div>
                </div>
            </footer>
            <!-- End of Footer -->

        </div>
        <!-- End of Content Wrapper -->

    </div>
    <!-- End of Page Wrapper -->

    <!-- Scroll to Top Button-->
    <a class="scroll-to-top rounded" href="#page-top">
        <i class="fas fa-angle-up"></i>
    </a>

    <!-- Logout Modal-->
    <div class="modal fade" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Ready to Leave?</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">X</span>
                    </button>
                </div>
                <div class="modal-body">Select "Logout" below if you are ready to end your current session.
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                    <a class="btn btn-primary" href="/logout">Logout</a>
                </div>
            </div>
        </div>
    </div>
    <c:forEach var="data" items="${channelData }">
        <input type="hidden" class="channelData" value="${data }" />
    </c:forEach>
    <c:forEach var="date" items="${channelDate }">
        <input type="hidden" class="channelDate" value="${date }" />
    </c:forEach>
    <c:forEach var="count" items="${countData}" varStatus="status">
    	<input type="hidden" class="countData" value="${count['count']}" />
    	<input type="hidden" class="countDate" value="${count['formatted_date']}" />
	</c:forEach>
    
    <!-- Bootstrap core JavaScript-->
    <script src="../resources/vendor/jquery/jquery.min.js"></script>
    <script src="../resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

    <!-- Core plugin JavaScript-->
    <script src="../resources/vendor/jquery-easing/jquery.easing.min.js"></script>

    <!-- Custom scripts for all pages-->
    <script src="../resources/js/sb-admin-2.min.js"></script>

    <!-- Page level plugins -->
    <script src="../resources/vendor/chart.js/Chart.min.js"></script>
    <!-- Page level custom scripts -->


    <script src="../resources/js/demo/chart-area-demo.js"></script>
    <script src="../resources/js/demo/chart-pie-demo.js"></script>
    <script src="../resources/js/demo/chart-bar-demo.js"></script>

</body>
</html>