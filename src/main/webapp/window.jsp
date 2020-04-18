<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!-- 引入easyUI 外部头文件 -->
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/themes/default/easyui.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/themes/icon.css" />

<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/jquery.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/jquery.easyui.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/locale/easyui-lang-zh_CN.js"></script>
<!-- <script type="text/javascript" src="/js/common.js"></script> -->

<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/sockjs.min.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css" type="text/css" media="all" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/chat.css" type="text/css" media="all" />
<title>跳转到主页</title>
<script type="text/javascript">
	function _delete2(){
		//从数据库中删除选中的用户
		alert("删除成功");
	}

	function _solution(){
		$("#concelUser").window("open");
	}
</script>

</head>
<body>
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
                            <input type="file" id="file" accept=".xls,.doc,.txt,.pdf, .docx, .xlsx" style="display:none;" />
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
                <textarea style="width:640px; height:100px" id="msg" title="按enter直接发送"></textarea>
                <button class="btn" id="sendBtn"></button>
            </div>
        </div>
	    <div class="ad">
        	<iframe src="https://www.kedacom.com/" width="315" height="635" scrolling="yes" frameborder="no"></iframe>
        </div>
    </div>
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
                            <input type="file" id="file" accept=".xls,.doc,.txt,.pdf, .docx, .xlsx" style="display:none;" />
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

	<div id="concelUser" class="easyui-window" align="center" style="width:500px;height:500px;" data-options="title:'删除用户',closed:true,modal:true,collapsible:false,minimizable:false,maximizable:false">
		<!-- 加载远程json格式数据 -->
		<table	class="easyui-datagrid" data-options="url:'data.txt',width:500,rownumbers:true,pagination:true,toolbar:'#menu'">
			<thead>
				<tr>
					<th data-options="field:'checkbox',checkbox:true">选择框</th>
					<th data-options="field:'id',width:200">编号</th>
					<th data-options="field:'nickname',width:200">用户名</th>
				</tr>
			</thead>
		</table>
		
		<div id="menu" align="right">
			<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" style="width:100px;height:30px;" onclick="_delete2();">删除</a>
		</div>
	</div>
	<input type="button" value="点击" onclick="_delete();">
</body>
</html>