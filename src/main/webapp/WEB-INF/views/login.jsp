<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<title>KK在线聊天室</title>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-1.11.3.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/lbt.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css" type="text/css" media="all" />
<script type="text/javascript">
	$(function(){
		//使用jQuery+Ajax进行用户名重复验证
			$("input[name='nickname']").blur(function(){         
	            var username= document.getElementById("myText").value;
	            //var url="${pageContext.request.contextPath}/";
	            //使用load方法
	            $("#validateResult").load("${pageContext.request.contextPath }/chat/judge",{"nickname":username}, function(){
	            	var spanValue=document.getElementById("validateResult").innerHTML;
	            	
	            	//alert(typeof spanValue);
	                //alert(spanValue.length);
	                //alert(spanValue);

	                     if(spanValue.length != 0){
	                       // alert(1111);
	                        //清空用户输入数据checkImg
	                        var myText=document.getElementById('myText');
	                        var myPassword=document.getElementById('myPassword');
	                        var checkImg=document.getElementById('checkImg');
	                        myText.value='';
	                        myPassword.value='';
	                        checkImg.value='';
	                        
	                        document.getElementById("bt").onclick = function(){ 

	                            return false; 

	                        };
	                    }
	                     
	                     //用户没有登录让登录按钮有效
	                     document.getElementById("bt").onclick = function(){ 

                             return true; 

                         };
	            });  //callback:function
	            
	        });   //blur

			             
	});  //$

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
<div class="loginMain">
	<div class="con">
    	<div class="inCon">
            <ul class="imgList">
                <li><img src="${pageContext.request.contextPath}/resources/images/1.png" width="680" height="494" /></li>
                <li><img src="${pageContext.request.contextPath}/resources/images/2.png" width="680" height="494" /></li>
                <li><img src="${pageContext.request.contextPath}/resources/images/3.png" width="680" height="494" /></li>
                <li><img src="${pageContext.request.contextPath}/resources/images/4.png" width="680" height="494" /></li>
                <li><img src="${pageContext.request.contextPath}/resources/images/5.png" width="680" height="494" /></li>
                <li><img src="${pageContext.request.contextPath}/resources/images/6.png" width="680" height="494" /></li>
                <li><img src="${pageContext.request.contextPath}/resources/images/7.png" width="680" height="494" /></li>
            </ul>
        </div>
        <ol class="btnList">
        	<li class="current"></li>
        	<li></li>
        	<li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
        </ol>
        <a href="javascript:;" class="left"></a>
        <a href="javascript:;" class="right"></a>   
    </div>


	<div class="loginArea">
    	<h2>欢迎登陆</h2>
        <p>欢迎您来到KK聊天室！</p>
        <div><font color="red" size="16">${requestScope.errorTips }</font></div>
        <form action="${pageContext.request.contextPath }/chat/login"  method="post" onsubmit="return chkForm(this)">
        	<input type="text" placeholder="请输入用户名" name="nickname" id="myText" />  <span id="validateResult"></span>
        	<input type="password" placeholder="请输入密码" name="password" id="myPassword" />            
            <input type="text" placeholder="验证码" name="checkImg" id="checkImg" />
            <img style="cursor: pointer;" alt="" src="${pageContext.request.contextPath}/img" id="img" onclick="_changImg();"/><a href="javascript:void(0);" onclick="_changImg();">看不清，换一张</a>
                              
            <br/>
            <h3><font color="red">${sessionScope.msg}</font></h3>
            <button id="bt">登录</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" onclick="window.location.href='${pageContext.request.contextPath }/chat/regist'" value="注册" id="reg" />
        </form>
    </div>
</div>
<!--登陆区域结束-->

<div class="footer">
	
</div>
</body>

<script type="text/javascript">
	//进行一个前端的用户登录信息验证
	var myText=document.getElementById('myText');
	var myPassword=document.getElementById('myPassword');
	var checkImg=document.getElementById('checkImg');
	
	//用户名验证######################################
	myText.onfocus=function(){    //光标聚焦
		if(myText.placeholder=='请输入用户名'){       //这里是假登录
			myText.placeholder='';
			myText.style.color='#333';	
		}	
	}
	myText.onblur=function(){
		if(myText.placeholder==''){
			myText.placeholder='请输入用户名';
			myText.style.color='#ccc';
		}	
	}
	
	//密码校验###########################################
	myPassword.onfocus=function(){    //光标聚焦
		if(myPassword.placeholder=='请输入密码'){   //这里是假登录
			myPassword.placeholder='';
			myPassword.style.color='#333';	
		}	
	}
	myPassword.onblur=function(){
		if(myPassword.placeholder==''){ 
			myPassword.placeholder='请输入密码';
			myPassword.style.color='#ccc';                     //checkImg
		}	
	}
	
	//用户名验证码校验######################################
    checkImg.onfocus=function(){    //光标聚焦
        if(checkImg.placeholder=='验证码'){       //这里是假登录
        	checkImg.placeholder='';
        	checkImg.style.color='#333';  
        }   
    }
    checkImg.onblur=function(){
        if(checkImg.placeholder==''){
        	checkImg.placeholder='验证码';
        	checkImg.style.color='#ccc';
        }   
    }
	
	//用户名密码不为空校验
	function chkForm(name){
		
		var username=name.nickname.value;
		var password=name.password.value;
		var checkImg=name.checkImg.value;
		
		if(username==null || username==""){
            alert("用户名不能为空");
            return false;
        }else if(password==null || password==""){
            alert("密码不能为空");
            return false;
        }else if(checkImg==null || checkImg==""){
        	alert("验证码不能为空");
            return false;
        }else{
			return true;
		}
	}
		
	//验证码判断
	function _changImg(){
            document.getElementById("img").src = "${pageContext.request.contextPath}/img?" + new Date().getTime();
          //获取图片中的验证码
            var validateCode = "<%=session.getAttribute("servletImg")%>";
        }
</script>
</html>













