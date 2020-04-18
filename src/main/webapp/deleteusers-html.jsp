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
<title>跳转到主页</title>
<script type="text/javascript">
	function _delete(){
		//从数据库中删除选中的用户
		alert("删除成功");
	}
</script>

</head>
<body>
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
		<a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'" style="width:100px;height:30px;" onclick="_delete();">删除</a>
	</div>
</body>
</html>