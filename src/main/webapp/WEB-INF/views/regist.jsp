<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<title>KK在线聊天室</title>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/resources/js/jquery-1.11.3.min.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/resources/js/lbt.js"></script>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/style.css" type="text/css" media="all" />
	
<script type="text/javascript">
	$(function() {
		//使用jQuery+Ajax进行用户名重复验证
        $("input[name='nickname']").blur(function(){   
            var username= document.getElementById("myText").value;
            //使用Ajax的load方法
            $("#validateResult").load("${pageContext.request.contextPath }/chat/judgeUserNameIsExit",{"nickname":username}, function(){
                    var spanValue=document.getElementById("validateResult").innerHTML;
                    
                    //alert(typeof spanValue);
                    //alert(spanValue.length);
                    //alert(spanValue);

                         if(spanValue.length != 0){
                           // alert(1111);
                          //清空用户输入数据
                            var myText=document.getElementById('myText');
                            var myPassword=document.getElementById('myPassword');
                            var myPassword2=document.getElementById('myPassword2');
                            myText.value='';
                            myPassword.value='';
                            myPassword2.value='';

                            document.getElementById("bt").onclick = function(){ 

                                return false; 

                            };
                        }
                         
                       //用户名没有注册就让注册按钮有效
                         document.getElementById("bt").onclick = function(){ 

                             return true; 

                         };
                });  //callback:function
            
        });
   
	});
		
</script>


</head>
<body>
	<!--顶部开始-->
	<div class="top">
		<div class="inTop">
			<p style="background-color: green;">KK聊天室，欢迎您！</p>
		</div>
	</div>
	<!--顶部end-->
	<!--头部开始-->
	<div class="header">
		<h1>KK聊天室</h1>
	</div>
	<!--头部end-->
	<!--登陆区域开始-->
	<div class="registMain">
		<div class="registArea">
			<h2>欢迎注册</h2>
			<p>欢迎您来到KK聊天室！</p>
			<div>
				<font color="red" size="16">${requestScope.errorTips }</font>
			</div>
			<form action="${pageContext.request.contextPath }/chat/doRegist" method="post" onsubmit="return chkForm(this)">
				<input type="text" placeholder="请输入用户名" name="nickname" id="myText" />  <span id="validateResult"></span>
				<input type="password" placeholder="请输入密码" name="password" id="myPassword" />
				<input type="password" placeholder="请再次输入密码" name="password2" id="myPassword2" />
				<button id="bt">提交</button>
				<button type="reset" >重置</button>
			</form>
		</div>
	</div>
	<!--登陆区域结束-->

	<div class="footer"></div>
</body>


<script type="text/javascript">
	//进行一个前端的用户登录信息验证
	var myText = document.getElementById('myText');
	var myPassword = document.getElementById('myPassword');
	var myPassword2 = document.getElementById('myPassword2');
	
	//用户名验证######################################
	myText.onfocus = function() { //光标聚焦
		if (myText.placeholder == '请输入用户名') { //这里是假登录
			myText.placeholder = '';
			myText.style.color = '#333';
		}
	}
	myText.onblur = function() {
		if (myText.placeholder == '') {
			myText.placeholder = '请输入用户名';
			myText.style.color = '#ccc';
		}
	}
	
	//密码校验###########################################
	myPassword.onfocus = function() { //光标聚焦
		if (myPassword.placeholder == '请输入密码') { //这里是假登录
			myPassword.placeholder = '';
			myPassword.style.color = '#333';
		}
	}
	myPassword.onblur = function() {
		if (myPassword.placeholder == '') {
			myPassword.placeholder = '请输入密码';
			myPassword.style.color = '#ccc';
		}
	}
	
	//确认密码
	myPassword2.onfocus = function() { //光标聚焦
		if (myPassword2.placeholder == '请再次输入密码') { //这里是假登录
			myPassword2.placeholder = '';
			myPassword2.style.color = '#333';
		}
	}
	myPassword2.onblur = function() {
		if (myPassword2.placeholder == '') {
			myPassword2.placeholder = '请再次输入密码';
			myPassword2.style.color = '#ccc';
		}
	}
	
	//用户名密码不为空校验
	function chkForm(name) {
		var username = name.nickname.value;
		var password = name.password.value;
		var password2 = name.password2.value;
		
		if(username==null || username==""){
			alert("用户名不能为空");
			return false;
		}else if(password==null || password==""){
			alert("密码不能为空");
			return false;
		} else if (password !== password2) {
			alert("两次输入的密码不一致，请重新输入");
			myText.value = '';
			myPassword.value = '';
			myPassword2.value = '';
			return false;
		} else {
			return true;
		}
	 }
</script>
</html>













