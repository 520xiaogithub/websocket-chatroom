<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getServerName() + ":" + request.getServerPort() + path + "/";
	String baseUrlPath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<title>KK在线聊天室</title>
<!-- 引入easyUI 外部头文件 -->
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/themes/default/easyui.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/themes/icon.css" />

<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/jquery.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/jquery.easyui.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/locale/easyui-lang-zh_CN.js"></script>
<!-- <script type="text/javascript" src="/js/common.js"></script> -->

<%-- <script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-1.11.3.min.js"></script> --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/sockjs.min.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css" type="text/css" media="all" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/chat.css" type="text/css" media="all" />

<script type="text/javascript">
    
	var path = '<%=basePath%>';
	
	var uid='${sessionScope.loginUser.id}';
	//发送人编号
	var fromID='${sessionScope.loginUser.id}';
	var fromName='${sessionScope.loginUser.nickname}';
	
	//接收人编号     #############################################################-------------------这里需要修改  
	var toID="-1";
	
	//将发送的文件数据分包需要设置的全局变量
    var CHUNK_SIZE = 2*1024*1024;   //每2M字节发送一次请求
    var start;  //开始分割位置
    var end;    //结束分割位置
    var slice;  //文件块
    var file;    //文件对象
    var reader = new FileReader() ;   //文件读取对象
    var reverse = false;  //一个标记
    
    var lockReconnect = false;  //避免重复连接
    var tt;
    var userLists ; //保存所有在线用户
    var pathpath = '${pageContext.request.contextPath}';
    
	//延时执行loadOnlineAllUser()方法
	function _load(){
//		alert(11111);
		setTimeout(loadOnlineAllUser, 2000);
	}
	//select点击事件
	function loadOnlineAllUser(){
		// alert(11); 
		 //每次加载页面之前先清空select
        $("#privateChat").html($('<option value="all">发给所有人</option>'));
		 
        var myselect=document.getElementById("privateChat");
        var temp=0;
        //使用异步请求获取所有在线用户
        $.post("${pageContext.request.contextPath}/chat/findAllOnlineUser?id="+fromID, function(data){
            //data接收到的是一个Json对象  是一个json数组
            userLists = data;
            console.log("userLists1111111111111111111="+userLists);
            $(data).each(function(){
                //alert(this.id);
                //向select中添加option
                //alert(fromName);
          
                if(fromName != this.nickname){
                   temp=temp+1;
                   myselect.options[temp]=new Option(this.nickname,this.id);                    
                }
            });
            
        });             
	}
	
	//管理员踢人***************
	function _solution(){
		//首先判断当前用户是不是管理员
		if(fromName == "admin"){       //使用easyUI做一个弹出框效果
			//如果是
			
		}
	}
	
	//将所有登录的用户添加到select中   
    //给下拉框添加一个离焦事件  用于获取用户的选择
    $(function(){
    	    	
        $("select[name='privateChat']").blur(function(){
        
            //获取接收人编号
            /* alert(1111);
            var myselect=document.getElementById("privateChat");
            var toID=myselect.selectedIndex ; // selectedIndex代表的是你所选中项的index
            var optionValue=myselect.options[toID].value;  //select标签中被选中的option值
            var optionText=myselect.options[toID].text;  //select标签中被选中的option嵌入的文本内容
            alert(toID);
            alert(optionValue);
            alert(optionText); */
        	var myselect=document.getElementById("privateChat");
            if($(this).val()=="all"){
            	toID="-1";
            }else{
            	//alert($(this).val());
            	//设置私聊的toID编号
            	toID=$(this).val();
            	//设置option值的显示
            	myselect.options[0].value=myselect.options[toID].value;
            	myselect.options[0].text=myselect.options[toID].text;
            	//select.options[1].selected = true;  
            }
                                  
          /* //每次加载页面之前先清空select
            $("#privateChat").html($('<option value="all">所有人</option>')); */
        });
    });
	
	// 创建一个Socket实例
	//参数为URL，ws表示WebSocket协议。onopen、onclose和onmessage方法把事件连接到Socket实例上。每个方法都提供了一个事件，以表示Socket的状态。
	var websocket;
	//不同浏览器的WebSocket对象类型不同
	//alert("ws://" + path + "/ws?uid="+uid);
	
	//   以下实现握手###################################################
	if ('WebSocket' in window) {    //IE浏览器
		websocket = new WebSocket("ws://" + path + "ws"); 
		console.log("=============WebSocket");
		//火狐
	} else if ('MozWebSocket' in window) {
		websocket = new MozWebSocket("ws://" + path + "ws");
		console.log("=============MozWebSocket");
	} else {
		websocket = new SockJS("http://" + path + "ws/sockjs");
		console.log("=============SockJS");
	}
	//#########################################################################
	
	console.log("ws://" + path + "ws");
	
	//打开Socket,
	websocket.onopen = function(event) {
		//握手成功后，发送一条初始化消息
		console.log("WebSocket:已连接");
	}	
	
	// 监听消息
	//onmessage事件提供了一个data属性，它可以包含消息的Body部分。消息的Body部分必须是一个字符串，可以进行序列化/反序列化操作，以便传递更多的数据。
	websocket.onmessage = function(event) {
		
		//判断是本文数据还是文件数据
		if(typeof event.data =='string'){        //文本数据
			
			//alert("这是string文件传输消息");
			console.log('Client received a message',event);
			//var data=JSON.parse(event.data);
			//event.data:获取服务端给客户端的消息                            ************************
			//data:对应的是domian中的Message实体类的属性值集合
			var data=$.parseJSON(event.data);
			console.log("WebSocket:收到一条消息",data);
			//alert(data.id+"     data.id");
			//alert(typeof data.id+"     data.id");
			
			if(data.id == 0){    //发送文件
				//alert("就要转送了");
				//alert(pathpath+"     pathpath");
				//发送文件下载链接
				//===普通消息######################################################
                //处理一下个人信息的显示：   单聊   ----------当消息很多的时候怎么办？？？？？？-修改
                //解决<a href>中中文乱码问题 
                if(data.fromName==fromName){
                    data.fromName="我";
                    $("#contentUl").append("<li><span  style='display:block; float:right;'><span>"+"<a id="+"'"+"encodehref"+"'"+"href="+"'"+pathpath+"/upload/"+data.text+"'"+"download="+"'"+data.typeName+"'"+"target='_blank"+"'>"+"您上传的文件是：   "+data.typeName+"</a></span><em>"+data.fromName+"</em><b>"+data.date+"</b></span></li><br/>");            
                }else{
                	$("#contentUl").append("<li><b>"+data.date+"</b><em>"+data.fromName+"</em><span>"+"<a id="+"'"+"encodehref"+"'"+"href="+"'"+pathpath+"/upload/"+data.text+"'"+"download="+"'"+data.typeName+"'"+"target='_blank"+"'>"+"请点击下载文件：    "+data.typeName+"</a></span></li><br/>");
                	//解决href中文乱码
                    var href=$("#encodehref").attr("href");
                	href = decodeURI(encodeURI(href, "UTF-8"));
                	$("#encodehref").attr("href",href);
                }                
                
                //等文件发送完后，再发送图片
                var imageElement = document.getElementById("image");
        		var imageList = imageElement.files;    //获取图片上传域中的所有图片，返回的是FileList对象，相当于一个数组。数组元素是File对象
        		image=imageList[0];
        		if(image != null && image != "" && image != undefined){
        			//alert("image is not null");
	        		var data={};
	                
			        //发送图片
			        data["fromID"]=fromID;
	                data["toID"]=toID;
			        data["typeName"]="image";
			        data["fromName"]=fromName;
			      //发送消息
	                websocket.send(JSON.stringify(data));
	              //调用文件上传方法
			        UpladFile(image);   //再发送图片
			        imageElement.outerHTML=imageElement.outerHTML; //清空<input type="file" id= "image">的值
        		}else{      //防止重复执行*******************
	        		//等图片发送完，再发送文本消息
	        		//判断文本框中是否有内容
	                var isAreaText=document.getElementById("msg").value; 
	                if(isAreaText != "" && isAreaText != null && isAreaText != undefined){
	                	console.log(isAreaText);
	        			//alert(typeof isAreaText+"isAreaText");
	                	//alert("is AreaText is not null");
	                	//获取用户要发送的消息内容----------发送文本消息
						var data={};
						data["fromID"]=fromID;
						data["fromName"]=fromName;
						data["toID"]=toID;
						data["text"]=isAreaText;
						data["typeName"]="text";
						//发送消息
						websocket.send(JSON.stringify(data));
						
						//发送完消息，清空输入框
						$("#msg").val("");
	                }        			
        		}              		
			}else if(data.id == 1){        //发送图片
				//alert("就要转送了");
				//alert(pathpath+"     pathpath");
				//发送文件下载链接
				//===普通消息######################################################
                //处理一下个人信息的显示：   单聊   ----------当消息很多的时候怎么办？？？？？？-修改
                //解决<a href>中中文乱码问题 
                if(data.fromName==fromName){
                    data.fromName="我";
                    $("#contentUl").append("<li><span  style='display:block; float:right;'><span>"+"<a id="+"'"+"encodehref"+"'"+"href="+"'"+pathpath+"/upload/"+data.text+"'"+"target='_blank"+"'>"+"<img alt='抱歉，图片未正常显示' src='"+pathpath+"/upload/"+data.text+"'"+"height='150'width='100'></a></span><em>"+data.fromName+"</em><b>"+data.date+"</b></span></li><br/>");            
                }else{
                	$("#contentUl").append("<li><b>"+data.date+"</b><em>"+data.fromName+"</em><span>"+"<a id="+"'"+"encodehref"+"'"+"href="+"'"+pathpath+"/upload/"+data.text+"'"+"download="+"'"+data.typeName+"'"+"target='_blank"+"'>"+"<img alt='抱歉，图片未正常显示' src='"+pathpath+"/upload/"+data.text+"'"+"height='150'width='100'></a></span></li><br/>");
                	//解决href中文乱码
                    var href=$("#encodehref").attr("href");
                	href = decodeURI(encodeURI(href, "UTF-8"));
                	$("#encodehref").attr("href",href);
                }
                
                //判断文本框中是否有内容
                var isAreaText=document.getElementById("msg").value;
                if(isAreaText != null && isAreaText != "" && isAreaText != undefined){
                	//获取用户要发送的消息内容----------发送文本消息
					var data={};
					data["fromID"]=fromID;
					data["fromName"]=fromName;
					data["toID"]=toID;
					data["text"]=isAreaText;
					data["typeName"]="text";
					//发送消息
					websocket.send(JSON.stringify(data));
					
					//发送完消息，清空输入框
					$("#msg").val("");
                }
                
			}else{
				//2种推送的消息
				//1.用户聊天信息：发送消息触发
				//2.系统消息：登录和退出触发
		
				//判断是否是欢迎消息（没用户编号的就是欢迎消息）
				if(data.fromID==undefined||data.fromID==null||data.fromID==""){
					//===系统消息###################################################
					$("#contentUl").append("<li><b>"+data.date+"</b><em>系统消息：</em><span>"+data.text+"</span></li>");
					//刷新在线用户列表
					$("#chatOnline").html("在线用户("+data.userList.length+")人");
					$("#chatUserList").empty();
					$(data.userList).each(function(){
						$("#chatUserList").append("<li>"+this.nickname+"</li>");
					});
					
				}else{
					//===普通消息######################################################
					//处理一下个人信息的显示：   单聊   ----------当消息很多的时候怎么办？？？？？？-修改   isWithText = isWithText.replace(/\n/g,"<br/>");
					data.text = (data.text).replace(/(\\n)/g,"<br/>");    //将
					if(data.fromName==fromName){
						data.fromName="我";
						$("#contentUl").append("<li><span  style='display:block; float:right;'><span>"+data.text+"</span><em>"+data.fromName+"</em><b>"+data.date+"</b></span></li><br/>");
					}else{
						$("#contentUl").append("<li><b>"+data.date+"</b><em>"+data.fromName+"</em><span>"+data.text+"</span></li><br/>");
					}				
				}
			}
		}else if(event.data instanceof Blob){                   //二进制数据			
			//alert(1112233445);
			console.log(event.data);
			//var reader = new FileReader();
			reader.onload=function(eve){
				 if(eve.target.readyState==FileReader.DONE)
				 {
					var img = document.createElement("img");     //这样无法显示
					img.src=this.result;
					document.getElementById("plane").appendChild(img);
				 }
			 };
			 reader.readAsDataURL(event.data);
		}else{
			
			console.log("fial");
		}
		
		scrollToBottom();
	}; 
	
	// 监听WebSocket的关闭
	websocket.onclose = function(event) {		
		$("#contentUl").append("<li><b>"+new Date().Format("yyyy-MM-dd hh:mm:ss")+"</b><em>系统消息：</em><span>连接已断开！</span></li>");
		scrollToBottom();
		console.log("WebSocket:已关闭：Client notified socket has closed",event); 
	}; 
	
	//监听异常
	websocket.onerror = function(event) {
		$("#contentUl").append("<li><b>"+new Date().Format("yyyy-MM-dd hh:mm:ss")+"</b><em>系统消息：</em><span>连接异常，建议重新登录</span></li>");
		scrollToBottom();
		console.log("WebSocket:发生错误 ",event);
	};
	
	//解决心跳连接问题
	function reconnect() {
		//alert("reconnect");
        if(lockReconnect) {
          return;
        };
        lockReconnect = true;
        //没连接上会一直重连，设置延迟避免请求过多
        tt && clearTimeout(tt);
        tt = setTimeout(function () {
            websocket = new WebSocket("ws://" + path + "ws"); 
            console.log("=============WebSocket");
            lockReconnect = false;
        }, 400);
      }  
	
	//将byte[]转换为string
	function byteToString(arr) {
		//alert("arr.length"+arr.length);
             if(typeof arr === 'string') {
                 return arr;
             }
             var str = '',
                 _arr = arr;
             for(var i = 0; i < _arr.length; i++) {
                 var one = _arr[i].toString(2);
                 var v = one.match(/^1+?(?=0)/);
                 if(v && one.length == 8) {
                     var bytesLength = v[0].length;
                     var store = _arr[i].toString(2).slice(7 - bytesLength);
                     for(var st = 1; st < bytesLength; st++) {
                         store += _arr[st + i].toString(2).slice(2);
                     }
                     str += String.fromCharCode(parseInt(store, 2));
                     i += bytesLength - 1;
                 } else {
                     str += String.fromCharCode(_arr[i]);
                 }
             }
             return str;
         }
	
	//onload初始化
	$(function(){   //整个页面加载完后执行
		//发送消息
		$("#sendBtn").on("click",function(){
			sendMsg();  //发送文本消息
		});
		
		//   给退出聊天绑定事件          客户端主动提出断开连接##############################################
		$("#exitBtn").on("click",function(){
			closeWebsocket();
			location.href="${pageContext.request.contextPath}/chat/quit?id="+fromID;
		});
		
		//给输入框绑定事件
		$("#msg").on("keydown",function(event){
			keySend(event);
		});
		
		//初始化时如果有消息，则滚动条到最下面：
		scrollToBottom();
		
	});

	//使用ctrl+回车快捷键发送消息
	function keySend(e) {
		var theEvent = window.event || e; 
		var code = theEvent.keyCode || theEvent.which; 
		//if (theEvent.ctrlKey && code == 13) {
		if (theEvent.ctrlKey && code == 13) {
			var msg=$("#msg");
			if (msg.innerHTML == "") {
				//这里需要清除一个回车键
				$("#msg").val("");
				msg.focus();
				return false;
			}
			sendMsg();
		}
	}
		
	//进行消息分割******************************************************************************************
	function seek(i, partitionNum){
		//alert("file"+file.size);
		if(i == partitionNum){
			//alert("true");
			reverse = true;
		}
		//var remaining = file.size % CHUNK_SIZE;   //获取剩余的文件字节数，进行单独处理
		end = reverse? file.size : CHUNK_SIZE+start;
		//alert("end"+end);
		//alert("start"+start);
		slice = file.slice(start, end);
		reader.readAsText(slice,'utf-8');
	}
	
	//**********************************************************************************
				var xhr;
		        //上传文件方法
		        function UpladFile(file) {
		            var fileObj = file; // js 获取文件对象
		            var fileNameName = fileObj.name;
		            var suffix = fileNameName.substring(fileNameName.lastIndexOf("."));   //获取文件类型
		            //alert("suffix  "+suffix);
		            if(suffix == ".xls" || suffix == ".xlsx" || suffix == ".doc" || suffix == ".docx" || suffix == ".txt" || suffix == ".pdf" || suffix == ".caj" || suffix == ".xml" || suffix == ".zip" || suffix == ".rar" || suffix == ".mp4" || suffix == ".avi" || suffix == ".mp3"){
			            var url =  "${pageContext.request.contextPath}/chat/upload"; // 接收上传文件的后台地址
			            
			            var form = new FormData(); // FormData 对象
			            form.append("file", fileObj); // 文件对象   	
		            }else{
						var url =  "${pageContext.request.contextPath}/chat/uploadImg"; // 接收上传文件的后台地址
			            
			            var form = new FormData(); // FormData 对象
			            form.append("image", fileObj); // 文件对象
		            }

		            xhr = new XMLHttpRequest();  // XMLHttpRequest 对象
		            xhr.open("post", url, true); //post方式，url为服务器请求地址，true 该参数规定请求是否异步处理。

		            xhr.upload.onprogress = progressFunction;  //【上传进度调用方法实现】
		            xhr.upload.onloadstart = function(){//上传开始执行方法
		                ot = new Date().getTime();   //设置上传开始时间
		                oloaded = 0;//设置上传开始时，以上传的文件大小为0
		            };
		            
		            xhr.send(form); //开始上传，发送form数据
		            xhr.onload = uploadComplete; //请求完成
		            xhr.onerror =  uploadFailed; //请求失败
		        }
		        
		      //上传成功响应
		        function uploadComplete(evt) {
		            //服务断接收完文件返回的结果
		        	var data = JSON.parse(evt.target.responseText);
		            
		            if(data.text == "true") {
		            	console.log("文件上传成功！");
		            	var fileTransferURL = data.fileURL;
		            	console.log(fileTransferURL); 
		                websocket.send(fileTransferURL+":fileFinishSingle");
		            }else{
		            	$.messager.alert("消息","对不起，文件上传失败！","warning");
		            	//alert("上传失败！");
		            }
		    	}
		        //上传失败
		        function uploadFailed(evt) {
		        	$.messager.alert("消息","对不起，文件上传失败！","warning");
		        	//alert("上传失败！");
		        }

		        //上传进度实现方法，上传过程中会频繁调用该方法
		        function progressFunction(evt) {
		            var progressBar = document.getElementById("progressBar");
		            var percentageDiv = document.getElementById("percentage");
		            // event.total是需要传输的总字节，event.loaded是已经传输的字节。如果event.lengthComputable不为真，则event.total等于0
		            if (evt.lengthComputable) {//
		                progressBar.max = evt.total;
		                progressBar.value = evt.loaded;
		                percentageDiv.innerHTML = Math.round(evt.loaded / evt.total * 100) + "%";
		            }
		            var time = document.getElementById("time");
		            var nt = new Date().getTime();//获取当前时间
		            var pertime = (nt-ot)/1000;    //计算出上次调用该方法时到现在的时间差，单位为s
		            ot = new Date().getTime(); //重新赋值时间，用于下次计算
		            var perload = evt.loaded - oloaded; //计算该分段上传的文件大小，单位b
		            oloaded = evt.loaded;//重新赋值已上传文件大小，用以下次计算
		            //上传速度计算
		            var speed = perload/pertime;      //单位b/s 
		            var bspeed = speed;
		            var units = 'b/s';//单位名称
		            if(speed/1024>1){
		                speed = speed/1024;
		                units = 'k/s';
		            }
		            if(speed/1024>1){
		                speed = speed/1024;
		                units = 'M/s';
		            }
		            speed = speed.toFixed(1);
		            //剩余时间
		            var resttime = ((evt.total-evt.loaded)/bspeed).toFixed(1);
		            time.innerHTML = '，速度：'+speed+units+'，剩余时间：'+resttime+'s';
		            if(bspeed==0) time.innerHTML = '上传已取消';
		        }
	
	   
	//发送消息
	function sendMsg(){
		//对象为空了		
		if(websocket==undefined||websocket==null){
			//alert('WebSocket connection not established, please connect.');
			$.messager.alert("消息","您的连接已经丢失，请退出聊天重新进入！","warning");
			//alert('您的连接已经丢失，请退出聊天重新进入');
			return;
		}
		
		//发送文件信息*************************************************************************
	 	var isWithText=document.getElementById("msg").value;
		//去除isWithText字符串中的前后空格
		isWithText = $.trim(isWithText);
		if(isWithText == ""){
			//发送完消息，清空输入框
			$("#msg").val("");
		}
		//判断用户是否发送文件
		var inputElement = document.getElementById("file");
		var fileList = inputElement.files;    //获取文件上传域中的所有文件，返回的是FileList对象，相当于一个数组。数组元素是File对象
		file=fileList[0];     //获取第一个File对象。  File对象包含属性：name,type(文件类型),size(文件大小，单位是字节)		
		//判断用户是否发送图片
		var imageElement = document.getElementById("image");
		var imageList = imageElement.files;    //获取图片上传域中的所有图片，返回的是FileList对象，相当于一个数组。数组元素是File对象
		image=imageList[0];
		
		if(file != null){
			if(file.size > 209715200){
				$.messager.alert("消息","上传的文件不能大于200M","warning");
				inputElement.outerHTML=inputElement.outerHTML; //清空<input type="file" id= "file">的值 
				return;
			}  
		}
		
		if(image != null){
			if(image.size > 209715200){
				$.messager.alert("消息","上传的图片不能大于200M","warning");
				imageElement.outerHTML=imageElement.outerHTML; //清空<input type="file" id= "image">的值
				return;
			}  
		}
		
		if(file || image || isWithText){
			if(file && image && isWithText){
				//alert("file && image && isWithText");
				var data={};
                data["fromID"]=fromID;
                data["toID"]=toID;
                data["typeName"]="file";
                data["fromName"]=fromName;
                //发送消息
                websocket.send(JSON.stringify(data));
		        //调用文件上传方法
		        UpladFile(file);   //先发送文件
		        //onmessage中发送图片和本文消息
		        inputElement.outerHTML=inputElement.outerHTML; //清空<input type="file" id= "file">的值  
		        
				
			}else if(file && image){
				//alert("file && image");				
				var data={};
                data["fromID"]=fromID;
                data["toID"]=toID;
                data["typeName"]="file";
                data["fromName"]=fromName;
                //发送消息
                websocket.send(JSON.stringify(data));
		        //调用文件上传方法
		        UpladFile(file);   //先发送文件
		        //onmessage中发送图片
		        inputElement.outerHTML=inputElement.outerHTML; //清空<input type="file" id= "file">的值  
		        

			}else if(file && isWithText){
				//alert("file && isWithText");
				var data={};
                data["fromID"]=fromID;
                data["toID"]=toID;
                data["typeName"]="file";
                data["fromName"]=fromName;
                //发送消息
                websocket.send(JSON.stringify(data));
		        //调用文件上传方法
		        UpladFile(file);   //先发送文件
		        //onmessage中发送文本消息
		        inputElement.outerHTML=inputElement.outerHTML; //清空<input type="file" id= "file">的值  	

			}else if(image && isWithText){
				//alert("image && isWithText");
				var data={};
                data["fromID"]=fromID;
                data["toID"]=toID;
                data["typeName"]="image";
                data["fromName"]=fromName;
                //发送消息
                websocket.send(JSON.stringify(data));
		        //调用图片上传方法
		        UpladFile(image);   //先发送图片
		        //onmessage中发送文本消息
		        imageElement.outerHTML=imageElement.outerHTML; //清空<input type="file" id= "image">的值	

			}else if(file){
				//alert("file");
				var data={};
                data["fromID"]=fromID;
                data["toID"]=toID;
                data["typeName"]="file";
                data["fromName"]=fromName;
                //发送消息
                websocket.send(JSON.stringify(data));
		        //调用文件上传方法
		        UpladFile(file);   //先发送文件
		        
		        inputElement.outerHTML=inputElement.outerHTML; //清空<input type="file" id= "file">的值  	
			}else if( image ){
				//alert("image");
				var data={};
                data["fromID"]=fromID;
                data["toID"]=toID;
                data["typeName"]="image";
                data["fromName"]=fromName;
                //发送消息
                websocket.send(JSON.stringify(data));
		        //调用图片上传方法
		        UpladFile(image);   
		      
		        imageElement.outerHTML=imageElement.outerHTML; //清空<input type="file" id= "image">的值 	

			}else if(isWithText){					
				//alert(isWithText);     //每行最多写72字符
				//对用户输入的信息进行处理
				isWithText = _initInputSolution(isWithText);
				//alert("New_isWithText="+isWithText);
				//获取用户要发送的消息内容----------发送文本消息
				var data={};
				data["fromID"]=fromID;
				data["fromName"]=fromName;
				data["toID"]=toID;
				data["text"]=isWithText;
				data["typeName"]="text";
				//发送消息
				websocket.send(JSON.stringify(data));
					
				//发送完消息，清空输入框
				$("#msg").val("");
		        console.log("finnish");
			}else{
				return;
			}
			
		}
		
		//处理用户在文本域中输入的字符串
		function _initInputSolution(textArea){
			var textLength = textArea.length;    //获取字符串长度 
			var cycNum = Math.floor(textLength/72);
			var ending =72;
			for(var i=0; i<cycNum; i++){
				textArea = textArea.slice(0,ending)+"\n"+textArea.slice(ending);
				ending = ending+73;
			}
			return textArea;
		}
			
						
		//获取用户要发送的消息内容----------发送文本消息
		/* var msg=$("#msg").val();
		if(msg==""){
			return;
		}else{
			var data={};
			data["fromID"]=fromID;
			data["fromName"]=fromName;
			data["toID"]=toID;
			data["text"]=msg;
			//发送消息
			websocket.send(JSON.stringify(data));
			//发送完消息，清空输入框
			$("#msg").val("");
		}  */
	}

	//关闭Websocket连接
	function closeWebsocket(){
		if (websocket != null) {
			websocket.close();
			websocket = null;
		}
		
	}
	
	//div滚动条(scrollbar)保持在最底部
	function scrollToBottom(){
		//var div = document.getElementById('chatCon');
		var div = document.getElementById('up');
		div.scrollTop = div.scrollHeight;
	}	
	//格式化日期
	Date.prototype.Format = function (fmt) { //author: meizz 
	    var o = {
	        "M+": this.getMonth() + 1, //月份 
	        "d+": this.getDate(), //日 
	        "h+": this.getHours(), //小时 
	        "m+": this.getMinutes(), //分 
	        "s+": this.getSeconds(), //秒  
	        "q+": Math.floor((this.getMonth() + 3) / 3), //季度              
	        "S": this.getMilliseconds() //毫秒 
	    };
	    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
	    for (var k in o)
	    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
	    return fmt;
	}
	
	//easyUI创建管理员踢人窗口
	function _solution(){
		if(fromName == "admin"){
			$("#concelUser").window('open');    //打开一个窗口			
		}else{
			$.messager.alert("消息","对不起，您不是管理员！","warning");
			return;
		}
	}
	
	//捕捉打开easyUI窗口前触发的事件
	$(document).ready(function(){
		$("#concelUser").window({
			onBeforeOpen:function(){ 
				//刷新grid
				/* //重新刷新在线用户信息
				_solution(); */
				$("#grid").datagrid("reload");
				$("#grid").datagrid("unselectAll");
			}
		});
	});
		
	function _delete(){
		$.messager.confirm('消息','确认要删除吗？',function(data){
			if(data){
				//采用ajax删除数据
				doDelete();
				//发送消息通知被删除的用户
	
			}
		});	
	}
	
	//删除选中的用户
	function doDelete(){
		//alert("删除...");
		//先获取选中的行
		var rows = $("#grid").datagrid("getSelections");
		
		//alert("rows="+rows);
		//先判断是否选中了，选中了才能作废操作
		if(rows.length==0 ){
			//提示：
			$.messager.alert("警告","必须至少选择一个用户","warning");
			return;
		}
		//作废操作:异步请求操作，传入参数，要作废的人员的id
		
		//姜数组对象转换为json对象（字符串的逗号分割-多选框name一样-String[]）
		//弄一个数组
		var rowsArray= new Array();
		
		for(var i=0;i<rows.length;i++){
			rowsArray.push(rows[i].id);
		}
		//转字符串
		var ids=rowsArray.join(",");
		console.log("ids======"+ids);
		
		//参数：两种name=rose&age=18,{}[]
		$.post("${pageContext.request.contextPath}/chat/deleteSelectUsers",{"ids":ids},function(data){
			//data:结果{result:true}
			if(data.result){
				//删除成功
				$.messager.alert("消息","删除成功","info");
				
				//发送消息给服务器，让其将删除的用户进行强制下线
				websocket.send(ids+":deleteSelectUser"); 
				//刷新grid
				/* //重新刷新在线用户信息
				_solution(); */
				$("#grid").datagrid("reload");
				$("#grid").datagrid("unselectAll");
			}else{
				//作废失败
				$.messager.alert("消息","删除失败","error");
			}
			
		});
		
	}
</script>
</head>

<body>
<!--顶部开始-->
<div class="top">
	<div class="inTop">
    	<p style="background-color: green;"><strong>KK聊天室，欢迎您！</strong></p>
    </div>
</div>
<!--顶部end-->
<!--头部开始-->
<div class="header">
	<div class="inHeader">
    	<h1>KK聊天室</h1>
        <div class="style">
        	<!-- 表达式?操作1:操作2  三目运算符 -->
        	<p>当前登录用户：${sessionScope.loginUser!=null?sessionScope.loginUser.nickname:"请登录" }&nbsp;&nbsp;&nbsp;<button id="exitBtn">退出或重新登录</button></p>
        </div>
    </div>
</div>
<!--头部end-->
<!--聊天区域开始-->
<div class="chatArea" id="chatArea">
	<div class="inChatArea">
    	<div id="chatSidebar" class="chatSidebar">
        	<h2 id="chatOnline">在线用户(0人)</h2>
            <ul id="chatUserList">
               
            </ul>
        </div>
    	<div class="chatCon">
        	<div class="up" id="up">
            	<ul id="contentUl">
            	<!-- 这里添加的是单聊的时候发送的消息############################### -->        
                	<!-- <li><b>14:08</b><em>江山如此多娇</em><span>今天天气不大家出来嗨！！！！！</span></li>
                	-->
                </ul>
<!--                 <img alt="" src=""> -->
            </div>
            <!-- 这里添加用户可以使用的功能 --> 
            <div>
                <table cellspacing="10" >            
                    <tr >
                        <th>
                            <input type='button' value='发送图片' onclick="document.getElementById('image').click()" style="width:100px;height:30px;"/>
                            <input type="file" id="image" accept="image/png, image/jpeg, image/gif, image/jpg" style="display:none;" />                            
                        </th>
                        <th>
                            <input type='button' value='发送文件' onclick="document.getElementById('file').click()" style="width:100px;height:30px;"/>
                            <input type="file" id="file" accept=".xls,.doc,.txt,.pdf, .docx, .xlsx, .caj, .xml, .zip, .rar, .mp4, .avi, .mp3" style="display:none;" />
                        </th>
                        <th>                        	
                            <input type='button' value='管理员踢人' onclick="_solution();" style="width:100px;height:30px;"/>
                        </th>
                        <th >私聊:</th>
                        <td>
                            <select name="privateChat" id="privateChat" ondblclick="loadOnlineAllUser();" >
	                            <option value="all">发给所有人</option>
	                            <option value=""></option>	                                                    
                            </select>
                        </td>
                        
                    </tr>
                </table>
            </div>
            <div>
                                                 显示进度：<progress id="progressBar" value="0"></progress><span id="percentage"></span><span id="time"></span>
            </div>
                        
            <div class="down">
                <!-- <textarea class="textInfo" id="msg" title="按ctrl+enter直接发送"></textarea> -->
                <textarea style="width:640px; height:100px" id="msg" title="按ctrl+enter直接发送" ></textarea>
                <button class="btn" id="sendBtn"></button>
            </div>
        </div>
	    <div class="ad">
        	<iframe src="https://www.bilibili.com/" width="315" height="635" scrolling="yes" frameborder="no"></iframe>
        </div>
    </div>
</div>
<!--聊天区域结束-->
<div class="footer">

</div>

<!-- 删除用户 -->
<div id="concelUser" class="easyui-window" align="center" style="width:800px;height:500px;" title="删除用户" closed="true" modal="true" collapsible="false" minimizable="false" maximizable="false" resizable="false">
<!-- 加载远程json格式数据 -->
	<table	id="grid" class="easyui-datagrid" data-options="url:'${pageContext.request.contextPath}/chat/findAllOnlineUser?id='+fromID, width:750, rownumbers:true, pagination:true, toolbar:'#menu'">
		<thead>     
			<tr>
				<th data-options="field:'checkbox',checkbox:true">选择框</th>
				<th data-options="field:'id',width:300">编号</th>
				<th data-options="field:'nickname',width:300">用户名</th>
			</tr>
		</thead>
	</table>
								
	<div id="menu" align="right">
		<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" style="width:100px;height:30px;" onclick="_delete();">删除</a>
	</div>
</div>
</body>
</html>
